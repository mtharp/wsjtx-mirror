//-------------------------------------------------------- MainWindow

#include "mainwindow.h"
#include <cinttypes>
#include <limits>

#include <QLineEdit>
#include <QRegExpValidator>
#include <QRegExp>
#include <QDesktopServices>
#include <QUrl>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QtConcurrent/QtConcurrentRun>
#include <QProgressDialog>
#include <QHostInfo>
#include <QVector>
#include <QCursor>
#include <QToolTip>

#include "revision_utils.hpp"
#include "qt_helpers.hpp"
#include "soundout.h"
#include "soundin.h"
#include "Modulator.hpp"
#include "Detector.hpp"
#include "plotter.h"
#include "echoplot.h"
#include "echograph.h"
#include "fastplot.h"
#include "fastgraph.h"
#include "about.h"
#include "astro.h"
#include "messageaveraging.h"
#include "widegraph.h"
#include "sleep.h"
#include "logqso.h"
#include "Radio.hpp"
#include "Bands.hpp"
#include "TransceiverFactory.hpp"
#include "FrequencyList.hpp"
#include "StationList.hpp"
#include "LiveFrequencyValidator.hpp"
#include "MessageClient.hpp"
#include "wsprnet.h"
#include "signalmeter.h"
#include "HelpTextWindow.hpp"
#include "SampleDownloader.hpp"
#include "Audio/BWFFile.hpp"

#include "ui_mainwindow.h"
#include "moc_mainwindow.cpp"


extern "C" {
  //----------------------------------------------------- C and Fortran routines
  void symspec_(struct dec_data *, int* k, int* ntrperiod, int* nsps, int* ingain, int* minw,
                float* px, float s[], float* df3, int* nhsym, int* npts8);

  void hspec_(short int d2[], int* k, int* ingain, float green[], float s[], int* jh);

  void gen4_(char* msg, int* ichk, char* msgsent, int itone[],
               int* itext, int len1, int len2);

  void gen9_(char* msg, int* ichk, char* msgsent, int itone[],
               int* itext, int len1, int len2);

  void genmsk_(char* msg, int* ichk, char* msgsent, int itone[],
               int* itext, int len1, int len2);

  void gen65_(char* msg, int* ichk, char* msgsent, int itone[],
              int* itext, int len1, int len2);

  void genwspr_(char* msg, char* msgsent, int itone[], int len1, int len2);

  void geniscat_(char* msg, char* msgsent, int itone[], int len1, int len2);

  bool stdmsg_(const char* msg, int len);

  void azdist_(char* MyGrid, char* HisGrid, double* utch, int* nAz, int* nEl,
               int* nDmiles, int* nDkm, int* nHotAz, int* nHotABetter,
               int len1, int len2);

  void morse_(char* msg, int* icw, int* ncw, int len);

  int ptt_(int nport, int ntx, int* iptt, int* nopen);

  int fftwf_import_wisdom_from_filename(const char *);
  int fftwf_export_wisdom_to_filename(const char *);

  void wspr_downsample_(short int d2[], int* k);
  void savec2_(char* fname, int* m_TRseconds, double* m_dialFreq, int len1);

  void avecho_( short id2[], int* dop, int* nfrit, int* nqual, float* f1,
                float* level, float* sigdb, float* snr, float* dfreq,
                float* width);

  void fast_decode_(short id2[], int narg[], char msg[], int len);
  void hash_calls_(char calls[], int* ih9, int len);
  void degrade_snr_(short d2[], int* n, float* db);
  void wav12_(short d2[], short d1[], int* nbytes, short* nbitsam2);
}

int volatile itone[NUM_ISCAT_SYMBOLS];	//Audio tones for all Tx symbols
int volatile icw[NUM_CW_SYMBOLS];	    //Dits for CW ID
struct dec_data dec_data;             // for sharing with Fortran

int outBufSize;
int rc;
qint32  g_iptt;
wchar_t buffer[256];
float fast_green[703];
float fast_green2[703];
float fast_s[44992];                                    //44992=64*703
float fast_s2[44992];
int   fast_jh;
int   fast_jh2;
int narg[14];
QVector<QColor> g_ColorTbl;

namespace
{
  Radio::Frequency constexpr default_frequency {14076000};
  QRegExp message_alphabet {"[- @A-Za-z0-9+./?#<>]*"};

  bool message_is_73 (int type, QStringList const& msg_parts)
  {
    return type >= 0
      && ((type < 6 && msg_parts.contains ("73"))
          || (type == 6 && !msg_parts.filter ("73").isEmpty ()));
  }
}

//--------------------------------------------------- MainWindow constructor
MainWindow::MainWindow(bool multiple, QSettings * settings, QSharedMemory *shdmem,
                       unsigned downSampleFactor, QNetworkAccessManager * network_manager,
                       QWidget *parent) :
  QMainWindow(parent),
  m_dataDir {QStandardPaths::writableLocation (QStandardPaths::DataLocation)},
  m_revision {revision ()},
  m_multiple {multiple},
  m_settings {settings},
  ui(new Ui::MainWindow),
  m_config {settings, this},
  m_WSPR_band_hopping {settings, &m_config, this},
  m_WSPR_tx_next {false},
  m_wideGraph (new WideGraph(settings)),
  m_echoGraph (new EchoGraph(settings)),
  m_fastGraph (new FastGraph(settings)),
  m_logDlg (new LogQSO (program_title (), settings, this)),
  m_dialFreq {std::numeric_limits<Radio::Frequency>::max ()},
  m_detector {new Detector {RX_SAMPLE_RATE, NTMAX, 6912 / 2, downSampleFactor}},
  m_soundInput {new SoundInput},
  m_modulator {new Modulator {TX_SAMPLE_RATE, NTMAX}},
  m_soundOutput {new SoundOutput},
  m_XIT {0},
  m_pctx {0},
  m_diskData {false},
  m_sentFirst73 {false},
  m_currentMessageType {-1},
  m_lastMessageType {-1},
  m_uploading {false},
  m_tuneup {false},
  m_bSimplex {false},
  m_appDir {QApplication::applicationDirPath ()},
  mem_jt9 {shdmem},
  m_msAudioOutputBuffered (0u),
  m_framesAudioInputBuffered (RX_SAMPLE_RATE / 10),
  m_downSampleFactor (downSampleFactor),
  m_audioThreadPriority (QThread::HighPriority),
  m_bandEdited {false},
  m_splitMode {false},
  m_monitoring {false},
  m_transmitting {false},
  m_tune {false},
  m_tune_attenuation {0},
  m_tune_attenuation_restore {0},
  m_block_pwr_tooltip {false},
  m_lastMonitoredFrequency {default_frequency},
  m_toneSpacing {0.},
  m_firstDecode {0},
  m_optimizingProgress {"Optimizing decoder FFTs for your CPU.\n"
      "Please be patient,\n"
      "this may take a few minutes", QString {}, 0, 1, this},
  m_messageClient {new MessageClient {QApplication::applicationName (),
                   m_config.udp_server_name (), m_config.udp_server_port (),
                   this}},
  psk_Reporter {new PSK_Reporter {m_messageClient, this}},
  m_manual {network_manager}
{
  ui->setupUi(this);

  m_optimizingProgress.setWindowModality (Qt::WindowModal);
  m_optimizingProgress.setAutoReset (false);
  m_optimizingProgress.setMinimumDuration (15000); // only show after 15s delay

  // Closedown.
  connect (ui->actionExit, &QAction::triggered, this, &QMainWindow::close);

  // parts of the rig error message box that are fixed
  m_rigErrorMessageBox.setInformativeText (tr ("Do you want to reconfigure the radio interface?"));
  m_rigErrorMessageBox.setStandardButtons (QMessageBox::Cancel | QMessageBox::Ok | QMessageBox::Retry);
  m_rigErrorMessageBox.setDefaultButton (QMessageBox::Ok);
  m_rigErrorMessageBox.setIcon (QMessageBox::Critical);

  // start audio thread and hook up slots & signals for shutdown management
  // these objects need to be in the audio thread so that invoking
  // their slots is done in a thread safe way
  m_soundOutput->moveToThread (&m_audioThread);
  m_modulator->moveToThread (&m_audioThread);
  m_soundInput->moveToThread (&m_audioThread);
  m_detector->moveToThread (&m_audioThread);

  // hook up sound output stream slots & signals and disposal
  connect (this, &MainWindow::initializeAudioOutputStream, m_soundOutput, &SoundOutput::setFormat);
  connect (m_soundOutput, &SoundOutput::error, this, &MainWindow::showSoundOutError);
  // connect (m_soundOutput, &SoundOutput::status, this, &MainWindow::showStatusMessage);
  connect (this, &MainWindow::outAttenuationChanged, m_soundOutput, &SoundOutput::setAttenuation);
  connect (&m_audioThread, &QThread::finished, m_soundOutput, &QObject::deleteLater);

  // hook up Modulator slots and disposal
  connect (this, &MainWindow::transmitFrequency, m_modulator, &Modulator::setFrequency);
  connect (this, &MainWindow::endTransmitMessage, m_modulator, &Modulator::stop);
  connect (this, &MainWindow::tune, m_modulator, &Modulator::tune);
  connect (this, &MainWindow::sendMessage, m_modulator, &Modulator::start);
  connect (&m_audioThread, &QThread::finished, m_modulator, &QObject::deleteLater);

  // hook up the audio input stream signals, slots and disposal
  connect (this, &MainWindow::startAudioInputStream, m_soundInput, &SoundInput::start);
  connect (this, &MainWindow::suspendAudioInputStream, m_soundInput, &SoundInput::suspend);
  connect (this, &MainWindow::resumeAudioInputStream, m_soundInput, &SoundInput::resume);
  connect (this, &MainWindow::finished, m_soundInput, &SoundInput::stop);
  connect(m_soundInput, &SoundInput::error, this, &MainWindow::showSoundInError);
  // connect(m_soundInput, &SoundInput::status, this, &MainWindow::showStatusMessage);
  connect (&m_audioThread, &QThread::finished, m_soundInput, &QObject::deleteLater);

  connect (this, &MainWindow::finished, this, &MainWindow::close);

  // hook up the detector signals, slots and disposal
  connect(m_detector, &Detector::framesWritten, this, &MainWindow::dataSink);
  connect (&m_audioThread, &QThread::finished, m_detector, &QObject::deleteLater);

  // setup the waterfall
  connect(m_wideGraph.data (), SIGNAL(freezeDecode2(int)),this,SLOT(freezeDecode(int)));
  connect(m_wideGraph.data (), SIGNAL(f11f12(int)),this,SLOT(bumpFqso(int)));
  connect(m_wideGraph.data (), SIGNAL(setXIT2(int)),this,SLOT(setXIT(int)));

  connect(m_fastGraph.data(),SIGNAL(fastPick(int,int,int)),this,
          SLOT(fastPick(int,int,int)));

  connect (this, &MainWindow::finished, m_wideGraph.data (), &WideGraph::close);
  connect (this, &MainWindow::finished, m_echoGraph.data (), &EchoGraph::close);
  connect (this, &MainWindow::finished, m_fastGraph.data (), &FastGraph::close);

  // setup the log QSO dialog
  connect (m_logDlg.data (), &LogQSO::acceptQSO, this, &MainWindow::acceptQSO2);
  connect (this, &MainWindow::finished, m_logDlg.data (), &LogQSO::close);

  // Network message handlers
  connect (m_messageClient, &MessageClient::reply, this, &MainWindow::replyToCQ);
  connect (m_messageClient, &MessageClient::replay, this, &MainWindow::replayDecodes);
  connect (m_messageClient, &MessageClient::halt_tx, [this] (bool auto_only) {
      if (m_config.accept_udp_requests ()) {
        if (auto_only) {
          if (ui->autoButton->isChecked ()) {
            ui->autoButton->click();
          }
        } else {
          ui->stopTxButton->click();
        }
      }
    });
  connect (m_messageClient, &MessageClient::error, this, &MainWindow::networkError);
  connect (m_messageClient, &MessageClient::free_text, [this] (QString const& text, bool send) {
      if (m_config.accept_udp_requests ()) {
        // send + non-empty text means set and send the free text
        // message, !send + non-empty text means set the current free
        // text message, send + empty text means send the current free
        // text message without change, !send + empty text means clear
        // the current free text message
        qDebug () << "Free text UDP message - text:" << text << "send:" << send << "text empty:" << text.isEmpty ();
        if (0 == ui->tabWidget->currentIndex ()) {
          if (!text.isEmpty ()) {
            ui->tx5->setCurrentText (text);
          }
          if (send) {
            ui->txb5->click ();
          } else if (text.isEmpty ()) {
            ui->tx5->setCurrentText (text);
          }
        } else if (1 == ui->tabWidget->currentIndex ()) {
          if (!text.isEmpty ()) {
            ui->freeTextMsg->setCurrentText (text);
          }
          if (send) {
            ui->rbFreeText->click ();
          } else if (text.isEmpty ()) {
            ui->freeTextMsg->setCurrentText (text);
          }
        }
      }
    });

  // Hook up WSPR band hopping
  connect (ui->band_hopping_schedule_push_button, &QPushButton::clicked
           , &m_WSPR_band_hopping, &WSPRBandHopping::show_dialog);
  connect (ui->sbTxPercent, static_cast<void (QSpinBox::*) (int)> (&QSpinBox::valueChanged)
           , &m_WSPR_band_hopping, &WSPRBandHopping::set_tx_percent);

  on_EraseButton_clicked ();

  QActionGroup* modeGroup = new QActionGroup(this);
  ui->actionJT9->setActionGroup(modeGroup);
  ui->actionJT65->setActionGroup(modeGroup);
  ui->actionJT9_JT65->setActionGroup(modeGroup);
  ui->actionJT4->setActionGroup(modeGroup);
  ui->actionWSPR_2->setActionGroup(modeGroup);
  ui->actionWSPR_15->setActionGroup(modeGroup);
  ui->actionEcho->setActionGroup(modeGroup);
  ui->actionISCAT->setActionGroup(modeGroup);
  ui->actionJTMSK->setActionGroup(modeGroup);

  QActionGroup* saveGroup = new QActionGroup(this);
  ui->actionNone->setActionGroup(saveGroup);
  ui->actionSave_decoded->setActionGroup(saveGroup);
  ui->actionSave_all->setActionGroup(saveGroup);

  QActionGroup* DepthGroup = new QActionGroup(this);
  ui->actionQuickDecode->setActionGroup(DepthGroup);
  ui->actionMediumDecode->setActionGroup(DepthGroup);
  ui->actionDeepestDecode->setActionGroup(DepthGroup);
  ui->actionInclude_averaging->setActionGroup(DepthGroup);
  ui->actionInclude_correlation->setActionGroup(DepthGroup);

  connect (ui->download_samples_action, &QAction::triggered, [this, network_manager] () {
      if (!m_sampleDownloader)
        {
          m_sampleDownloader.reset (new SampleDownloader {m_settings, &m_config, network_manager, this});
        }
      m_sampleDownloader->show ();
    });

  QButtonGroup* txMsgButtonGroup = new QButtonGroup;
  txMsgButtonGroup->addButton(ui->txrb1,1);
  txMsgButtonGroup->addButton(ui->txrb2,2);
  txMsgButtonGroup->addButton(ui->txrb3,3);
  txMsgButtonGroup->addButton(ui->txrb4,4);
  txMsgButtonGroup->addButton(ui->txrb5,5);
  txMsgButtonGroup->addButton(ui->txrb6,6);
  connect(txMsgButtonGroup,SIGNAL(buttonClicked(int)),SLOT(set_ntx(int)));
  connect(ui->decodedTextBrowser2,SIGNAL(selectCallsign(bool,bool)),this,
          SLOT(doubleClickOnCall(bool,bool)));
  connect(ui->decodedTextBrowser,SIGNAL(selectCallsign(bool,bool)),this,
          SLOT(doubleClickOnCall2(bool,bool)));

  // initialise decoded text font and hook up change signal
  setDecodedTextFont (m_config.decoded_text_font ());
  connect (&m_config, &Configuration::decoded_text_font_changed, [this] (QFont const& font) {
      setDecodedTextFont (font);
    });

  setWindowTitle (program_title ());
  createStatusBar();

  connect(&proc_jt9, SIGNAL(readyReadStandardOutput()),this, SLOT(readFromStdout()));
  connect(&proc_jt9, SIGNAL(error(QProcess::ProcessError)),this, SLOT(jt9_error(QProcess::ProcessError)));
  connect(&proc_jt9, SIGNAL(readyReadStandardError()),this, SLOT(readFromStderr()));

  connect(&p1, SIGNAL(readyReadStandardOutput()),this, SLOT(p1ReadFromStdout()));
  connect(&p1, SIGNAL(error(QProcess::ProcessError)),this, SLOT(p1Error(QProcess::ProcessError)));
  connect(&p1, SIGNAL(readyReadStandardError()),this, SLOT(p1ReadFromStderr()));

//  connect(&p3, SIGNAL(readyReadStandardOutput()),this, SLOT(p3ReadFromStdout()));
  connect(&p3, SIGNAL(error(QProcess::ProcessError)),this, SLOT(p3Error(QProcess::ProcessError)));
  connect(&p3, SIGNAL(readyReadStandardError()),this, SLOT(p3ReadFromStderr()));

  // Hook up working frequencies.
  ui->bandComboBox->setModel (m_config.frequencies ());
  ui->bandComboBox->setModelColumn (FrequencyList::frequency_mhz_column);

  // combo box drop down width defaults to the line edit + decorator width,
  // here we change that to the column width size hint of the model column
  ui->bandComboBox->view ()->setMinimumWidth (ui->bandComboBox->view ()->sizeHintForColumn (FrequencyList::frequency_mhz_column));

  // Enable live band combo box entry validation and action.
  auto band_validator = new LiveFrequencyValidator {ui->bandComboBox
                                                    , m_config.bands ()
                                                    , m_config.frequencies ()
                                                    , this};
  ui->bandComboBox->setValidator (band_validator);

  // Hook up signals.
  connect (band_validator, &LiveFrequencyValidator::valid, this, &MainWindow::band_changed);
  connect (ui->bandComboBox->lineEdit (), &QLineEdit::textEdited, [this] (QString const&) {m_bandEdited = true;});

  // hook up configuration signals
  connect (&m_config, &Configuration::transceiver_update, this, &MainWindow::handle_transceiver_update);
  connect (&m_config, &Configuration::transceiver_failure, this, &MainWindow::handle_transceiver_failure);
  connect (&m_config, &Configuration::udp_server_changed, m_messageClient, &MessageClient::set_server);
  connect (&m_config, &Configuration::udp_server_port_changed, m_messageClient, &MessageClient::set_server_port);

  // set up message text validators
  ui->tx1->setValidator (new QRegExpValidator {message_alphabet, this});
  ui->tx2->setValidator (new QRegExpValidator {message_alphabet, this});
  ui->tx3->setValidator (new QRegExpValidator {message_alphabet, this});
  ui->tx4->setValidator (new QRegExpValidator {message_alphabet, this});
  ui->tx5->setValidator (new QRegExpValidator {message_alphabet, this});
  ui->tx6->setValidator (new QRegExpValidator {message_alphabet, this});
  ui->freeTextMsg->setValidator (new QRegExpValidator {message_alphabet, this});

  // Free text macros model to widget hook up.
  ui->tx5->setModel (m_config.macros ());
  connect (ui->tx5->lineEdit ()
           , &QLineEdit::editingFinished
           , [this] () {on_tx5_currentTextChanged (ui->tx5->lineEdit ()->text ());});
  ui->freeTextMsg->setModel (m_config.macros ());
  connect (ui->freeTextMsg->lineEdit ()
           , &QLineEdit::editingFinished
           , [this] () {on_freeTextMsg_currentTextChanged (ui->freeTextMsg->lineEdit ()->text ());});

  connect(&m_guiTimer, &QTimer::timeout, this, &MainWindow::guiUpdate);
  m_guiTimer.start(100);   //### Don't change the 100 ms! ###

  ptt0Timer = new QTimer(this);
  ptt0Timer->setSingleShot(true);
  connect(ptt0Timer, &QTimer::timeout, this, &MainWindow::stopTx2);
  ptt1Timer = new QTimer(this);
  ptt1Timer->setSingleShot(true);
  connect(ptt1Timer, &QTimer::timeout, this, &MainWindow::startTx2);

  logQSOTimer = new QTimer(this);
  logQSOTimer->setSingleShot(true);
  connect(logQSOTimer, &QTimer::timeout, this, &MainWindow::on_logQSOButton_clicked);

  tuneButtonTimer= new QTimer(this);
  tuneButtonTimer->setSingleShot(true);
  connect(tuneButtonTimer, &QTimer::timeout, this, &MainWindow::on_stopTxButton_clicked);

  tuneATU_Timer= new QTimer(this);
  tuneATU_Timer->setSingleShot(true);
  connect(tuneATU_Timer, &QTimer::timeout, this, &MainWindow::stopTuneATU);

  killFileTimer = new QTimer(this);
  killFileTimer->setSingleShot(true);
  connect(killFileTimer, &QTimer::timeout, this, &MainWindow::killFile);

  uploadTimer = new QTimer(this);
  uploadTimer->setSingleShot(true);
  connect(uploadTimer, SIGNAL(timeout()), this, SLOT(uploadSpots()));

  TxAgainTimer = new QTimer(this);
  TxAgainTimer->setSingleShot(true);
  connect(TxAgainTimer, SIGNAL(timeout()), this, SLOT(TxAgain()));

  RxQSYTimer = new QTimer(this);
  RxQSYTimer->setSingleShot(true);
  connect(RxQSYTimer, SIGNAL(timeout()), this, SLOT(RxQSY()));

  m_auto=false;
  m_waterfallAvg = 1;
  m_txFirst=false;
  m_btxok=false;
  m_restart=false;
  m_killAll=false;
  m_widebandDecode=false;
  m_ntx=1;

  m_tx=0;
  m_txNext=false;
  m_grid6=false;
  m_nseq=0;
  m_ntr=0;

  m_loopall=false;
  m_startAnother=false;
  m_saveDecoded=false;
  m_saveAll=false;
  m_sec0=-1;
  m_palette="Linrad";
  m_RxLog=1;                     //Write Date and Time to RxLog
  m_nutc0=9999;
  m_mode="JT9";
  m_rpt="-15";
  m_TRperiod=60;
  m_inGain=0;
  m_dataAvailable=false;
  g_iptt=0;
  m_secID=0;
  m_blankLine=false;
  m_decodedText2=false;
  m_freeText=false;
  m_msErase=0;
  m_sentFirst73=false;
  m_watchdogLimit=7;
  m_repeatMsg=0;
  m_secBandChanged=0;
  m_lockTxFreq=false;
  m_baseCall = Radio::base_callsign (m_config.my_callsign ());
  m_QSOText.clear();
  decodeBusy(false);
  m_nSubMode=0;
  m_DTtol=0.5;
  m_wideGraph->setTol(500);
  m_bShMsgs=false;
  m_bTxTime=false;
  m_rxDone=false;
  m_bEchoTxOK=false;
  m_bTransmittedEcho=false;
  m_bFastDecodeCalled=false;
  m_bDoubleClickAfterCQnnn=false;
  m_nclearave=1;
  m_bEchoTxed=false;
  m_nWSPRdecodes=0;
  m_k0=9999999;
  m_nPick=0;
  m_DTtol=3.0;
  m_TRperiodFast=-1;
  m_nTx73=0;
  m_freqCQ=0;
  m_dialFreq0=0;
  QString t1[28]={"1 uW","2 uW","5 uW","10 uW","20 uW","50 uW","100 uW","200 uW","500 uW",
                  "1 mW","2 mW","5 mW","10 mW","20 mW","50 mW","100 mW","200 mW","500 mW",
                  "1 W","2 W","5 W","10 W","20 W","50 W","100 W","200 W","500 W","1 kW"};

  for(int i=0; i<28; i++)  {                      //Initialize dBm values
    float dbm=(10.0*i)/3.0 - 30.0;
    int ndbm=0;
    if(dbm<0) ndbm=int(dbm-0.5);
    if(dbm>=0) ndbm=int(dbm+0.5);
    QString t;
    t.sprintf("%d dBm  ",ndbm);
    t+=t1[i];
    ui->TxPowerComboBox->addItem(t);
  }

  ui->labAz->setStyleSheet("border: 0px;");
  ui->labDist->setStyleSheet("border: 0px;");

  auto t = "UTC   dB   DT Freq   Message";
  ui->decodedTextLabel->setText(t);
  ui->decodedTextLabel2->setText(t);

  readSettings();		         //Restore user's setup params

  m_audioThread.start (m_audioThreadPriority);

#ifdef WIN32
  if (!m_multiple)
    {
      while(true)
        {
          int iret=killbyname("jt9.exe");
          if(iret == 603) break;
          if(iret != 0) msgBox("KillByName return code: " +
                               QString::number(iret));
        }
    }
#endif

  auto_tx_label->setText (m_config.quick_call () ? "Auto-Tx-Enable Armed" : "Auto-Tx-Enable Disarmed");

  {
    //delete any .quit file that might have been left lying around
    //since its presence will cause jt9 to exit a soon as we start it
    //and decodes will hang
    QFile quitFile {m_config.temp_dir ().absoluteFilePath (".quit")};
    while (quitFile.exists ())
      {
        if (!quitFile.remove ())
          {
            msgBox ("Error removing \"" + quitFile.fileName () +
                    "\" - OK to retry.");
          }
      }
  }

  //Create .lock so jt9 will wait
  QFile {m_config.temp_dir ().absoluteFilePath (".lock")}.open(QIODevice::ReadWrite);

  QStringList jt9_args {
    "-s", QApplication::applicationName () // shared memory key,
                                           // includes rig-name
#ifdef NDEBUG
      , "-w", "1"               //FFTW patience - release
#else
      , "-w", "1"               //FFTW patience - debug builds for speed
#endif
      // The number  of threads for  FFTW specified here is  chosen as
      // three because  that gives  the best  throughput of  the large
      // FFTs used  in jt9.  The count  is the minimum of  (the number
      // available CPU threads less one) and three.  This ensures that
      // there is always at least one free CPU thread to run the other
      // mode decoder in parallel.
      , "-m", QString::number (qMin (qMax (QThread::idealThreadCount () - 1, 1), 3)) //FFTW threads

      , "-e", QDir::toNativeSeparators (m_appDir)
      , "-a", QDir::toNativeSeparators (m_dataDir.absolutePath ())
      , "-t", QDir::toNativeSeparators (m_config.temp_dir ().absolutePath ())
      };
  proc_jt9.start(QDir::toNativeSeparators (m_appDir) + QDir::separator () +
          "jt9", jt9_args, QIODevice::ReadWrite | QIODevice::Unbuffered);

  QString fname {QDir::toNativeSeparators(m_dataDir.absoluteFilePath ("wsjtx_wisdom.dat"))};
  QByteArray cfname=fname.toLocal8Bit();
  fftwf_import_wisdom_from_filename(cfname);

  getpfx();                               //Load the prefix/suffix dictionary
  genStdMsgs(m_rpt);
  m_ntx=6;
  ui->txrb6->setChecked(true);
  if(m_mode=="") m_mode="JT9";
  on_actionWide_Waterfall_triggered();
  connect(m_wideGraph.data (), SIGNAL(setFreq3(int,int)),this,
          SLOT(setFreq4(int,int)));
  m_wideGraph->setLockTxFreq(m_lockTxFreq);
  m_wideGraph->setMode(m_mode);
  m_wideGraph->setModeTx(m_modeTx);

  connect (&m_wav_future_watcher, &QFutureWatcher<void>::finished, this, &MainWindow::diskDat);

  future3 = new QFuture<void>;
  watcher3 = new QFutureWatcher<void>;
  connect(watcher3, SIGNAL(finished()),this,SLOT(fast_decode_done()));
//  Q_EMIT startAudioInputStream (m_config.audio_input_device (), m_framesAudioInputBuffered, &m_detector, m_downSampleFactor, m_config.audio_input_channel ());
  Q_EMIT startAudioInputStream (m_config.audio_input_device (), m_framesAudioInputBuffered, m_detector, m_downSampleFactor, m_config.audio_input_channel ());
  Q_EMIT initializeAudioOutputStream (m_config.audio_output_device (), AudioDevice::Mono == m_config.audio_output_channel () ? 1 : 2, m_msAudioOutputBuffered);
  Q_EMIT transmitFrequency (ui->TxFreqSpinBox->value () - m_XIT);

  enable_DXCC_entity (m_config.DXCC ());  // sets text window proportions and (re)inits the logbook

  ui->label_9->setStyleSheet("QLabel{background-color: #aabec8}");
  ui->label_10->setStyleSheet("QLabel{background-color: #aabec8}");

  // this must be done before initializing the mode as some modes need
  // to turn off split om the rig e.g. WSPR
  m_config.transceiver_online (true);

  bool b=m_config.enable_VHF_features() and (m_mode=="JT4" or m_mode=="JT65" or
                                             m_mode=="ISCAT" or m_mode=="JT9" or
                                             m_mode=="JTMSK");
  VHF_controls_visible(b);

  if(m_mode=="JT4") on_actionJT4_triggered();
  if(m_mode=="JT9") on_actionJT9_triggered();
  if(m_mode=="JT65") on_actionJT65_triggered();
  if(m_mode=="JT9+JT65") on_actionJT9_JT65_triggered();
  if(m_mode=="WSPR-2") on_actionWSPR_2_triggered();
  if(m_mode=="WSPR-15") on_actionWSPR_15_triggered();
  if(m_mode=="Echo") on_actionEcho_triggered();
  if(m_mode=="ISCAT") on_actionISCAT_triggered();
  if(m_mode=="JTMSK") on_actionJTMSK_triggered();

  // this can only be done after mode is initialized otherwise split
  // on rig may be incorrect selected
  on_monitorButton_clicked (!m_config.monitor_off_at_startup ());
  if(m_mode=="Echo") monitor(false); //Don't auto-start Monitor in Echo mode.

  m_ntx=1;
  ui->txrb1->setChecked(true);

  if(m_mode.mid(0,4)=="WSPR" and m_pctx>0)  {
    QPalette palette {ui->sbTxPercent->palette ()};
    palette.setColor(QPalette::Base,Qt::yellow);
    ui->sbTxPercent->setPalette(palette);
  }
  if(m_mode=="WSPR-2") {
    m_hsymStop=396;
  } else if(m_mode=="WSPR-15") {
    m_hsymStop=3090;
  } else if(m_mode=="Echo") {
    m_hsymStop=10;
  } else {
    m_hsymStop=173;
    if(m_config.decode_at_52s()) m_hsymStop=179;
  }
  progressBar->setMaximum(m_TRperiod);
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_dialFreqRxWSPR=0;
  wsprNet = new WSPRNet(network_manager, this);
  connect( wsprNet, SIGNAL(uploadStatus(QString)), this, SLOT(uploadResponse(QString)));
  if(m_bFastMode) {
    int ntr[]={5,10,15,30};
    m_TRperiod=ntr[m_TRindex-11];
  }
}

//--------------------------------------------------- MainWindow destructor
MainWindow::~MainWindow()
{
  QString fname {QDir::toNativeSeparators(m_dataDir.absoluteFilePath ("wsjtx_wisdom.dat"))};
  QByteArray cfname=fname.toLocal8Bit();
  fftwf_export_wisdom_to_filename(cfname);
  m_audioThread.quit ();
  m_audioThread.wait ();
  delete ui, ui = 0;
}

//-------------------------------------------------------- writeSettings()
void MainWindow::writeSettings()
{
  m_settings->beginGroup("MainWindow");
  m_settings->setValue ("geometry", saveGeometry ());
  m_settings->setValue ("state", saveState ());
  m_settings->setValue("MRUdir", m_path);
  m_settings->setValue("TxFirst",m_txFirst);
  m_settings->setValue("DXcall",ui->dxCallEntry->text());
  m_settings->setValue("DXgrid",ui->dxGridEntry->text());
  m_settings->setValue ("AstroDisplayed", m_astroWidget && m_astroWidget->isVisible());
  m_settings->setValue ("MsgAvgDisplayed", m_msgAvgWidget && m_msgAvgWidget->isVisible());
  m_settings->setValue ("FreeText", ui->freeTextMsg->currentText ());
  m_settings->endGroup();

  m_settings->beginGroup("Common");
  m_settings->setValue("Mode",m_mode);
  m_settings->setValue("ModeTx",m_modeTx);
  m_settings->setValue("SaveNone",ui->actionNone->isChecked());
  m_settings->setValue("SaveDecoded",ui->actionSave_decoded->isChecked());
  m_settings->setValue("SaveAll",ui->actionSave_all->isChecked());
  m_settings->setValue("NDepth",m_ndepth);
  m_settings->setValue("RxFreq",ui->RxFreqSpinBox->value());
  m_settings->setValue("TxFreq",ui->TxFreqSpinBox->value());
  m_settings->setValue("WSPRfreq",ui->WSPRfreqSpinBox->value());
  m_settings->setValue("TRindex",ui->sbTR->value());
  m_settings->setValue("SubMode",ui->sbSubmode->value());
  m_settings->setValue("DTtol",m_DTtol);
  m_settings->setValue("FtolIndex",m_FtolIndex);
  m_settings->setValue("MinSync",m_minSync);
  m_settings->setValue("EME",m_bEME);
  m_settings->setValue ("DialFreq", QVariant::fromValue(m_lastMonitoredFrequency));
  m_settings->setValue("InGain",m_inGain);
  m_settings->setValue("OutAttenuation", ui->outAttenuation->value ());
  m_settings->setValue("NoSuffix",m_noSuffix);
  m_settings->setValue("GUItab",ui->tabWidget->currentIndex());
  m_settings->setValue("OutBufSize",outBufSize);
  m_settings->setValue("LockTxFreq",m_lockTxFreq);
  m_settings->setValue("PctTx",m_pctx);
  m_settings->setValue("dBm",m_dBm);
  m_settings->setValue("UploadSpots",m_uploadSpots);
  m_settings->setValue ("BandHopping", ui->band_hopping_group_box->isChecked ());
  m_settings->setValue("TRindex",m_TRindex);
  m_settings->setValue("FastMode",m_bFastMode);
  m_settings->setValue("Fast9",m_bFast9);
  m_settings->setValue("CQRxfreq",m_freqCQ);
  m_settings->setValue("TuneAttenuation",m_tune_attenuation);
  m_settings->endGroup();
}

//---------------------------------------------------------- readSettings()
void MainWindow::readSettings()
{
  m_settings->beginGroup("MainWindow");
  restoreGeometry (m_settings->value ("geometry", saveGeometry ()).toByteArray ());
  restoreState (m_settings->value ("state", saveState ()).toByteArray ());
  ui->dxCallEntry->setText(m_settings->value("DXcall","").toString());
  ui->dxGridEntry->setText(m_settings->value("DXgrid","").toString());
  m_path = m_settings->value("MRUdir", m_config.save_directory ().absolutePath ()).toString ();
  m_txFirst = m_settings->value("TxFirst",false).toBool();
  ui->txFirstCheckBox->setChecked(m_txFirst);
  auto displayAstro = m_settings->value ("AstroDisplayed", false).toBool ();
  auto displayMsgAvg = m_settings->value ("MsgAvgDisplayed", false).toBool ();
  if (m_settings->contains ("FreeText")) ui->freeTextMsg->setCurrentText (
        m_settings->value ("FreeText").toString ());
  m_settings->endGroup();

  // do this outside of settings group because it uses groups internally
  if (displayAstro) on_actionAstronomical_data_triggered ();
  if (displayMsgAvg) on_actionMessage_averaging_triggered();

  m_settings->beginGroup("Common");
  morse_(const_cast<char *> (m_config.my_callsign ().toLatin1().constData()),
         const_cast<int *> (icw), &m_ncw, m_config.my_callsign ().length());
  m_mode=m_settings->value("Mode","JT9").toString();
  m_modeTx=m_settings->value("ModeTx","JT9").toString();
  if(m_modeTx.mid(0,3)=="JT9") ui->pbTxMode->setText("Tx JT9  @");
  if(m_modeTx=="JT65") ui->pbTxMode->setText("Tx JT65  #");
  ui->actionNone->setChecked(m_settings->value("SaveNone",true).toBool());
  ui->actionSave_decoded->setChecked(m_settings->value("SaveDecoded",false).toBool());
  ui->actionSave_all->setChecked(m_settings->value("SaveAll",false).toBool());
  ui->RxFreqSpinBox->setValue(0); // ensure a change is signaled
  ui->RxFreqSpinBox->setValue(m_settings->value("RxFreq",1500).toInt());
  m_nSubMode=m_settings->value("SubMode",0).toInt();
  ui->sbSubmode->setValue(m_nSubMode);
  m_FtolIndex=m_settings->value("FtolIndex",21).toInt();
  ui->sbFtol->setValue(m_FtolIndex);
  on_sbFtol_valueChanged(m_FtolIndex);
//  ui->FTol_combo_box->setCurrentText(m_settings->value("FTol","500").toString ());
  ui->syncSpinBox->setValue(m_settings->value("MinSync",0).toInt());
  m_bEME=m_settings->value("EME",false).toBool();
  ui->cbEME->setChecked(m_bEME);
  m_TRindex=m_settings->value("TRindex",0).toInt();
  ui->sbTR->setValue(m_TRindex);
  m_bFast9=m_settings->value("Fast9",false).toBool();
  ui->cbFast9->setChecked(m_bFast9);
  m_bFastMode=m_settings->value("FastMode",false).toBool();
  if(m_bFast9) m_bFastMode=true;
  m_lastMonitoredFrequency = m_settings->value ("DialFreq",
     QVariant::fromValue<Frequency> (default_frequency)).value<Frequency> ();
  ui->WSPRfreqSpinBox->setValue(0); // ensure a change is signaled
  ui->WSPRfreqSpinBox->setValue(m_settings->value("WSPRfreq",1500).toInt());
  ui->TxFreqSpinBox->setValue(0); // ensure a change is signaled
  ui->TxFreqSpinBox->setValue(m_settings->value("TxFreq",1500).toInt());
  Q_EMIT transmitFrequency (ui->TxFreqSpinBox->value () - m_XIT);
  m_saveDecoded=ui->actionSave_decoded->isChecked();
  m_saveAll=ui->actionSave_all->isChecked();
  m_ndepth=m_settings->value("NDepth",3).toInt();
  m_inGain=m_settings->value("InGain",0).toInt();
  ui->inGain->setValue(m_inGain);
  m_pctx=m_settings->value("PctTx",20).toInt();
  ui->sbTxPercent->setValue(m_pctx);
  m_dBm=m_settings->value("dBm",37).toInt();
  ui->TxPowerComboBox->setCurrentIndex(int(0.3*(m_dBm + 30.0)+0.2));
  m_uploadSpots=m_settings->value("UploadSpots",false).toBool();
  ui->cbUploadWSPR_Spots->setChecked(m_uploadSpots);
  if(!m_uploadSpots) ui->cbUploadWSPR_Spots->setStyleSheet("QCheckBox{background-color: yellow}");
  ui->band_hopping_group_box->setChecked (m_settings->value ("BandHopping", false).toBool());
  // setup initial value of tx attenuator
  ui->outAttenuation->setValue (m_settings->value ("OutAttenuation", 0).toInt ());
  m_tune_attenuation = m_settings->value ("TuneAttenuation", 0).toInt ();
  on_outAttenuation_valueChanged (ui->outAttenuation->value ());
  m_freqCQ=m_settings->value("CQRxFreq",285).toInt();
  ui->sbCQRxFreq->setValue(m_freqCQ);
  m_noSuffix=m_settings->value("NoSuffix",false).toBool();
  int n=m_settings->value("GUItab",0).toInt();
  ui->tabWidget->setCurrentIndex(n);
  outBufSize=m_settings->value("OutBufSize",4096).toInt();
  m_lockTxFreq=m_settings->value("LockTxFreq",false).toBool();
  ui->cbTxLock->setChecked(m_lockTxFreq);
  m_TRindex=m_settings->value("TRindex",4).toInt();
  m_settings->endGroup();

  // use these initialisation settings to tune the audio o/p buffer
  // size and audio thread priority
  m_settings->beginGroup ("Tune");
  m_msAudioOutputBuffered = m_settings->value ("Audio/OutputBufferMs").toInt ();
  m_framesAudioInputBuffered = m_settings->value ("Audio/InputBufferFrames", RX_SAMPLE_RATE / 10).toInt ();
  m_audioThreadPriority = static_cast<QThread::Priority> (m_settings->value ("Audio/ThreadPriority", QThread::HighPriority).toInt () % 8);
  m_settings->endGroup ();

  if(m_ndepth==1) ui->actionQuickDecode->setChecked(true);
  if(m_ndepth==2) ui->actionMediumDecode->setChecked(true);
  if(m_ndepth==3) ui->actionDeepestDecode->setChecked(true);
  if(m_ndepth==4) ui->actionInclude_averaging->setChecked(true);
  if(m_ndepth==5) ui->actionInclude_correlation->setChecked(true);

  statusChanged();
}

void MainWindow::setDecodedTextFont (QFont const& font)
{
  ui->decodedTextBrowser->setContentFont (font);
  ui->decodedTextBrowser2->setContentFont (font);
  auto style_sheet = "QLabel {" + font_as_stylesheet (font) + '}';
  ui->decodedTextLabel->setStyleSheet (ui->decodedTextLabel->styleSheet () + style_sheet);
  ui->decodedTextLabel2->setStyleSheet (ui->decodedTextLabel2->styleSheet () + style_sheet);
  updateGeometry ();
}

//-------------------------------------------------------------- dataSink()
void MainWindow::dataSink(qint64 frames)
{
  static float s[NSMAX];
  static int ihsym=0;
  static int nzap=0;
  static int trmin;
  static int npts8;
  static float px=0.0;
  static float df3;

  if(m_diskData) {
    dec_data.params.ndiskdat=1;
  } else {
    dec_data.params.ndiskdat=0;
  }

  if(m_mode=="ISCAT" or m_mode=="JTMSK" or m_bFast9) {
    fastSink(frames);
//    return;
  }

  // Get power, spectrum, and ihsym
  trmin=m_TRperiod/60;
//  int k (frames - 1);
  int k (frames);
  dec_data.params.nfa=m_wideGraph->nStartFreq();
  dec_data.params.nfb=m_wideGraph->Fmax();
  int nsps=m_nsps;
  if(m_bFastMode) nsps=6912;
  int nsmo=m_wideGraph->smoothYellow()-1;
  symspec_(&dec_data,&k,&trmin,&nsps,&m_inGain,&nsmo,&px,s,&df3,&ihsym,&npts8);
  if(m_mode=="WSPR-2") wspr_downsample_(dec_data.d2,&k);
  if(ihsym <=0) return;
  QString t;
  m_pctZap=nzap*100.0/m_nsps;
  t.sprintf(" Rx noise: %5.1f ",px);
  ui->signal_meter_widget->setValue(px); // Update thermometer
  if(m_monitoring || m_diskData) {
    m_wideGraph->dataSink2(s,df3,ihsym,m_diskData);
  }

  if(m_mode=="WSPR-2") {
    m_hsymStop=396;
  } else if(m_mode=="WSPR-15") {
    m_hsymStop=3090;
  } else if(m_mode=="Echo") {
    m_hsymStop=10;
  } else {
    m_hsymStop=173;
    if(m_config.decode_at_52s()) m_hsymStop=179;
  }

  if(ihsym==3*m_hsymStop/4) {
    m_dialFreqRxWSPR=m_dialFreq;
  }

  if(ihsym == m_hsymStop) {
    if(m_mode=="Echo") {
      float snr=0;
      int nfrit=0;
      int nqual=0;
      float f1=1500.0;
      float xlevel=0.0;
      float sigdb=0.0;
      float dfreq=0.0;
      float width=0.0;
      echocom_.nclearave=m_nclearave;
      int nDop=0;
      avecho_(dec_data.d2,&nDop,&nfrit,&nqual,&f1,&xlevel,&sigdb,
          &snr,&dfreq,&width);
      QString t;
      t.sprintf("%3d %7.1f %7.1f %7.1f %7.1f %3d",echocom_.nsum,xlevel,sigdb,
                dfreq,width,nqual);
      t=QDateTime::currentDateTimeUtc().toString("hh:mm:ss  ") + t;
      ui->decodedTextBrowser->appendText(t);
      if(m_echoGraph->isVisible()) m_echoGraph->plotSpec();
      m_nclearave=0;
//Don't restart Monitor after an Echo transmission
      if(m_bEchoTxed and !m_auto) {
        monitor(false);
        m_bEchoTxed=false;
      }
      return;
    }
    if( m_dialFreqRxWSPR==0) m_dialFreqRxWSPR=m_dialFreq;
    m_dataAvailable=true;
    dec_data.params.npts8=(ihsym*m_nsps)/16;
    dec_data.params.newdat=1;
    dec_data.params.nagain=0;
    dec_data.params.nzhsym=m_hsymStop;
    QDateTime t = QDateTime::currentDateTimeUtc();
    m_dateTime=t.toString("yyyy-MMM-dd hh:mm");
    if(m_mode.mid(0,4)!="WSPR") decode();                            //Start decoder

    if(!m_diskData) {                        //Always save; may delete later
      int ihr=t.time().toString("hh").toInt();
      int imin=t.time().toString("mm").toInt();
      imin=imin - (imin%(m_TRperiod/60));
      QString t2;
      t2.sprintf("%2.2d%2.2d",ihr,imin);
      m_fileToSave.clear ();
      m_fname = m_config.save_directory ().absoluteFilePath (t.date().toString("yyMMdd") + "_" + t2);
      // the following is potential a threading hazard - not a good
      // idea to pass pointer to be processed in another thread
      QtConcurrent::run(this, &MainWindow::save_wave_file, m_fname + ".wav", &dec_data.d2[0], m_TRperiod);

      if (m_mode.mid (0,4) == "WSPR") {
        m_c2name = m_fname + ".c2";
        int len1=m_c2name.length();
        char c2name[80];
        strcpy(c2name,m_c2name.toLatin1());
        int nsec=120;
        int nbfo=1500;
        double f0m1500=m_dialFreq/1000000.0 + nbfo - 1500;
        savec2_(c2name,&nsec,&f0m1500,len1);
      }
    }

    if(m_mode.mid(0,4)=="WSPR") {
      QString t2,cmnd;
      double f0m1500=m_dialFreqRxWSPR/1000000.0;   // + 0.000001*(m_BFO - 1500);
      t2.sprintf(" -f %.6f ",f0m1500);

      if(m_diskData) {
//      cmnd='"' + m_appDir + '"' + "/wsprd " + m_path;
        cmnd='"' + m_appDir + '"' + "/wsprd -a \"" +
            QDir::toNativeSeparators(m_dataDir.absolutePath()) + "\" \"" + m_path + "\"";
//      if(m_TRseconds==900) cmnd='"' + m_appDir + '"' + "/wsprd -m 15" + t2 +
//          m_path + '"';
      } else {
        cmnd='"' + m_appDir + '"' + "/wsprd -a \"" +
            QDir::toNativeSeparators(m_dataDir.absolutePath()) + "\" " +
            t2 + '"' + m_fname + ".wav\"";
      }
      QString t3=cmnd;
      int i1=cmnd.indexOf("/wsprd ");
      cmnd=t3.mid(0,i1+7) + t3.mid(i1+7);
      ui->DecodeButton->setChecked (true);
      p1.start(QDir::toNativeSeparators(cmnd));
      m_messageClient->status_update (m_dialFreq, m_mode, m_hisCall,
                                      QString::number (ui->rptSpinBox->value ()),
                                      m_modeTx, ui->autoButton->isChecked (),
                                      m_transmitting, (m_decoderBusy = true));
    }
    m_rxDone=true;
  }
}

void MainWindow::save_wave_file (QString const& name, short const * data, int seconds) const
{
  QAudioFormat format;
  format.setCodec ("audio/pcm");
  format.setSampleRate (12000);
  format.setChannelCount (1);
  format.setSampleSize (16);
  format.setSampleType (QAudioFormat::SignedInt);
  auto source = QString {"%1, %2"}.arg (m_config.my_callsign ()).arg (m_config.my_grid ());
  auto comment = QString {"Mode=%1%2, Freq=%3%4"}
     .arg (m_mode)
     .arg (QString {m_mode.contains ('J') && !m_mode.contains ('+')
           ? QString {", Sub Mode="} + QChar {'A' + m_nSubMode}
         : QString {}})
     .arg (Radio::frequency_MHz_string (m_dialFreq))
     .arg (QString {!m_mode.contains ("WSPR") ? QString {", DXCall=%1, DXGrid=%2"}
         .arg (m_hisCall)
         .arg (m_hisGrid).toLocal8Bit () : ""});
  BWFFile::InfoDictionary list_info {
      {{{'I','S','R','C'}}, source.toLocal8Bit ()},
      {{{'I','S','F','T'}}, program_title (revision ()).simplified ().toLocal8Bit ()},
      {{{'I','C','R','D'}}, QDateTime::currentDateTime ()
                          .toString ("yyyy-MM-ddTHH:mm:ss.zzzZ").toLocal8Bit ()},
      {{{'I','C','M','T'}}, comment.toLocal8Bit ()},
  };
  BWFFile wav {format, name, list_info};
  wav.open (BWFFile::WriteOnly);
  wav.write (reinterpret_cast<char const *> (data), sizeof (short) * seconds * format.sampleRate ());
}

//-------------------------------------------------------------- fastSink()
void MainWindow::fastSink(qint64 frames)
{
  static float px;
  static bool decodeEarly;
  int k (frames);
  bool decodeNow=false;

  if(m_k0==9999999) {
    memset(fast_green,0,sizeof(float)*703);        //Zero fast_gereen[]
    memset(fast_s2,0,sizeof(float)*703*64);        //Zero fast_s2[]
    m_bFastDecodeCalled=false;
  } else {
    if(k < m_k0) {                                 //New sequence ?
      memcpy(fast_green2,fast_green,4*703);        //Copy fast_green[] to fast_green2[]
      memcpy(fast_s2,fast_s,4*703*64);             //Copy fast_s[] into fast_s2[]
      fast_jh2=fast_jh;
      if(!m_diskData) memset(dec_data.d2,0,2*30*12000);   //Zero the d2[] array
      decodeEarly=false;
      m_bFastDecodeCalled=false;
      QDateTime t=QDateTime::currentDateTimeUtc();     //.addSecs(2-m_TRperiod);
      int ihr=t.toString("hh").toInt();
      int imin=t.toString("mm").toInt();
      int isec=t.toString("ss").toInt();
      isec=isec - isec%m_TRperiod;
      QString t2;
      t2.sprintf("%2.2d%2.2d%2.2d.wav",ihr,imin,isec);
      m_fname = m_config.save_directory().absoluteFilePath(
            t.date().toString("yyMMdd") + "_" + t2);
    }
  }

  hspec_(dec_data.d2, &k, &m_inGain, fast_green, fast_s, &fast_jh);
  px=fast_green[fast_jh] - 5.0;
  QString t;
  t.sprintf(" Rx noise: %5.1f ",px);
  ui->signal_meter_widget->setValue(px); // Update thermometer
  m_fastGraph->plotSpec();

  decodeNow=false;
  m_k0=k;
  if(m_diskData and m_k0 >= dec_data.params.kin-3456) decodeNow=true;
  if(!m_diskData and m_tRemaining<0.35 and !m_bFastDecodeCalled) decodeNow=true;

  if(decodeNow) {
    m_dataAvailable=true;
    m_t0=0.0;
    m_t1=k/12000.0;
    m_kdone=k;
    dec_data.params.newdat=1;
    if(!m_decoderBusy) {
      m_bFastDecodeCalled=true;
      decode();
    }
    if(!m_diskData and (m_saveAll or m_saveDecoded) and m_fname != "" and
       !decodeEarly) {
      // the following is potential a threading hazard - not a good
      // idea to pass pointer to be processed in another thread
      QtConcurrent::run (this, &MainWindow::save_wave_file, m_fname, &dec_data.d2[0], m_TRperiod);
      m_fileToKill=m_fname;
      killFileTimer->start (3*1000*m_TRperiod/4); //Kill 3/4 period from now
    }
    decodeEarly=false;
  }
}

void MainWindow::showSoundInError(const QString& errorMsg)
{QMessageBox::critical(this, tr("Error in SoundInput"), errorMsg);}

void MainWindow::showSoundOutError(const QString& errorMsg)
{QMessageBox::critical(this, tr("Error in SoundOutput"), errorMsg);}

void MainWindow::showStatusMessage(const QString& statusMsg)
{statusBar()->showMessage(statusMsg);}

void MainWindow::on_actionSettings_triggered()               //Setup Dialog
{
  // things that might change that we need know about
  auto callsign = m_config.my_callsign ();

  if (QDialog::Accepted == m_config.exec ())
    {
      if (m_config.my_callsign () != callsign)
        {
          m_baseCall = Radio::base_callsign (m_config.my_callsign ());
          morse_(const_cast<char *> (m_config.my_callsign ().toLatin1().constData())
                 , const_cast<int *> (icw)
                 , &m_ncw
                 , m_config.my_callsign ().length());
        }

      on_dxGridEntry_textChanged (m_hisGrid); // recalculate distances in case of units change
      enable_DXCC_entity (m_config.DXCC ());  // sets text window proportions and (re)inits the logbook

      if(m_config.spot_to_psk_reporter ()) {
        pskSetLocal ();
      }

      if(m_config.restart_audio_input ()) {
        Q_EMIT startAudioInputStream (m_config.audio_input_device (),
                                      m_framesAudioInputBuffered, m_detector,
                                      m_downSampleFactor,
                                      m_config.audio_input_channel ());
      }

      if(m_config.restart_audio_output ()) {
        Q_EMIT initializeAudioOutputStream (m_config.audio_output_device (),
           AudioDevice::Mono == m_config.audio_output_channel () ? 1 : 2,
                                            m_msAudioOutputBuffered);
      }

      auto_tx_label->setText (m_config.quick_call () ? "Auto-Tx-Enable Armed" : "Auto-Tx-Enable Disarmed");
      displayDialFrequency ();
      bool b=m_config.enable_VHF_features() and (m_mode=="JT4" or m_mode=="JT65" or
                              m_mode=="ISCAT" or m_mode=="JT9" or m_mode=="JTMSK");
      VHF_controls_visible(b);
    }

  if(!m_bFastMode) setXIT (ui->TxFreqSpinBox->value ());
  if (m_config.transceiver_online ())
    {
      Q_EMIT m_config.transceiver_frequency (m_dialFreq);
    }
}

void MainWindow::on_monitorButton_clicked (bool checked)
{
  if (!m_transmitting)
    {
      auto prior = m_monitoring;
      monitor (checked);

      if (checked && !prior)
        {
          Frequency operating_frequency {m_dialFreq};
          if (m_config.monitor_last_used ())
            {
              // put rig back where it was when last in control
              operating_frequency = m_lastMonitoredFrequency;
              Q_EMIT m_config.transceiver_frequency (operating_frequency);
            }
          qsy (operating_frequency);
          if (m_config.monitor_last_used ())
            {
              setXIT (ui->TxFreqSpinBox->value ());
            }
        }

//Get Configuration in/out of strict split and mode checking
      Q_EMIT m_config.sync_transceiver (true, checked);
    }
  else
    {
      ui->monitorButton->setChecked (false); // disallow
    }
}

void MainWindow::monitor (bool state)
{
  ui->monitorButton->setChecked (state);
  if (state) {
    m_diskData = false;	// no longer reading WAV files
    if (!m_monitoring) Q_EMIT resumeAudioInputStream ();
  } else {
    Q_EMIT suspendAudioInputStream ();
  }
  m_monitoring = state;
}

void MainWindow::on_actionAbout_triggered()                  //Display "About"
{
  CAboutDlg {this}.exec ();
}

void MainWindow::on_autoButton_clicked (bool checked)
{
  m_auto = checked;
  m_messageClient->status_update (m_dialFreq, m_mode, m_hisCall,
                                  QString::number (ui->rptSpinBox->value ()),
                                  m_modeTx, ui->autoButton->isChecked (),
                                  m_transmitting, m_decoderBusy);
  m_bEchoTxOK=false;
  if(m_auto and (m_mode=="Echo")) {
    m_nclearave=1;
    echocom_.nsum=0;
  }
  if(m_mode.mid(0,4)=="WSPR")  {
    QPalette palette {ui->sbTxPercent->palette ()};
    if(m_auto or m_pctx==0) {
      palette.setColor(QPalette::Base,Qt::white);
    } else {
      palette.setColor(QPalette::Base,Qt::yellow);
    }
    ui->sbTxPercent->setPalette(palette);
  }
}

void MainWindow::auto_tx_mode (bool state)
{
  ui->autoButton->setChecked (state);
  on_autoButton_clicked (state);
}

void MainWindow::keyPressEvent( QKeyEvent *e )                //keyPressEvent
{
  int n;
  switch(e->key())
    {
    case Qt::Key_D:
      if(m_mode != "WSPR-2" && e->modifiers() & Qt::ShiftModifier) {
        if(!m_decoderBusy) {
          dec_data.params.newdat=0;
          dec_data.params.nagain=0;
          decode();
          return;
        }
      }
      break;
    case Qt::Key_F4:
      clearDX ();
      ui->dxCallEntry->setFocus();
      return;
    case Qt::Key_F6:
      if(e->modifiers() & Qt::ShiftModifier) {
        on_actionDecode_remaining_files_in_directory_triggered();
        return;
      }
      break;
    case Qt::Key_F11:
      n=11;
      if(e->modifiers() & Qt::ControlModifier) n+=100;
      bumpFqso(n);
      return;
    case Qt::Key_F12:
      n=12;
      if(e->modifiers() & Qt::ControlModifier) n+=100;
      bumpFqso(n);
      return;
    case Qt::Key_F:
      if(e->modifiers() & Qt::ControlModifier) {
        if(ui->tabWidget->currentIndex()==0) {
          ui->tx5->clearEditText();
          ui->tx5->setFocus();
        } else {
          ui->freeTextMsg->clearEditText();
          ui->freeTextMsg->setFocus();
        }
        return;
      }
      break;
    case Qt::Key_G:
      if(e->modifiers() & Qt::AltModifier) {
        genStdMsgs(m_rpt);
        return;
      }
      break;
    case Qt::Key_H:
      if(e->modifiers() & Qt::AltModifier) {
        on_stopTxButton_clicked();
        return;
      }
      break;
    case Qt::Key_L:
      if(e->modifiers() & Qt::ControlModifier) {
        lookup();
        genStdMsgs(m_rpt);
        return;
      }
      break;
    case Qt::Key_V:
      if(e->modifiers() & Qt::AltModifier) {
        m_fileToSave=m_fname;
        return;
      }
      break;
    }

  QMainWindow::keyPressEvent (e);
}

void MainWindow::bumpFqso(int n)                                 //bumpFqso()
{
  int i;
  bool ctrl = (n>=100);
  n=n%100;
  i=ui->RxFreqSpinBox->value ();
  if(n==11) i--;
  if(n==12) i++;
  if (ui->RxFreqSpinBox->isEnabled ())
    {
      ui->RxFreqSpinBox->setValue (i);
    }
  if(ctrl and m_mode.mid(0,4)=="WSPR") {
    ui->WSPRfreqSpinBox->setValue(i);
  } else {
    if(ctrl && ui->TxFreqSpinBox->isEnabled ()) {
      ui->TxFreqSpinBox->setValue (i);
    }
  }
}

void MainWindow::qsy (Frequency f)
{
  if (!m_transmitting)
    {
      if (m_monitoring)
        {
          m_lastMonitoredFrequency = f;
        }
//      if (m_dialFreq != f)
      if (m_dialFreq != f and (m_mode!="JTMSK" or !ui->cbCQRx->isChecked()))
        {
          m_dialFreq = f;
          m_repeatMsg=0;
          m_secBandChanged=QDateTime::currentMSecsSinceEpoch()/1000;
          if(m_dialFreq/1000000 < 30 and m_mode.mid(0,4)!="WSPR") {
// Write freq changes to ALL.TXT only below 30 MHz.
            QFile f2 {m_dataDir.absoluteFilePath ("ALL.TXT")};
            if (f2.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
              QTextStream out(&f2);
              out << QDateTime::currentDateTimeUtc().toString("yyyy-MMM-dd hh:mm")
                  << "  " << (m_dialFreq / 1.e6) << " MHz  " << m_mode << endl;
              f2.close();
            } else {
              msgBox("Cannot open \"" + f2.fileName () + "\" for append:" + f2.errorString ());
            }
          }

          if (m_config.spot_to_psk_reporter ()) {
            pskSetLocal ();
          }
          displayDialFrequency ();
          statusChanged();
          m_wideGraph->setDialFreq(m_dialFreq / 1.e6);
        }
    }
}

void MainWindow::displayDialFrequency ()
{
  // lookup band
  auto const& band_name = m_config.bands ()->find (m_dialFreq);
  ui->bandComboBox->setCurrentText (band_name);
  m_wideGraph->setRxBand (band_name);

  // search working frequencies for one we are within 10kHz of (1 Mhz
  // of on VHF and up)
  bool valid {false};
  quint64 min_offset {99999999};
  for (auto const& item : *m_config.frequencies ())
    {
      // we need to do specific checks for above and below here to
      // ensure that we can use unsigned Radio::Frequency since we
      // potentially use the full 64-bit unsigned range.
      auto const& working_frequency = item.frequency_;
      auto const& offset = m_dialFreq > working_frequency ? m_dialFreq - working_frequency : working_frequency - m_dialFreq;
      if (offset < min_offset) {
         m_freqNominal = working_frequency;
         min_offset = offset;
      }
  }
  if (min_offset < 10000u or (m_config.enable_VHF_features() and
                              min_offset < 1000000u)) {
    valid = true;
  }

  update_dynamic_property (ui->labDialFreq, "oob", !valid);
  if(m_dialFreq==18446744073709551615u) {
    ui->labDialFreq->setText (Radio::pretty_frequency_MHz_string (default_frequency));
  } else {
    ui->labDialFreq->setText (Radio::pretty_frequency_MHz_string (m_dialFreq));

  }
}

void MainWindow::statusChanged()
{
  m_messageClient->status_update (m_dialFreq, m_mode, m_hisCall,
                                  QString::number (ui->rptSpinBox->value ()),
                                  m_modeTx, ui->autoButton->isChecked (),
                                  m_transmitting, m_decoderBusy);

  QFile f {m_config.temp_dir ().absoluteFilePath ("wsjtx_status.txt")};
  if(f.open(QFile::WriteOnly | QIODevice::Text)) {
    QTextStream out(&f);
    out << (m_dialFreq / 1.e6) << ";" << m_mode << ";" << m_hisCall << ";"
        << ui->rptSpinBox->value() << ";" << m_modeTx << endl;
    f.close();
  } else {
    msgBox("Cannot open \"" + f.fileName () + "\" for writing:" + f.errorString ());
  }
}

bool MainWindow::eventFilter(QObject *object, QEvent *event)  //eventFilter()
{
  if (event->type() == QEvent::KeyPress) {
    QKeyEvent *keyEvent = static_cast<QKeyEvent *>(event);
    MainWindow::keyPressEvent(keyEvent);
    return QObject::eventFilter(object, event);
  }
  return QObject::eventFilter(object, event);
}

void MainWindow::createStatusBar()                           //createStatusBar
{
  tx_status_label = new QLabel("Receiving");
  tx_status_label->setAlignment(Qt::AlignHCenter);
  tx_status_label->setMinimumSize(QSize(150,18));
  tx_status_label->setStyleSheet("QLabel{background-color: #00ff00}");
  tx_status_label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(tx_status_label);


  mode_label = new QLabel("");
  mode_label->setAlignment(Qt::AlignHCenter);
  mode_label->setMinimumSize(QSize(80,18));
  mode_label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(mode_label);

  last_tx_label = new QLabel("");
  last_tx_label->setAlignment(Qt::AlignHCenter);
  last_tx_label->setMinimumSize(QSize(150,18));
  last_tx_label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(last_tx_label);

  auto_tx_label = new QLabel("");
  auto_tx_label->setAlignment(Qt::AlignHCenter);
  auto_tx_label->setMinimumSize(QSize(150,18));
  auto_tx_label->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(auto_tx_label);

  progressBar = new QProgressBar;
  statusBar()->addWidget(progressBar);
  progressBar->setFormat("%v/%m");
}

void MainWindow::closeEvent(QCloseEvent * e)
{
  m_config.transceiver_offline ();
  writeSettings ();
  m_guiTimer.stop ();
  m_prefixes.reset ();
  m_shortcuts.reset ();
  m_mouseCmnds.reset ();

  killFile ();
  m_killAll=true;
  mem_jt9->detach();
  QFile quitFile {m_config.temp_dir ().absoluteFilePath (".quit")};
  quitFile.open(QIODevice::ReadWrite);
  QFile {m_config.temp_dir ().absoluteFilePath (".lock")}.remove(); // Allow jt9 to terminate
  bool b=proc_jt9.waitForFinished(1000);
  if(!b) proc_jt9.kill();
  quitFile.remove();

  Q_EMIT finished ();

  QMainWindow::closeEvent (e);
}

void MainWindow::on_stopButton_clicked()                       //stopButton
{
  monitor (false);
  m_loopall=false;  
}

void MainWindow::msgBox(QString t)                             //msgBox
{
  msgBox0.setText(t);
  msgBox0.exec();
}

void MainWindow::on_actionOnline_User_Guide_triggered()      //Display manual
{
#if defined (CMAKE_BUILD)
  m_manual.display_html_url (QUrl {PROJECT_MANUAL_DIRECTORY_URL}, PROJECT_MANUAL);
#endif
}

//Display local copy of manual
void MainWindow::on_actionLocal_User_Guide_triggered()
{
#if defined (CMAKE_BUILD)
  m_manual.display_html_file (m_config.doc_dir (), PROJECT_MANUAL);
#endif
}

void MainWindow::on_actionWide_Waterfall_triggered()      //Display Waterfalls
{
  m_wideGraph->show();
}

void MainWindow::on_actionEcho_Graph_triggered()
{
  m_echoGraph->show();
}

void MainWindow::on_actionFast_Graph_triggered()
{
  m_fastGraph->show();
}

void MainWindow::on_actionAstronomical_data_triggered()
{
  if (!m_astroWidget)
    {
      m_astroWidget.reset (new Astro {m_settings, &m_config});

      // hook up termination signal
      connect (this, &MainWindow::finished, m_astroWidget.data (), &Astro::close);
      connect (m_astroWidget.data (), &Astro::doppler_tracking_toggled
               , this, &MainWindow::DopplerTracking_toggled);
    }
  m_astroWidget->showNormal();
  m_astroWidget->raise ();
  m_astroWidget->activateWindow ();
}

void MainWindow::on_actionMessage_averaging_triggered()
{
  if (!m_msgAvgWidget)
    {
      m_msgAvgWidget.reset (new MessageAveraging {m_settings});

      // Connect signals from Message Averaging window
      connect (this, &MainWindow::finished, m_msgAvgWidget.data (), &MessageAveraging::close);
    }
  m_msgAvgWidget->showNormal();
  m_msgAvgWidget->raise ();
  m_msgAvgWidget->activateWindow ();
}

void MainWindow::on_actionOpen_triggered()                     //Open File
{
  monitor (false);

  QString fname;
  fname=QFileDialog::getOpenFileName(this, "Open File", m_path,
                                     "WSJT Files (*.wav)");
  if(!fname.isEmpty ()) {
    m_path=fname;
    int i1=fname.lastIndexOf("/");
    QString baseName=fname.mid(i1+1);
    tx_status_label->setStyleSheet("QLabel{background-color: #99ffff}");
    tx_status_label->setText(" " + baseName + " ");
    on_stopButton_clicked();
    m_diskData=true;
    read_wav_file (fname);
  }
}

void MainWindow::read_wav_file (QString const& fname)
{
  m_wav_future = QtConcurrent::run ([this, fname] {
      auto basename = fname.mid (fname.lastIndexOf ('/') + 1);
      auto pos = fname.indexOf (".wav", 0, Qt::CaseInsensitive);
      // global variables and threads do not mix well, this needs changing
      dec_data.params.nutc = 0;
      if (pos > 0)
        {
          if (pos == fname.indexOf ('_', -11) + 7)
            {
              dec_data.params.nutc = fname.mid (pos - 6, 6).toInt ();
            }
          else
            {
              dec_data.params.nutc = 100 * fname.mid (pos - 4, 4).toInt ();
            }
        }
      BWFFile file {QAudioFormat {}, fname};
      file.open (BWFFile::ReadOnly);
      auto ntps = std::min (m_TRperiod * 12000, 120 * 12000);
      auto bytes_per_frame = file.format ().bytesPerFrame ();
      int n = file.read (reinterpret_cast<char *> (dec_data.d2),
                         std::min (qint64 (bytes_per_frame * ntps), file.size ()));
      std::memset (dec_data.d2 + n, 0, bytes_per_frame * ntps - n);
      if (11025 == file.format ().sampleRate ())
        {
          auto sample_size = static_cast<short > (file.format ().sampleSize ());
          wav12_ (dec_data.d2, dec_data.d2, &n, &sample_size);
        }
      dec_data.params.kin = n;
      dec_data.params.newdat = 1;
    });
  m_wav_future_watcher.setFuture(m_wav_future); // call diskDat() when done
}

void MainWindow::on_actionOpen_next_in_directory_triggered()   //Open Next
{
  monitor (false);

  int i,len;
  QFileInfo fi(m_path);
  QStringList list;
  list= fi.dir().entryList().filter(".wav",Qt::CaseInsensitive);
  for (i = 0; i < list.size()-1; ++i) {
    if(i==list.size()-2) m_loopall=false;
    len=list.at(i).length();
    if(list.at(i)==m_path.right(len)) {
      int n=m_path.length();
      QString fname=m_path.replace(n-len,len,list.at(i+1));
      m_path=fname;
      int i1=fname.lastIndexOf("/");
      QString baseName=fname.mid(i1+1);
      tx_status_label->setStyleSheet("QLabel{background-color: #99ffff}");
      tx_status_label->setText(" " + baseName + " ");
      m_diskData=true;
      read_wav_file (fname);
      return;
    }
  }
}
//Open all remaining files
void MainWindow::on_actionDecode_remaining_files_in_directory_triggered()
{
  m_loopall=true;
  on_actionOpen_next_in_directory_triggered();
}

void MainWindow::diskDat()                                   //diskDat()
{
  int k;
//  int kstep=m_nsps/2;
  int kstep=3456;
  m_diskData=true;

  float db=m_config.degrade();
  if(db > 0.0) degrade_snr_(dec_data.d2,&dec_data.params.kin,&db);

  for(int n=1; n<=m_hsymStop; n++) {                      // Do the waterfall spectra
    k=(n+1)*kstep;
    if(k > dec_data.params.kin) break;
    dec_data.params.npts8=k/8;
    dataSink(k);
    qApp->processEvents();                                //Update the waterfall
  }
}

//Delete ../save/*.wav
void MainWindow::on_actionDelete_all_wav_files_in_SaveDir_triggered()
{
  if (QMessageBox::Yes == QMessageBox::warning(this, "Confirm Delete",
                                              "Are you sure you want to delete all *.wav and *.c2 files in\n" +
                                              QDir::toNativeSeparators(m_config.save_directory ().absolutePath ()) + " ?",
                                               QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes)) {
    Q_FOREACH (auto const& file
               , m_config.save_directory ().entryList ({"*.wav", "*.c2"}, QDir::Files | QDir::Writable)) {
      m_config.save_directory ().remove (file);
    }
  }
}

void MainWindow::on_actionNone_triggered()                    //Save None
{
  m_saveDecoded=false;
  m_saveAll=false;
  ui->actionNone->setChecked(true);
}

void MainWindow::on_actionSave_decoded_triggered()
{
  m_saveDecoded=true;
  m_saveAll=false;
  ui->actionSave_decoded->setChecked(true);
}

void MainWindow::on_actionSave_all_triggered()                //Save All
{
  m_saveDecoded=false;
  m_saveAll=true;
  ui->actionSave_all->setChecked(true);
}

void MainWindow::on_actionKeyboard_shortcuts_triggered()
{
  if (!m_shortcuts)
    {
      QFont font;
      font.setPointSize (10);
      m_shortcuts.reset (new HelpTextWindow {tr ("Keyboard Shortcuts")
            , ":/shortcuts.txt", font});
    }
  m_shortcuts->showNormal ();
  m_shortcuts->raise ();
}

void MainWindow::on_actionSpecial_mouse_commands_triggered()
{
  if (!m_mouseCmnds)
    {
      QFont font;
      font.setPointSize (10);
      m_mouseCmnds.reset (new HelpTextWindow {tr ("Special Mouse Commands")
            , ":/mouse_commands.txt", font});
    }
  m_mouseCmnds->showNormal ();
  m_mouseCmnds->raise ();
}

void MainWindow::on_DecodeButton_clicked (bool /* checked */)	//Decode request
{
  if(m_mode != "WSPR-2" && !m_decoderBusy) {
    dec_data.params.newdat=0;
    dec_data.params.nagain=1;
    m_blankLine=false; // don't insert the separator again
    decode();
  }
}

void MainWindow::freezeDecode(int n)                          //freezeDecode()
{
  if((n%100)==2) on_DecodeButton_clicked (true);
}

void MainWindow::on_ClrAvgButton_clicked()
{
  m_nclearave=1;
  if(m_msgAvgWidget != NULL) {
    if(m_msgAvgWidget->isVisible()) m_msgAvgWidget->displayAvg("");
  }
}

void MainWindow::msgAvgDecode2()
{
  on_DecodeButton_clicked (true);
}

void MainWindow::decode()                                       //decode()
{
  if(!m_dataAvailable or m_TRperiod==0) return;
  ui->DecodeButton->setChecked (true);
  if(m_diskData and !m_bFastMode) dec_data.params.nutc=dec_data.params.nutc/100;
  if(dec_data.params.newdat==1 && (!m_diskData)) {
    qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
    int imin=ms/60000;
    int ihr=imin/60;
    imin=imin % 60;
    if(m_TRperiod>=60) imin=imin - (imin % (m_TRperiod/60));
    dec_data.params.nutc=100*ihr + imin;
    if(m_mode=="ISCAT" or m_bFast9) {

      QDateTime t=QDateTime::currentDateTimeUtc().addSecs(2-m_TRperiod);
      ihr=t.toString("hh").toInt();
      imin=t.toString("mm").toInt();
      int isec=t.toString("ss").toInt();
      isec=isec - isec%m_TRperiod;
      dec_data.params.nutc=10000*ihr + 100*imin + isec;
    }
  }

  dec_data.params.nfqso=m_wideGraph->rxFreq();
  dec_data.params.ndepth=m_ndepth;
  dec_data.params.n2pass=1;
  if(m_config.twoPass()) dec_data.params.n2pass=2;
  dec_data.params.nranera=m_config.ntrials();
  dec_data.params.naggressive=m_config.aggressive();
  dec_data.params.nrobust=0;
  if(m_config.sync1Bit()) dec_data.params.nrobust=1;
  dec_data.params.ndiskdat=0;
  if(m_diskData) dec_data.params.ndiskdat=1;
  dec_data.params.nfa=m_wideGraph->nStartFreq();
  dec_data.params.nfSplit=m_wideGraph->Fmin();
  dec_data.params.nfb=m_wideGraph->Fmax();
  dec_data.params.ntol=m_Ftol;
  if(m_mode=="JT9+JT65") {
    dec_data.params.ntol=20;
    dec_data.params.naggressive=0;
  }
  if(dec_data.params.nutc < m_nutc0) m_RxLog = 1;       //Date and Time to all.txt
  m_nutc0=dec_data.params.nutc;
  dec_data.params.ntxmode=9;
  if(m_modeTx=="JT65") dec_data.params.ntxmode=65;
  dec_data.params.nmode=9;
  if(m_mode=="JT65") dec_data.params.nmode=65;
  if(m_mode=="JT9+JT65") dec_data.params.nmode=9+65;  // = 74
  if(m_mode=="JT4") {
    dec_data.params.nmode=4;
    dec_data.params.ntxmode=4;
  }
  dec_data.params.ntrperiod=m_TRperiod;
  dec_data.params.nsubmode=m_nSubMode;
  dec_data.params.minw=0;
  dec_data.params.nclearave=m_nclearave;
  if(m_nclearave!=0) {
    QFile f(m_config.temp_dir ().absoluteFilePath ("avemsg.txt"));
    f.remove();
  }
  dec_data.params.dttol=m_DTtol;
  dec_data.params.emedelay=0.0;
  if(m_bEME) dec_data.params.emedelay=2.5;
  dec_data.params.minSync=m_minSync;
  dec_data.params.nexp_decode=0;
  if(m_config.MyDx()) dec_data.params.nexp_decode += 1;
  if(m_config.CQMyN()) dec_data.params.nexp_decode += 2;
  if(m_config.NDxG()) dec_data.params.nexp_decode += 4;
  if(m_config.NN()) dec_data.params.nexp_decode += 8;
  if(m_config.EMEonly()) dec_data.params.nexp_decode += 16;

  strncpy(dec_data.params.datetime, m_dateTime.toLatin1(), 20);
  strncpy(dec_data.params.mycall, (m_config.my_callsign()+"            ").toLatin1(),12);
  strncpy(dec_data.params.mygrid, (m_config.my_grid()+"      ").toLatin1(),6);
  QString hisCall=ui->dxCallEntry->text().toUpper().trimmed();
  QString hisGrid=ui->dxGridEntry->text().toUpper().trimmed();
  strncpy(dec_data.params.hiscall,(hisCall+"            ").toLatin1(),12);
  strncpy(dec_data.params.hisgrid,(hisGrid+"      ").toLatin1(),6);

  //newdat=1  ==> this is new data, must do the big FFT
  //nagain=1  ==> decode only at fQSO +/- Tol

  char *to = (char*)mem_jt9->data();
  char *from = (char*) dec_data.ss;
  int size=sizeof(struct dec_data);
  if(dec_data.params.newdat==0) {
    int noffset {offsetof (struct dec_data, params.nutc)};
    to += noffset;
    from += noffset;
    size -= noffset;
  }
  if(m_mode=="ISCAT" or m_mode=="JTMSK" or m_bFast9) {
    float t0=m_t0;
    float t1=m_t1;
    qApp->processEvents();                                //Update the waterfall
    if(m_nPick > 0) {
      t0=m_t0Pick;
      t1=m_t1Pick;
      if(t1 > m_kdone/12000.0) t1=m_kdone/12000.0;
    }
    static short int d2b[360000];
    narg[0]=dec_data.params.nutc;
    if(m_kdone>12000*m_TRperiod) {
      m_kdone=12000*m_TRperiod;
    }
    narg[1]=m_kdone;
    narg[2]=m_nSubMode;
    narg[3]=dec_data.params.newdat;
    narg[4]=dec_data.params.minSync;
    narg[5]=m_nPick;
    narg[6]=1000.0*t0;
    narg[7]=1000.0*t1;
    narg[8]=2;                                //Max decode lines per decode attempt
    if(dec_data.params.minSync<0) narg[8]=50;
    if(m_mode=="ISCAT") narg[9]=101;          //ISCAT
    if(m_mode=="JT9") narg[9]=102;            //Fast JT9
    if(m_mode=="JTMSK") narg[9]=103;          //JTMSK
    narg[10]=ui->RxFreqSpinBox->value();
    narg[11]=m_Ftol;
    m_calls="<" + m_config.my_callsign() + " " + hisCall + ">";
    hash_calls_(m_calls.toLatin1().data(), &narg[12], m_calls.length());
    narg[13]=-1;
    memcpy(d2b,dec_data.d2,2*360000);
    *future3 = QtConcurrent::run(fast_decode_,&d2b[0],&narg[0],&m_msg[0][0],80);
    watcher3->setFuture(*future3);
  } else {
    memcpy(to, from, qMin(mem_jt9->size(), size));
    QFile {m_config.temp_dir ().absoluteFilePath (".lock")}.remove (); // Allow jt9 to start
    decodeBusy(true);
  }
}

void::MainWindow::fast_decode_done()
{
  float t,tmax=-99.0;
  QString msg0;
  m_bDecoded=false;
  for(int i=0; i<100; i++) {
    int i1=msg0.indexOf(m_baseCall);
    int i2=msg0.indexOf(m_hisCall);
    if(((m_mode=="JTMSK") or m_bFast9) and m_bEME and tmax>=0.0 and i1>10 and
       i2>i1+3) {     //Here, "m_bEME" implies AutoSeq
      processMessage(msg0,40,false);
    }
    if(m_msg[i][0]==0) break;
    QString message=QString::fromLatin1(m_msg[i]);
    if(narg[13]==narg[12]) message=message.trimmed().replace("<...>",m_calls);

//Left (Band activity) window
    DecodedText decodedtext;
    decodedtext=message.replace("\n","");
    ui->decodedTextBrowser->displayDecodedText (decodedtext,m_baseCall,m_config.DXCC(),
         m_logBook,m_config.color_CQ(),m_config.color_MyCall(),m_config.color_DXCC(),
         m_config.color_NewCall());

    t=message.mid(10,5).toFloat();
    if(t>tmax) {
      msg0=message;
      tmax=t;
      m_bDecoded=true;
    }

// Write decoded text to file "ALL.TXT".
    QFile f {m_dataDir.absoluteFilePath ("ALL.TXT")};
    if (f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
      QTextStream out(&f);
      if(m_RxLog==1) {
        out << QDateTime::currentDateTimeUtc().toString("yyyy-MMM-dd hh:mm")
            << "  " << (m_dialFreq / 1.e6) << " MHz  " << m_mode << endl;
        m_RxLog=0;
      }
      int n=message.length();
      out << message.mid(0,n-2) << endl;
      f.close();
    } else {
      msgBox("Cannot open \"" + f.fileName () + "\" for append:" + f.errorString ());
    }

    if(m_mode=="JT9" or m_mode=="JTMSK") {
      // find and extract any report for myCall
      QString msg=message.mid(0,4) + message.mid(6,-1);
      decodedtext=msg.replace("\n","");
      bool stdMsg = decodedtext.report(m_baseCall,
              Radio::base_callsign(ui->dxCallEntry->text().toUpper().trimmed()), m_rptRcvd);
      // extract details and send to PSKreporter
//      int nsec=QDateTime::currentMSecsSinceEpoch()/1000-m_secBandChanged;

      if(m_config.spot_to_psk_reporter() and stdMsg and !m_diskData) {
        QString msgmode="JT9";
        QString deCall;
        QString grid;
        decodedtext.deCallAndGrid(/*out*/deCall,grid);
        int audioFrequency = decodedtext.frequencyOffset();
        int snr = decodedtext.snr();
        Frequency frequency = m_dialFreq + audioFrequency;
        pskSetLocal();
        if(gridOK(grid))
//          qDebug() << "To PSKreporter:" << deCall << grid << frequency << msgmode << snr;
          psk_Reporter->addRemoteStation(deCall,grid,QString::number(frequency),msgmode,
                  QString::number(snr),QString::number(QDateTime::currentDateTime().toTime_t()));
      }
    }

  }
  m_startAnother=m_loopall;
  m_nPick=0;
  ui->DecodeButton->setChecked (false);
}

void MainWindow::jt9_error (QProcess::ProcessError e)
{
  if(!m_killAll) {
    msgBox("Error starting or running\n" + m_appDir + "/jt9 -s");
    qDebug() << e;                           // silence compiler warning
    exit(1);
  }
}

void MainWindow::readFromStderr()                             //readFromStderr
{
  QByteArray t=proc_jt9.readAllStandardError();
  msgBox(t);
}

void MainWindow::readFromStdout()                             //readFromStdout
{
  while(proc_jt9.canReadLine()) {
    QByteArray t=proc_jt9.readLine();
    bool baveJT4msg=(t.length()>49);
    if(m_mode=="JT4") t=t.mid(0,39) + t.mid(42,t.length()-42);
    if(t.indexOf("<DecodeFinished>") >= 0) {
      m_bDecoded = (t.mid(23,1).toInt()==1);
      if(!m_diskData) killFileTimer->start (3*1000*m_TRperiod/4); //Kill in 45 s
      dec_data.params.nagain=0;
      dec_data.params.ndiskdat=0;
      m_nclearave=0;
      QFile {m_config.temp_dir ().absoluteFilePath (".lock")}.open(QIODevice::ReadWrite);
      ui->DecodeButton->setChecked (false);
      decodeBusy(false);
      m_RxLog=0;
      m_startAnother=m_loopall;
      m_blankLine=true;
      return;
    } else {
      QFile f {m_dataDir.absoluteFilePath ("ALL.TXT")};
      if (f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
        QTextStream out(&f);
        if(m_RxLog==1) {
          out << QDateTime::currentDateTimeUtc().toString("yyyy-MMM-dd hh:mm")
              << "  " << (m_dialFreq / 1.e6) << " MHz  " << m_mode << endl;
          m_RxLog=0;
        }
        int n=t.length();
        out << t.mid(0,n-2) << endl;
        f.close();
      } else {
        msgBox("Cannot open \"" + f.fileName () + "\" for append:" + f.errorString ());
      }

        if (m_config.insert_blank () && m_blankLine)
          {
            QString band;
            if (QDateTime::currentMSecsSinceEpoch() / 1000 - m_secBandChanged > 50)
              {
                band = ' ' + m_config.bands ()->find (m_dialFreq);
              }
            ui->decodedTextBrowser->insertLineSpacer (band.rightJustified  (40, '-'));
            m_blankLine = false;
          }

      DecodedText decodedtext;
      decodedtext = t.replace("\n",""); //t.replace("\n","").mid(0,t.length()-4);

        //Left (Band activity) window
      if(!baveJT4msg) {
        ui->decodedTextBrowser->displayDecodedText (decodedtext
                                                    , m_baseCall
                                                    , m_config.DXCC ()
                                                    , m_logBook
                                                    , m_config.color_CQ()
                                                    , m_config.color_MyCall()
                                                    , m_config.color_DXCC()
                                                    , m_config.color_NewCall());
      }

        //Right (Rx Frequency) window
      if (((abs(decodedtext.frequencyOffset() - m_wideGraph->rxFreq()) <= 10) and
           m_mode!="JT4") or baveJT4msg) {
          // This msg is within 10 hertz of our tuned frequency, or a JT4 avg
        ui->decodedTextBrowser2->displayDecodedText(decodedtext
                                                    , m_baseCall
                                                    , false
                                                    , m_logBook
                                                    , m_config.color_CQ()
                                                    , m_config.color_MyCall()
                                                    , m_config.color_DXCC()
                                                    , m_config.color_NewCall());

        if(m_mode!="JT4") {
          bool b65=decodedtext.isJT65();
          if(b65 and m_modeTx!="JT65") on_pbTxMode_clicked();
          if(!b65 and m_modeTx=="JT65") on_pbTxMode_clicked();
        }
        m_QSOText=decodedtext;
      }

      postDecode (true, decodedtext.string ());

      // find and extract any report for myCall
      bool stdMsg = decodedtext.report(m_baseCall,
          Radio::base_callsign(ui->dxCallEntry->text().toUpper().trimmed()), m_rptRcvd);
      // extract details and send to PSKreporter
      int nsec=QDateTime::currentMSecsSinceEpoch()/1000-m_secBandChanged;
      bool okToPost=(nsec>50);
      if(m_config.spot_to_psk_reporter () and stdMsg and !m_diskData and okToPost) {
        QString msgmode="JT9";
        if (decodedtext.isJT65()) msgmode="JT65";
        QString deCall;
        QString grid;
        decodedtext.deCallAndGrid(/*out*/deCall,grid);
        int audioFrequency = decodedtext.frequencyOffset();
        int snr = decodedtext.snr();
        Frequency frequency = m_dialFreq + audioFrequency;
        pskSetLocal ();
        if(gridOK(grid))
          psk_Reporter->addRemoteStation(deCall,grid,QString::number(frequency),msgmode,
             QString::number(snr),QString::number(QDateTime::currentDateTime().toTime_t()));
      }

      if((m_mode=="JT4" or m_mode=="JT65") and m_msgAvgWidget!=NULL) {
        if(m_msgAvgWidget->isVisible()) {
          QFile f(m_config.temp_dir ().absoluteFilePath ("avemsg.txt"));
          if(f.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream s(&f);
            QString t=s.readAll();
            m_msgAvgWidget->displayAvg(t);
          }
        }
      }
    }
  }
}

void MainWindow::killFile ()
{
  QString f=m_fname;
  if(m_bFastMode) f=m_fileToKill;
  if (!m_fname.isEmpty() &&
      !(m_saveAll || (m_saveDecoded && m_bDecoded) || m_fname == m_fileToSave)) {
    if(m_fname.indexOf(".wav")<0) f+= ".wav";
    QFile f1{f};
    f1.remove();
    if(m_mode.mid(0,4)=="WSPR") {
      QFile f2{m_fname + ".c2"};
      f2.remove();
    }
  }
}

void MainWindow::on_EraseButton_clicked()                          //Erase
{
  qint64 ms=QDateTime::currentMSecsSinceEpoch();
  ui->decodedTextBrowser2->clear();
  if(m_mode.mid(0,4)=="WSPR" or m_mode=="Echo" or m_mode=="ISCAT") {
    ui->decodedTextBrowser->clear();
  } else {
    m_QSOText.clear();
    if((ms-m_msErase)<500) {
      ui->decodedTextBrowser->clear();
      m_messageClient->clear_decodes ();
      QFile f(m_config.temp_dir ().absoluteFilePath ("decoded.txt"));
      if(f.exists()) f.remove();
    }
  }
  m_msErase=ms;
}

void MainWindow::decodeBusy(bool b)                             //decodeBusy()
{
  bool showProgress = false;
  if (b && m_firstDecode < 65 && ("JT65" == m_mode || "JT9+JT65" == m_mode))
    {
      m_firstDecode += 65;
      if ("JT9+JT65" == m_mode) m_firstDecode = 65 + 9;
      showProgress = true;
    }
  if (b && m_firstDecode != 9 && m_firstDecode != 65 + 9 &&
      ("JT9" == m_mode))
    {
      m_firstDecode += 9;
      showProgress = true;
    }
/* ###   Temporarily(?) disable the long-decode progress bar.
  if (showProgress)
    {
      // this sequence is needed to create an indeterminate progress
      // bar
      m_optimizingProgress.setRange (0, 1);
      m_optimizingProgress.setValue (0);
      m_optimizingProgress.setRange (0, 0);
    }
### */
  if (!b)
    {
      m_optimizingProgress.reset ();
    }

  m_decoderBusy=b;
  ui->DecodeButton->setEnabled(!b);
  ui->actionOpen->setEnabled(!b);
  ui->actionOpen_next_in_directory->setEnabled(!b);
  ui->actionDecode_remaining_files_in_directory->setEnabled(!b);

  m_messageClient->status_update (m_dialFreq, m_mode, m_hisCall,
                                  QString::number (ui->rptSpinBox->value ()),
                                  m_modeTx, ui->autoButton->isChecked (),
                                  m_transmitting, m_decoderBusy);
}

//------------------------------------------------------------- //guiUpdate()
void MainWindow::guiUpdate()
{
  static int iptt0=0;
  static bool btxok0=false;
  static char message[29];
  static char msgsent[29];
  static int nsendingsh=0;
  static double onAirFreq0=0.0;
  double txDuration;
  QString rt;

  if(m_TRperiod==0) m_TRperiod=60;
  txDuration=0.0;
  if(m_modeTx=="JT4")  txDuration=1.0 + 207.0*2520/11025.0;   // JT4
  if(m_modeTx=="JT9")  txDuration=1.0 + 85.0*m_nsps/12000.0;  // JT9
  if(m_modeTx=="JT65") txDuration=1.0 + 126*4096/11025.0;     // JT65
  if(m_mode=="WSPR-2") txDuration=2.0 + 162*8192/12000.0;     // WSPR
  if(m_mode=="ISCAT" or m_bFast9) txDuration=m_TRperiod-0.25; // ISCAT, JT9-fast, JTMSK
//###  if(m_mode=="WSPR-15") tx2=...

  double tx1=0.0;
  double tx2=txDuration + + icw[0]*2560.0/48000.0;          //Full length including CW ID
  if(!m_txFirst and m_mode.mid(0,4)!="WSPR") {
    tx1 += m_TRperiod;
    tx2 += m_TRperiod;
  }

  qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
  int nsec=ms/1000;
  double tsec=0.001*ms;
  double t2p=fmod(tsec,2*m_TRperiod);
  m_s6=fmod(tsec,6.0);
  m_nseq = nsec % m_TRperiod;
  m_tRemaining=m_TRperiod - fmod(tsec,double(m_TRperiod));

  if(m_mode=="Echo") {
    txDuration=2.5;
    tx1=0.0;
    tx2=txDuration;
    if(m_auto and m_s6>4.0) m_bEchoTxOK=true;
    if(m_transmitting) m_bEchoTxed=true;
  }

  if(m_mode.mid(0,4)=="WSPR") {
    if(m_nseq==0 and m_ntr==0) {                   //Decide whether to Tx or Rx
      m_tuneup=false;                              //This is not an ATU tuneup
      if(m_pctx==0) m_WSPR_tx_next = false; //Don't transmit if m_pctx=0
      bool btx = m_auto && m_WSPR_tx_next; // To Tx, we need m_auto and
                                // scheduled transmit
      if(m_auto and m_txNext) btx=true;            //TxNext button overrides
      if(m_auto and m_pctx==100) btx=true;         //Always transmit

      if(btx) {
        m_ntr=-1;                          //This says we will have transmitted
        m_txNext=false;
        ui->pbTxNext->setChecked(false);
        m_bTxTime=true;                      //Start a WSPR Tx sequence
      } else {
// This will be a WSPR Rx sequence.
        m_ntr=1;                           //This says we will have received
        m_bTxTime=false;                     //Start a WSPR Rx sequence
      }
    }

  } else {
 // For all modes other than WSPR
    m_bTxTime = (t2p >= tx1) and (t2p < tx2);
    if(m_mode=="Echo") m_bTxTime = m_bTxTime and m_bEchoTxOK;
  }
  if(m_tune) m_bTxTime=true;                 //"Tune" takes precedence

  if(m_transmitting or m_auto or m_tune) {
// Check for "txboth" (testing purposes only)
    QFile f(m_appDir + "/txboth");
    if(f.exists() and
       fmod(tsec,m_TRperiod)<(1.0 + 85.0*m_nsps/12000.0)) m_bTxTime=true;

// Don't transmit another mode in the 30 m WSPR sub-band
    Frequency onAirFreq = m_dialFreq + ui->TxFreqSpinBox->value();
    if ((onAirFreq > 10139900 and onAirFreq < 10140320) and
        m_mode.mid(0,4)!="WSPR") {
      m_bTxTime=false;
//      if (m_tune) stop_tuning ();
      if (m_auto) auto_tx_mode (false);
      if(onAirFreq!=onAirFreq0) {
        onAirFreq0=onAirFreq;
        QString t="Please choose another Tx frequency.\n";
        t+="WSJT-X will not knowingly transmit another\n";
        t+="mode in the WSPR sub-band on 30 m.";
        msgBox(t);
      }
    }

    float fTR=float((nsec%m_TRperiod))/m_TRperiod;
//    if(g_iptt==0 and ((m_bTxTime and fTR<0.4) or m_tune )) {
    if(g_iptt==0 and ((m_bTxTime and fTR<99) or m_tune )) {   //### Allow late starts
      icw[0]=m_ncw;
      g_iptt = 1;
      setXIT (ui->TxFreqSpinBox->value ());         //Ensure correct offset

// If "CQ nnn ..." feature is active, set the proper Tx frequency
      if(m_config.offsetRxFreq() and ui->cbCQRx->isChecked()) {
        if(m_ntx==6) {
          m_dialFreqTx = m_dialFreq0;
        } else {
          int MHz=int(m_dialFreq/1000000);
          m_dialFreqTx=1000000*MHz + 1000*m_freqCQ;
        }

        if (m_monitoring || m_transmitting) {
          if (m_config.transceiver_online ()) {
            if (m_config.split_mode ()) {
            // All conditions are met, reset the transceiver dial frequency:
//            ui->labDialFreq->setText (Radio::pretty_frequency_MHz_string (m_dialFreq));
              Q_EMIT m_config.transceiver_tx_frequency (m_dialFreqTx);
            }
          }
        }
      }

      Q_EMIT m_config.transceiver_ptt (true);       //Assert the PTT
      ptt1Timer->start(200);                        //Sequencer delay
    }
    if(!m_bTxTime and !m_tune) m_btxok=false;       //Time to stop transmitting
  }

  if(m_mode.mid(0,4)=="WSPR" and
     ((m_ntr==1 and m_rxDone) or (m_ntr==-1 and m_nseq>tx2))) {
    if(m_monitoring) {
      m_rxDone=false;
    }
    if(m_transmitting) {
      WSPR_history(m_dialFreq,-1);
      m_bTxTime=false;                        //Time to stop a WSPR transmission
      m_btxok=false;
    }
    else if (m_ntr != -1) {
      WSPR_scheduling ();
      m_ntr=0;                                //This WSPR Rx sequence is complete
    }
  }

  // Calculate Tx tones when needed
  if((g_iptt==1 && iptt0==0) || m_restart) {
//----------------------------------------------------------------------
    QByteArray ba;

    if(m_mode.mid(0,4)=="WSPR") {
      QString sdBm,msg0,msg1,msg2;
      sdBm.sprintf(" %d",m_dBm);
      m_tx=1-m_tx;
      int i2=m_config.my_callsign().indexOf("/");
      if(i2>0 or m_grid6) {
        if(i2<0) {                                                 // "Type 2" WSPR message
          msg1=m_config.my_callsign() + " " + m_config.my_grid().mid(0,4) + sdBm;
        } else {
          msg1=m_config.my_callsign() + sdBm;
        }
        msg0="<" + m_config.my_callsign() + "> " + m_config.my_grid()+ sdBm;
        if(m_tx==0) msg2=msg0;
        if(m_tx==1) msg2=msg1;
      } else {
        msg2=m_config.my_callsign() + " " + m_config.my_grid().mid(0,4) + sdBm; // Normal WSPR message
      }
      ba=msg2.toLatin1();
    } else {
      if(m_ntx == 1) ba=ui->tx1->text().toLocal8Bit();
      if(m_ntx == 2) ba=ui->tx2->text().toLocal8Bit();
      if(m_ntx == 3) ba=ui->tx3->text().toLocal8Bit();
      if(m_ntx == 4) ba=ui->tx4->text().toLocal8Bit();
      if(m_ntx == 5) ba=ui->tx5->currentText().toLocal8Bit();
      if(m_ntx == 6) ba=ui->tx6->text().toLocal8Bit();
      if(m_ntx == 7) ba=ui->genMsg->text().toLocal8Bit();
      if(m_ntx == 8) ba=ui->freeTextMsg->currentText().toLocal8Bit();
    }

    ba2msg(ba,message);
    int ichk=0;
    if (m_lastMessageSent != m_currentMessage
        || m_lastMessageType != m_currentMessageType)
      {
        m_lastMessageSent = m_currentMessage;
        m_lastMessageType = m_currentMessageType;
      }
    m_currentMessageType = 0;
    if(m_tune or m_mode=="Echo") {
      itone[0]=0;
    } else {
      if(m_mode=="ISCAT") {
        int len2=28;
        geniscat_(message, msgsent, const_cast<int *> (itone),len2, len2);
        msgsent[28]=0;
      } else {
        int len1=22;
        if(m_modeTx=="JT4") gen4_(message, &ichk , msgsent, const_cast<int *> (itone),
                                  &m_currentMessageType, len1, len1);
        if(m_modeTx=="JT9") gen9_(message, &ichk, msgsent, const_cast<int *> (itone),
                                  &m_currentMessageType, len1, len1);
        if(m_modeTx=="JT65") gen65_(message, &ichk, msgsent, const_cast<int *> (itone),
                                    &m_currentMessageType, len1, len1);
        if(m_mode.mid(0,4)=="WSPR") genwspr_(message, msgsent, const_cast<int *> (itone),
                                             len1, len1);
        if(m_modeTx=="JTMSK") genmsk_(message, &ichk, msgsent, const_cast<int *> (itone),
                                  &m_currentMessageType, len1, len1);
        msgsent[22]=0;
      }
    }

    m_currentMessage = QString::fromLatin1(msgsent);
    if (m_tune)
      {
        m_currentMessage = "TUNE";
        m_currentMessageType = -1;
      }
    last_tx_label->setText("Last Tx:  " + m_currentMessage);
    if(m_restart) {
      QFile f {m_dataDir.absoluteFilePath ("ALL.TXT")};
      if (f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append))
        {
          QTextStream out(&f);
          out << QDateTime::currentDateTimeUtc().toString("hhmm")
              << "  Transmitting " << (m_dialFreq / 1.e6) << " MHz  " << m_modeTx
              << ":  " << m_currentMessage << endl;
          f.close();
        }
      else
        {
          msgBox("Cannot open \"" + f.fileName () + "\" for append:" + f.errorString ());
        }
      if (m_config.TX_messages ())
        {
          ui->decodedTextBrowser2->displayTransmittedText(m_currentMessage,m_modeTx,
                     ui->TxFreqSpinBox->value(),m_config.color_TxMsg(),m_bFastMode);
        }
    }

    auto t2 = QDateTime::currentDateTimeUtc ().toString ("hhmm");
    icw[0] = 0;
    auto msg_parts = m_currentMessage.split (' ', QString::SkipEmptyParts);
    auto is_73 = message_is_73 (m_currentMessageType, msg_parts);
    m_sentFirst73 = is_73
      && !message_is_73 (m_lastMessageType, m_lastMessageSent.split (' ', QString::SkipEmptyParts));
    if (m_sentFirst73) {
      m_qsoStop=t2;
      if(m_config.id_after_73 () and (!m_bFastMode)) {
        icw[0] = m_ncw;
      }
      if (m_config.prompt_to_log () && !m_tune) {
        logQSOTimer->start (0);
      }
    }
    if (is_73 && m_config.disable_TX_on_73 ()) {
      auto_tx_mode (false);
    }

    if(m_config.id_interval () >0 and (!m_bFastMode)) {
      int nmin=(m_sec0-m_secID)/60;
      if(nmin >= m_config.id_interval ()) {
        icw[0]=m_ncw;
        m_secID=m_sec0;
      }
    }

    if (m_currentMessageType < 6 && msg_parts.length() >= 3
        && (msg_parts[1] == m_config.my_callsign () ||
            msg_parts[1] == m_baseCall))
    {
      int i1;
      bool ok;
      i1 = msg_parts[2].toInt(&ok);
      if(ok and i1>=-50 and i1<50)
      {
        m_rptSent = msg_parts[2];
        m_qsoStart = t2;
      } else {
        if (msg_parts[2].mid (0, 1) == "R")
        {
          i1 = msg_parts[2].mid (1).toInt (&ok);
          if (ok and i1 >= -50 and i1 < 50)
          {
            m_rptSent = msg_parts[2].mid (1);
            m_qsoStart = t2;
          }
        }
      }
    }
    m_restart=false;
//----------------------------------------------------------------------
  } else {
    if (!m_auto && m_sentFirst73)
    {
      m_sentFirst73 = false;
      if (1 == ui->tabWidget->currentIndex())
      {
        ui->genMsg->setText(ui->tx6->text());
        m_ntx=7;
        ui->rbGenMsg->setChecked(true);
      } else {
//JHT 11/29/2015        m_ntx=6;
//        ui->txrb6->setChecked(true);
      }
    }
  }

  if (g_iptt == 1 && iptt0 == 0)
    {
      QString t=QString::fromLatin1(msgsent);
      if(t==m_msgSent0) {
        m_repeatMsg++;
      } else {
        m_repeatMsg=0;
        m_msgSent0=t;
      }
      if(!m_tune) {
        QFile f {m_dataDir.absoluteFilePath ("ALL.TXT")};
        if (f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
          QTextStream out(&f);
          out << QDateTime::currentDateTimeUtc().toString("hhmm")
              << "  Transmitting " << (m_dialFreq / 1.e6) << " MHz  " << m_modeTx
              << ":  " << m_currentMessage << endl;
          f.close();
        } else {
          msgBox("Cannot open \"" + f.fileName () + "\" for append:" +
                 f.errorString ());
        }
      }

      if (m_config.TX_messages () && !m_tune) {
        ui->decodedTextBrowser2->displayTransmittedText(t,m_modeTx,
              ui->TxFreqSpinBox->value(),m_config.color_TxMsg(),m_bFastMode);
      }

      m_transmitting = true;
      transmitDisplay (true);
      m_messageClient->status_update (m_dialFreq, m_mode, m_hisCall,
                                      QString::number (ui->rptSpinBox->value ()),
                                      m_modeTx, ui->autoButton->isChecked (),
                                      m_transmitting, m_decoderBusy);
    }

  if(!m_btxok && btxok0 && g_iptt==1) stopTx();

  if(m_startAnother) {
    m_startAnother=false;
    on_actionOpen_next_in_directory_triggered();
  }

//Once per second:
  if(nsec != m_sec0) {
    if(m_auto and m_mode=="Echo" and m_bEchoTxOK) {
      progressBar->setMaximum(6);
      progressBar->setValue(int(m_s6));
    }

    if(m_mode!="Echo") {
      if(m_monitoring or m_transmitting) {
        progressBar->setMaximum(m_TRperiod);
        int isec=int(fmod(tsec,m_TRperiod));
        progressBar->setValue(isec);
      } else {
        progressBar->setValue(0);
      }
    }

    QDateTime t = QDateTime::currentDateTimeUtc();
    astroCalculations (t, (m_astroWidget && m_astroWidget->doppler_tracking()));
    if(m_transmitting) {
      char s[37];
      sprintf(s,"Tx: %s",msgsent);
      nsendingsh=0;
      if(s[4]==64) nsendingsh=1;
      if(nsendingsh==1) {
        tx_status_label->setStyleSheet("QLabel{background-color: #66ffff}");
      } else if(nsendingsh==-1) {
        tx_status_label->setStyleSheet("QLabel{background-color: #ffccff}");
      } else {
        tx_status_label->setStyleSheet("QLabel{background-color: #ffff33}");
      }
      if(m_tune) {
        tx_status_label->setText("Tx: TUNE");
      } else {
        if(m_mode=="Echo") {
          tx_status_label->setText("Tx: ECHO");
        } else {
          tx_status_label->setText(s);
        }
      }
    } else if(m_monitoring) {
      tx_status_label->setStyleSheet("QLabel{background-color: #00ff00}");
      QString t="Receiving ";
      tx_status_label->setText(t);
      transmitDisplay(false);
    } else if (!m_diskData) {
      tx_status_label->setStyleSheet("");
      tx_status_label->setText("");
    }

    QString utc = t.date().toString("yyyy MMM dd") + "\n " +
      t.time().toString() + " ";
    ui->labUTC->setText(utc);
    if(!m_monitoring and !m_diskData) {
      ui->signal_meter_widget->setValue(0);
    }
    m_sec0=nsec;
  }
  iptt0=g_iptt;
  btxok0=m_btxok;
}               //End of GUIupdate


void MainWindow::startTx2()
{
  if (!m_modulator->isActive ()) { // TODO - not thread safe
    double fSpread=0.0;
    double snr=99.0;
    QString t=ui->tx5->currentText();
    if(t.mid(0,1)=="#") fSpread=t.mid(1,5).toDouble();
    m_modulator->setSpread(fSpread); // TODO - not thread safe
    t=ui->tx6->text();
    if(t.mid(0,1)=="#") snr=t.mid(1,5).toDouble();
    if(snr>0.0 or snr < -50.0) snr=99.0;
    transmit (snr);
    ui->signal_meter_widget->setValue(0);
    if(m_mode=="Echo" and !m_tune) m_bTransmittedEcho=true;

    if(m_mode.mid(0,4)=="WSPR" and !m_tune) {
      if (m_config.TX_messages ()) {
        t = " Transmitting " + m_mode + " ----------------------- " +
          m_config.bands ()->find (m_dialFreq);
        t=WSPR_hhmm(0) + ' ' + t.rightJustified (66, '-');
        ui->decodedTextBrowser->appendText(t);
      }

      QFile f {m_dataDir.absoluteFilePath ("ALL_WSPR.TXT")};
      if (f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
        QTextStream out(&f);
        out << QDateTime::currentDateTimeUtc().toString("yyMMdd hhmm")
            << "  Transmitting " << (m_dialFreq / 1.e6) << " MHz:  "
            << m_currentMessage << "  " + m_mode << endl;
        f.close();
      } else {
        msgBox("Cannot open \"" + f.fileName () + "\" for append:" + f.errorString ());
      }
    }
  }
}

void MainWindow::stopTx()
{
  Q_EMIT endTransmitMessage ();
  m_btxok = false;
  m_transmitting = false;
  g_iptt=0;
  tx_status_label->setStyleSheet("");
  tx_status_label->setText("");
  ptt0Timer->start(200);                       //Sequencer delay
  monitor (true);
  m_messageClient->status_update (m_dialFreq, m_mode, m_hisCall,
                                  QString::number (ui->rptSpinBox->value ()),
                                  m_modeTx, ui->autoButton->isChecked (),
                                  m_transmitting, m_decoderBusy);
}

void MainWindow::stopTx2()
{
  Q_EMIT m_config.transceiver_ptt (false);      //Lower PTT
  if(m_mode=="JT9" and m_bFast9 and ui->cbEME->isChecked() and m_ntx==5 and (m_nTx73>=5)) {
    on_stopTxButton_clicked();
    m_nTx73=0;
  }
  if (m_mode.mid(0,4)!="WSPR" and m_mode!="Echo" and m_config.watchdog() and
      m_repeatMsg>=m_watchdogLimit-1) {
    on_stopTxButton_clicked();
    msgBox("Runaway Tx watchdog");
    m_repeatMsg=0;
  }
  if(m_mode.mid(0,4)=="WSPR" and m_ntr==-1 and !m_tuneup) {
    m_wideGraph->setWSPRtransmitted();
    WSPR_scheduling ();
    m_ntr=0;
  }
  if(m_config.offsetRxFreq() and ui->cbCQRx->isChecked()) {
//    Q_EMIT m_config.transceiver_frequency(m_dialFreq);
    RxQSYTimer->start(50);
  }
}

void MainWindow::RxQSY()
{
  Q_EMIT m_config.transceiver_frequency(m_dialFreq);
}

void MainWindow::ba2msg(QByteArray ba, char message[])             //ba2msg()
{
  int iz=ba.length();
  for(int i=0;i<28; i++) {
    if(i<iz) {
      message[i]=ba[i];
    } else {
      message[i]=32;
    }
  }
  message[28]=0;
}

void MainWindow::on_txFirstCheckBox_stateChanged(int nstate)        //TxFirst
{
  m_txFirst = (nstate==2);
}

void MainWindow::set_ntx(int n)                                   //set_ntx()
{
  m_ntx=n;
  m_repeatMsg=0;
}

void MainWindow::on_txb1_clicked()                                //txb1
{
  m_ntx=1;
  ui->txrb1->setChecked(true);
  if (m_transmitting) m_restart=true;
}

void MainWindow::on_txb2_clicked()                                //txb2
{
  m_ntx=2;
  ui->txrb2->setChecked(true);
  if (m_transmitting) m_restart=true;
}

void MainWindow::on_txb3_clicked()                                //txb3
{
  m_ntx=3;
  ui->txrb3->setChecked(true);
  if (m_transmitting) m_restart=true;
}

void MainWindow::on_txb4_clicked()                                //txb4
{
  m_ntx=4;
  ui->txrb4->setChecked(true);
  if (m_transmitting) m_restart=true;
}

void MainWindow::on_txb5_clicked()                                //txb5
{
  m_ntx=5;
  ui->txrb5->setChecked(true);
  if (m_transmitting) m_restart=true;
}

void MainWindow::on_txb6_clicked()                                //txb6
{
  m_ntx=6;
  ui->txrb6->setChecked(true);
  if (m_transmitting) m_restart=true;
}

void MainWindow::doubleClickOnCall2(bool shift, bool ctrl)
{
  m_decodedText2=true;
  doubleClickOnCall(shift,ctrl);
  m_decodedText2=false;
}

void MainWindow::doubleClickOnCall(bool shift, bool ctrl)
{
  QTextCursor cursor;
  QString t;                         //Full contents
  if(m_mode=="ISCAT") msgBox("Double-click not presently implemented for ISCAT mode");
  if(shift) t="";                    //Silence compiler warning
  if(m_decodedText2) {
    cursor=ui->decodedTextBrowser->textCursor();
    t= ui->decodedTextBrowser->toPlainText();
  } else {
    cursor=ui->decodedTextBrowser2->textCursor();
    t= ui->decodedTextBrowser2->toPlainText();
  }
  cursor.select(QTextCursor::LineUnderCursor);
  int position {cursor.position()};
  if(shift && position==-9999) return;        //Silence compiler warning

  QString messages;
  if(!m_decodedText2) messages= ui->decodedTextBrowser2->toPlainText();
  if(m_decodedText2) messages= ui->decodedTextBrowser->toPlainText();
  if(ui->cbCQRx->isChecked()) m_bDoubleClickAfterCQnnn=true;
  processMessage(messages, position, ctrl);
}

void MainWindow::processMessage(QString const& messages, int position, bool ctrl)
{
  QString t1 = messages.mid(0,position);              //contents up to \n on selected line
  int i1=t1.lastIndexOf("\n") + 1;       //points to first char of line
  DecodedText decodedtext;
  QString t2 = messages.mid(i1,position-i1);         //selected line
  QString t2a;
  int ntsec=3600*t2.mid(0,2).toInt() + 60*t2.mid(2,2).toInt();
  if(m_bFast9) {
    ntsec = ntsec + t2.mid(4,2).toInt();
    t2a=t2.mid(0,4) + t2.mid(6,-1);     //Change hhmmss to hhmm for the message parser
  } else {
    t2a=t2;
  }
  if(m_bFast9) {
    i1=t2a.indexOf(" CQ ");
    if(i1>10) {
      bool ok;
      int kHz=t2a.mid(i1+4,3).toInt(&ok);
      if(ok and kHz>=0 and kHz<=999) {
        t2a=t2a.mid(0,i1+4) + t2a.mid(i1+8,-1);
        if (m_config.transceiver_online ()) {
          int MHz=int(m_dialFreq/1000000);
          m_dialFreq = 1000000*MHz + 1000*kHz;            //QSY Freq for answering CQ nnn
          QString t;
          t.sprintf("QSY %7.3f",0.000001*m_dialFreq);
          ui->decodedTextBrowser2->displayQSY(t);
          ui->labDialFreq->setText (Radio::pretty_frequency_MHz_string (m_dialFreq));
          Q_EMIT m_config.transceiver_frequency (m_dialFreq);

          if (m_monitoring || m_transmitting) {
            if (m_config.transceiver_online ()) {
              if (m_config.split_mode ()) {
                // All conditions are met, reset the transceiver dial frequency:
                Q_EMIT m_config.transceiver_tx_frequency(m_dialFreq);
              }
            }
          }

        }
      }
    }
  }
  decodedtext = t2a;
  int nmod=ntsec % (2*m_TRperiod);
  m_txFirst=(nmod!=0);
  ui->txFirstCheckBox->setChecked(m_txFirst);

  if (decodedtext.indexOf(" CQ ") > 0) {
// TODO this magic 36 characters is also referenced in DisplayText::_appendDXCCWorkedB4()
    auto eom_pos = decodedtext.string ().indexOf (' ', 35);
    if (eom_pos < 35) eom_pos = decodedtext.string ().size () - 1; // we always want at least the characters
                            // to position 35
    decodedtext = decodedtext.string ().left (eom_pos + 1);  // remove DXCC entity and worked B4 status. TODO need a better way to do this
  }

  auto t3 = decodedtext.string ();
  auto t4 = t3.replace (" CQ DX ", " CQ_DX ").split (" ", QString::SkipEmptyParts);
  if(t4.size () < 6) return;             //Skip the rest if no decoded text

  QString hiscall;
  QString hisgrid;
  decodedtext.deCallAndGrid(/*out*/hiscall,hisgrid);
  if (!Radio::is_callsign (hiscall) // not interested if not from QSO partner
      && !(t4.size () == 7          // unless it is of the form
           && (t4.at (5) == m_baseCall // "<our-call> 73"
               || t4.at (5).startsWith (m_baseCall + '/')
               || t4.at (5).endsWith ('/' + m_baseCall))
           && t4.at (6) == "73"))
    {
      qDebug () << "Not processing message - hiscall:" << hiscall << "hisgrid:" << hisgrid;
      return;
    }

  // only allow automatic mode changes between JT9 and JT65, and when not transmitting
  if (!m_transmitting and m_mode == "JT9+JT65") {
      if (decodedtext.isJT9())
        {
          m_modeTx="JT9";
          ui->pbTxMode->setText("Tx JT9  @");
          m_wideGraph->setModeTx(m_modeTx);
        } else if (decodedtext.isJT65()) {
          m_modeTx="JT65";
          ui->pbTxMode->setText("Tx JT65  #");
          m_wideGraph->setModeTx(m_modeTx);
        }
    } else if ((decodedtext.isJT9 () and m_modeTx != "JT9" and m_mode != "JT4") or
               (decodedtext.isJT65 () and m_modeTx != "JT65" and m_mode != "JT4")) {
      // if we are not allowing mode change then don't process decode
      return;
    }

  int frequency = decodedtext.frequencyOffset();
  QString firstcall = decodedtext.call();
  if(!m_bFastMode) {
  // Don't change Tx freq if in a fast mode; also not if a station is calling me,
  // unless m_lockTxFreq is true or CTRL is held down
    if ((firstcall!=m_config.my_callsign () and firstcall != m_baseCall) or
        m_lockTxFreq or ctrl) {
      if (ui->TxFreqSpinBox->isEnabled ()) {
        if(!m_bFastMode) ui->TxFreqSpinBox->setValue(frequency);
      } else if(m_mode!="JT4") {
        return;
      }
    }
  }

  int i9=m_QSOText.indexOf(decodedtext.string());
  if (i9<0 and !decodedtext.isTX())
    {
    decodedtext=t2;
      ui->decodedTextBrowser2->displayDecodedText(decodedtext, m_baseCall, false, m_logBook,
              m_config.color_CQ(), m_config.color_MyCall(), m_config.color_DXCC(),
              m_config.color_NewCall());
      m_QSOText=decodedtext;
    }

  if (ui->RxFreqSpinBox->isEnabled ())
    {
      ui->RxFreqSpinBox->setValue (frequency); //Set Rx freq
    }
  if (decodedtext.isTX())
    {
      if (ctrl && ui->TxFreqSpinBox->isEnabled ())
        {
          ui->TxFreqSpinBox->setValue(frequency); //Set Tx freq
        }
      return;
    }

  // prior DX call (possible QSO partner)
  auto qso_partner_base_call = Radio::base_callsign (ui->dxCallEntry-> text ().toUpper ().trimmed ());

  auto base_call = Radio::base_callsign (hiscall);
  if (base_call != Radio::base_callsign (ui->dxCallEntry-> text ().toUpper ().trimmed ()) || base_call != hiscall)
    {
  // his base call different or his call more qualified
  // i.e. compound version of same base call
      ui->dxCallEntry->setText(hiscall);
    }
  if (gridOK(hisgrid)) {
    if(ui->dxGridEntry->text().mid(0,4) != hisgrid) ui->dxGridEntry->setText(hisgrid);
  }
  if (ui->dxGridEntry->text()=="")
    lookup();
  m_hisGrid = ui->dxGridEntry->text();

  QString rpt = decodedtext.report();
  ui->rptSpinBox->setValue(rpt.toInt());
  genStdMsgs(rpt);

// Determine appropriate response to received message
  auto dtext = " " + decodedtext.string () + " ";
  if(dtext.contains (" " + m_baseCall + " ")
     || dtext.contains ("/" + m_baseCall + " ")
     || dtext.contains (" " + m_baseCall + "/")
     || (firstcall == "DE" && ((t4.size () > 7 && t4.at(7) != "73") || t4.size () <= 7)))
    {

      if (t4.size () > 7   // enough fields for a normal msg
          and !gridOK (t4.at (7))) // but no grid on end of msg
        {
          QString r=t4.at (7);
          if(r.mid(0,3)=="RRR" || (r.toInt()==73)) {
            m_ntx=5;
            ui->txrb5->setChecked(true);
            if(ui->tabWidget->currentIndex()==1) {
              ui->genMsg->setText(ui->tx5->currentText());
              m_ntx=7;
              ui->rbGenMsg->setChecked(true);
            }
          } else if(r.mid(0,1)=="R") {
            m_ntx=4;
            ui->txrb4->setChecked(true);
            if(ui->tabWidget->currentIndex()==1) {
              ui->genMsg->setText(ui->tx4->text());
              m_ntx=7;
              ui->rbGenMsg->setChecked(true);
            }
          } else if(r.toInt()>=-50 and r.toInt()<=49) {
            m_ntx=3;
            ui->txrb3->setChecked(true);
            if(ui->tabWidget->currentIndex()==1) {
              ui->genMsg->setText(ui->tx3->text());
              m_ntx=7;
              ui->rbGenMsg->setChecked(true);
            }
          }
        }
      else if (t4.size () == 7 && t4.at (6) == "73") {
        // 73 back to compound call holder
        m_ntx=5;
        ui->txrb5->setChecked(true);
        if(ui->tabWidget->currentIndex()==1) {
          ui->genMsg->setText(ui->tx5->currentText());
          m_ntx=7;
          ui->rbGenMsg->setChecked(true);
        }
      }
      else {
        m_ntx=2;
        ui->txrb2->setChecked(true);
        if(ui->tabWidget->currentIndex()==1) {
          ui->genMsg->setText(ui->tx2->text());
          m_ntx=7;
          ui->rbGenMsg->setChecked(true);
        }

        if(m_bDoubleClickAfterCQnnn and m_transmitting) {
          on_stopTxButton_clicked();
          TxAgainTimer->start(1500);
        }
        m_bDoubleClickAfterCQnnn=false;
      }
    }
  else if (firstcall == "DE" && t4.size () == 8 && t4.at (7) == "73") {
    if (base_call == qso_partner_base_call) {
      // 73 back to compound call holder
      m_ntx=5;
      ui->txrb5->setChecked(true);
      if(ui->tabWidget->currentIndex()==1) {
        ui->genMsg->setText(ui->tx5->currentText());
        m_ntx=7;
        ui->rbGenMsg->setChecked(true);
      }
    }
    else {
      // treat like a CQ/QRZ
      m_ntx=1;
      ui->txrb1->setChecked(true);
      if(ui->tabWidget->currentIndex()==1) {
        ui->genMsg->setText(ui->tx1->text());
        m_ntx=7;
        ui->rbGenMsg->setChecked(true);
      }
    }
  }
  else // myCall not in msg
    {
      m_ntx=1;
      ui->txrb1->setChecked(true);
      if(ui->tabWidget->currentIndex()==1) {
        ui->genMsg->setText(ui->tx1->text());
        m_ntx=7;
        ui->rbGenMsg->setChecked(true);
      }
    }
  if(m_transmitting) m_restart=true;
  if(m_config.quick_call()) auto_tx_mode(true);
}

void MainWindow::genStdMsgs(QString rpt)                       //genStdMsgs()
{
  QString t;
  if(m_config.my_callsign() !="" and m_config.my_grid() !="")
    {
      t="CQ " + m_config.my_callsign() + " " + m_config.my_grid().mid(0,4);
      if(m_config.offsetRxFreq() and ui->cbCQRx->isChecked()) {
        t.sprintf("CQ %3.3d ",m_freqCQ);
        t += m_config.my_callsign() + " " + m_config.my_grid().mid(0,4);
      }
      if(m_mode=="JT4") t="@1000  (TUNE)";
      msgtype(t, ui->tx6);
    }
  else
    {
      ui->tx6->setText("");
    }
  QString hisCall=ui->dxCallEntry->text().toUpper().trimmed();
  ui->dxCallEntry->setText(hisCall);
  if(hisCall=="") {
    ui->labAz->setText("");
    ui->labDist->setText("");
    ui->tx1->setText("");
    ui->tx2->setText("");
    ui->tx3->setText("");
    ui->tx4->setText("");
    ui->tx5->setCurrentText("");
    ui->genMsg->setText("");
    return;
  }
  QString hisBase = Radio::base_callsign (hisCall);

  QString t0=hisBase + " " + m_baseCall + " ";
  t=t0 + m_config.my_grid ().mid(0,4);
  msgtype(t, ui->tx1);
  if(rpt == "") {
    t=t+" OOO";
    msgtype(t, ui->tx2);
    msgtype("RO", ui->tx3);
    msgtype("RRR", ui->tx4);
    msgtype("73", ui->tx5->lineEdit ());
  } else {
    int n=rpt.toInt();
    rpt.sprintf("%+2.2d",n);
    if(m_mode=="JTMSK" and m_bShMsgs) {
      int i=t0.length()-1;
      t0="<" + t0.mid(0,i) + "> ";
      if(n<26) n=26;
      if(n>28) n=28;
      rpt.sprintf("%2.2d",n);
    }
    t=t0 + rpt;
    msgtype(t, ui->tx2);
    t=t0 + "R" + rpt;
    msgtype(t, ui->tx3);
    t=t0 + "RRR";
    if(m_mode=="JT4" and m_bShMsgs) t="@1500  (RRR)";
    msgtype(t, ui->tx4);
    t=t0 + "73";
    if(m_mode=="JT4" and m_bShMsgs) t="@1750  (73)";
    msgtype(t, ui->tx5->lineEdit ());
  }

  if(m_config.my_callsign () != m_baseCall) {
    if(shortList(m_config.my_callsign ())) {
      t=hisBase + " " + m_config.my_callsign ();
      msgtype(t, ui->tx1);
      t="CQ " + m_config.my_callsign ();
      if(m_config.offsetRxFreq() and ui->cbCQRx->isChecked()) {
        t.sprintf("CQ %3.3d ",m_freqCQ);
        t += m_config.my_callsign ();
      }
      msgtype(t, ui->tx6);
    } else {
      switch (m_config.type_2_msg_gen ())
        {
        case Configuration::type_2_msg_1_full:
          t="DE " + m_config.my_callsign () + " " + m_config.my_grid ().mid(0,4);
          msgtype(t, ui->tx1);
          t=t0 + "R" + rpt;
          msgtype(t, ui->tx3);
          break;

        case Configuration::type_2_msg_3_full:
          t = t0 + m_config.my_grid ().mid(0,4);
          msgtype(t, ui->tx1);
          t="DE " + m_config.my_callsign () + " R" + rpt;
          msgtype(t, ui->tx3);
          break;

        case Configuration::type_2_msg_5_only:
          t = t0 + m_config.my_grid ().mid(0,4);
          msgtype(t, ui->tx1);
          t=t0 + "R" + rpt;
          msgtype(t, ui->tx3);
          break;
        }
      t="DE " + m_config.my_callsign () + " 73";
      msgtype(t, ui->tx5->lineEdit ());
    }
    if (hisCall != hisBase
        && m_config.type_2_msg_gen () != Configuration::type_2_msg_5_only) {
      // cfm we have his full call copied as we could not do this earlier
      t = hisCall + " 73";
      msgtype(t, ui->tx5->lineEdit ());
    }
  } else {
    if(hisCall!=hisBase) {
      if(shortList(hisCall)) {
        // cfm we know his full call with a type 1 tx1 message
        t=hisCall + " " + m_config.my_callsign ();
        msgtype(t, ui->tx1);
      }
      else {
        t=hisCall + " 73";
        msgtype(t, ui->tx5->lineEdit());
      }
    }
  }
  m_ntx=1;
  ui->txrb1->setChecked(true);
  m_rpt=rpt;
}

void MainWindow::TxAgain()
{
  auto_tx_mode(true);
}

void MainWindow::clearDX ()
{
  ui->dxCallEntry->setText("");
  ui->dxGridEntry->setText("");
  m_hisCall="";
  m_hisGrid="";
  m_rptSent="";
  m_rptRcvd="";
  m_qsoStart="";
  m_qsoStop="";
  genStdMsgs("");
  if (1 == ui->tabWidget->currentIndex())
    {
      ui->genMsg->setText(ui->tx6->text());
      m_ntx=7;
      ui->rbGenMsg->setChecked(true);
    }
  else
    {
      m_ntx=6;
      ui->txrb6->setChecked(true);
    }
}

void MainWindow::lookup()                                       //lookup()
{
  QString hisCall=ui->dxCallEntry->text().toUpper().trimmed();
  if (hisCall.isEmpty ())
    {
      return;
    }
  ui->dxCallEntry->setText(hisCall);
  QFile f {m_dataDir.absoluteFilePath ("CALL3.TXT")};
  if (f.open (QIODevice::ReadOnly | QIODevice::Text))
    {
      char c[132];
      qint64 n=0;
      for(int i=0; i<999999; i++) {
        n=f.readLine(c,sizeof(c));
        if(n <= 0) {
          ui->dxGridEntry->setText("");
          break;
        }
        QString t=QString(c);
        if(t.indexOf(hisCall)==0) {
          int i1=t.indexOf(",");
          QString hisgrid=t.mid(i1+1,6);
          i1=hisgrid.indexOf(",");
          if(i1>0) {
            hisgrid=hisgrid.mid(0,4);
          } else {
            hisgrid=hisgrid.mid(0,4) + hisgrid.mid(4,2).toLower();
          }
          ui->dxGridEntry->setText(hisgrid);
          break;
        }
      }
      f.close();
    }
}

void MainWindow::on_lookupButton_clicked()                    //Lookup button
{
  lookup();
}

void MainWindow::on_addButton_clicked()                       //Add button
{
  if(ui->dxGridEntry->text()=="") {
    msgBox("Please enter a valid grid locator.");
    return;
  }
  m_call3Modified=false;
  QString hisCall=ui->dxCallEntry->text().toUpper().trimmed();
  QString hisgrid=ui->dxGridEntry->text().trimmed();
  QString newEntry=hisCall + "," + hisgrid;

  //  int ret = QMessageBox::warning(this, "Add",
  //       newEntry + "\n" + "Is this station known to be active on EME?",
  //       QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
  //  if(ret==QMessageBox::Yes) {
  //    newEntry += ",EME,,";
  //  } else {
  newEntry += ",,,";
  //  }
  
  QFile f1 {m_dataDir.absoluteFilePath ("CALL3.TXT")};
  if(!f1.open(QIODevice::ReadWrite | QIODevice::Text)) {
    msgBox("Cannot open \"" + f1.fileName () + "\" for read/write:" + f1.errorString ());
    return;
  }
  if(f1.size()==0) {
    QTextStream out(&f1);
    out << "ZZZZZZ" << endl;
    f1.close();
    f1.open(QIODevice::ReadOnly | QIODevice::Text);
  }
  QFile f2 {m_dataDir.absoluteFilePath ("CALL3.TMP")};
  if(!f2.open(QIODevice::WriteOnly | QIODevice::Text)) {
    msgBox("Cannot open \"" + f2.fileName () + "\" for writing:" + f2.errorString ());
    return;
  }
  QTextStream in(&f1);          //Read from CALL3.TXT
  QTextStream out(&f2);         //Copy into CALL3.TMP
  QString hc=hisCall;
  QString hc1="";
  QString hc2="000000";
  QString s;
  do {
    s=in.readLine();
    hc1=hc2;
    if(s.mid(0,2)=="//") {
      out << s + "\n";          //Copy all comment lines
    } else {
      int i1=s.indexOf(",");
      hc2=s.mid(0,i1);
      if(hc>hc1 && hc<hc2) {
        out << newEntry + "\n";
        out << s + "\n";
        m_call3Modified=true;
      } else if(hc==hc2) {
        QString t=s + "\n\n is already in CALL3.TXT\n" +
          "Do you wish to replace it?";
        int ret = QMessageBox::warning(this, "Add",t,
                                       QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
        if(ret==QMessageBox::Yes) {
          out << newEntry + "\n";
          m_call3Modified=true;
        }
      } else {
        if(s!="") out << s + "\n";
      }
    }
  } while(!s.isNull());

  f1.close();
  if(hc>hc1 && !m_call3Modified) out << newEntry + "\n";
  if(m_call3Modified) {
    QFile f0 {m_dataDir.absoluteFilePath ("CALL3.OLD")};
    if(f0.exists()) f0.remove();
    QFile f1 {m_dataDir.absoluteFilePath ("CALL3.TXT")};
    f1.rename(m_dataDir.absoluteFilePath ("CALL3.OLD"));
    f2.rename(m_dataDir.absoluteFilePath ("CALL3.TXT"));
    f2.close();
  }
}

void MainWindow::msgtype(QString t, QLineEdit* tx)               //msgtype()
{
  char message[29];
  char msgsent[29];
  int len1=22;
  QByteArray s=t.toUpper().toLocal8Bit();
  ba2msg(s,message);
  int ichk=1,itype=0;
  gen9_(message,&ichk,msgsent,const_cast<int *>(itone),&itype,len1,len1);
  msgsent[22]=0;
  bool text=false;
  if(itype==6) text=true;
  if(m_mode=="JTMSK" and t.mid(0,1)=="<") text=false;
  QString t1;
  t1.fromLatin1(msgsent);
  if(text) t1=t1.mid(0,13);
  QPalette p(tx->palette());
  if(text) {
    p.setColor(QPalette::Base,"#ffccff");
  } else {
    p.setColor(QPalette::Base,Qt::white);
    if(m_mode=="JTMSK" and t.mid(0,1)=="<") p.setColor(QPalette::Base,"#00ffff");
  }
  tx->setPalette(p);
  int len=t.length();
  auto pos  = tx->cursorPosition ();
  if(text && m_mode!="JTMSK" && t.mid(0,1)!="<") {
    len=qMin(len,13);
    tx->setText(t.mid(0,len).toUpper());
  } else {
    tx->setText(t);
  }
  tx->setCursorPosition (pos);
}

void MainWindow::on_tx1_editingFinished()                       //tx1 edited
{
  QString t=ui->tx1->text();
  msgtype(t, ui->tx1);
}

void MainWindow::on_tx2_editingFinished()                       //tx2 edited
{
  QString t=ui->tx2->text();
  msgtype(t, ui->tx2);
}

void MainWindow::on_tx3_editingFinished()                       //tx3 edited
{
  QString t=ui->tx3->text();
  msgtype(t, ui->tx3);
}

void MainWindow::on_tx4_editingFinished()                       //tx4 edited
{
  QString t=ui->tx4->text();
  msgtype(t, ui->tx4);
}

void MainWindow::on_tx5_currentTextChanged (QString const& text) //tx5 edited
{
  msgtype(text, ui->tx5->lineEdit ());
}

void MainWindow::on_tx6_editingFinished()                       //tx6 edited
{
  QString t=ui->tx6->text();
  msgtype(t, ui->tx6);
}

void MainWindow::on_dxCallEntry_textChanged(const QString &t) //dxCall changed
{
  m_hisCall=t.toUpper().trimmed();
  ui->dxCallEntry->setText(m_hisCall);
  statusChanged();
}

void MainWindow::on_dxGridEntry_textChanged(const QString &t) //dxGrid changed
{
  int n=t.length();
  if(n!=4 and n!=6) {
    ui->labAz->setText("");
    ui->labDist->setText("");
    return;
  }
  if(!t[0].isLetter() or !t[1].isLetter()) return;
  if(!t[2].isDigit() or !t[3].isDigit()) return;
  if(n==4) m_hisGrid=t.mid(0,2).toUpper() + t.mid(2,2);
  if(n==6) m_hisGrid=t.mid(0,2).toUpper() + t.mid(2,2) +
             t.mid(4,2).toLower();
  ui->dxGridEntry->setText(m_hisGrid);
  if(gridOK(m_hisGrid)) {
    qint64 nsec = QDateTime::currentMSecsSinceEpoch() % 86400;
    double utch=nsec/3600.0;
    int nAz,nEl,nDmiles,nDkm,nHotAz,nHotABetter;
    azdist_(const_cast <char *> (m_config.my_grid ().toLatin1().constData()),
            const_cast <char *> (m_hisGrid.toLatin1().constData()),&utch,
            &nAz,&nEl,&nDmiles,&nDkm,&nHotAz,&nHotABetter,6,6);
    QString t;
    t.sprintf("Az: %d",nAz);
    ui->labAz->setText(t);
    if (m_config.miles ())
      {
        t.sprintf ("%d mi", int (0.621371 * nDkm));
      }
    else
      {
        t.sprintf ("%d km", nDkm);
      }
    ui->labDist->setText(t);
  } else {
    ui->labAz->setText("");
    ui->labDist->setText("");
  }
}

void MainWindow::on_genStdMsgsPushButton_clicked()         //genStdMsgs button
{
  genStdMsgs(m_rpt);
}

void MainWindow::on_logQSOButton_clicked()                 //Log QSO button
{
  if(m_hisCall=="") return;
  m_dateTimeQSO=QDateTime::currentDateTimeUtc();

  m_logDlg->initLogQSO (m_hisCall, m_hisGrid, m_modeTx, m_rptSent, m_rptRcvd,
                        m_dateTimeQSO, m_dialFreq + ui->TxFreqSpinBox->value(),
                        m_config.my_callsign(), m_config.my_grid(), m_noSuffix,
                        m_config.log_as_RTTY(), m_config.report_in_comments());
}

void MainWindow::acceptQSO2(QDateTime const& QSO_date, QString const& call, QString const& grid
                            , Frequency dial_freq, QString const& mode
                            , QString const& rpt_sent, QString const& rpt_received
                            , QString const& tx_power, QString const& comments
                            , QString const& name)
{
  QString date = m_dateTimeQSO.toString("yyyyMMdd");
  m_logBook.addAsWorked (m_hisCall, m_config.bands ()->find (m_dialFreq), m_modeTx, date);

  m_messageClient->qso_logged (QSO_date, call, grid, dial_freq, mode, rpt_sent, rpt_received, tx_power, comments, name);

  if (m_config.clear_DX ())
    {
      clearDX ();
    }
}

void MainWindow::on_actionJT9_triggered()
{
  m_mode="JT9";
  if(m_nSubMode<4) {
    ui->cbFast9->setChecked(false);
    ui->cbFast9->setEnabled(false);
  } else {
    ui->cbFast9->setEnabled(true);
  }
  m_bFast9=ui->cbFast9->isChecked();
  m_bFastMode=m_bFast9;
  switch_mode (Modes::JT9);
  if(m_modeTx!="JT9") on_pbTxMode_clicked();
  statusChanged();
  m_nsps=6912;
  QString t1=(QString)QChar(short(m_nSubMode+65));
  m_hsymStop=173;
  if(m_config.decode_at_52s()) m_hsymStop=179;
  mode_label->setStyleSheet("QLabel{background-color: #ff99cc}");
  bool bVHF=m_config.enable_VHF_features();
  if(bVHF) {
    QString t1=(QString)QChar(short(m_nSubMode+65));
    mode_label->setText(m_mode + " " + t1);
  } else {
    mode_label->setText(m_mode);
  }
  m_toneSpacing=0.0;
  ui->actionJT9->setChecked(true);
  m_wideGraph->setMode(m_mode);
  m_wideGraph->setModeTx(m_modeTx);
  ui->pbTxMode->setVisible(false);
  VHF_features_enabled(bVHF);
  VHF_controls_visible(bVHF);
  ui->cbFast9->setVisible(bVHF);
  ui->cbShMsgs->setVisible(false);
  ui->cbTx6->setVisible(false);
  ui->cbEME->setVisible(true);
  ui->sbSubmode->setVisible(true);
  ui->sbSubmode->setMaximum(7);
  WSPR_config(false);
  fast_config(m_bFastMode);
  if(m_bFast9) {
    m_TRperiod=ui->sbTR->cleanText().toInt();
    m_wideGraph->hide();
    m_fastGraph->show();
    ui->TxFreqSpinBox->setValue(700);
    ui->RxFreqSpinBox->setValue(700);
    ui->decodedTextLabel->setText("UTC     dB   T  Freq   Message");
    ui->decodedTextLabel2->setText("UTC     dB   T  Freq   Message");
    ui->sbTR->setVisible(true);
  } else {
    m_TRperiod=60;
    ui->decodedTextLabel->setText("UTC   dB   DT Freq   Message");
    ui->decodedTextLabel2->setText("UTC   dB   DT Freq   Message");
    ui->sbTR->setVisible(false);
  }
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_detector->setPeriod(m_TRperiod);  // TODO - not thread safe
  ui->label_6->setText("Band Activity");
  ui->label_7->setText("Rx Frequency");
  ui->ClrAvgButton->setVisible(false);
}

void MainWindow::on_actionJTMSK_triggered()
{
//  on_actionISCAT_triggered();
  m_mode="JTMSK";
  m_modeTx="JTMSK";
  ui->actionJTMSK->setChecked(true);
  switch_mode (Modes::JTMSK);
  statusChanged();
  m_nsps=6;
  mode_label->setStyleSheet("QLabel{background-color: #ff6666}");
  mode_label->setText(m_mode);
  m_toneSpacing=0.0;
  ui->actionJTMSK->setChecked(true);
  ui->pbTxMode->setVisible(false);
  VHF_features_enabled(true);
  VHF_controls_visible(true);
  ui->cbFast9->setVisible(false);
  ui->cbShMsgs->setVisible(true);
  ui->cbTx6->setVisible(false);
  ui->sbSubmode->setVisible(false);
  WSPR_config(false);
  m_bFastMode=true;
  m_bFast9=true;
  fast_config(m_bFastMode);
  m_TRperiod=ui->sbTR->cleanText().toInt();
  m_wideGraph->hide();
  m_fastGraph->show();
  ui->TxFreqSpinBox->setValue(1500);
  ui->RxFreqSpinBox->setValue(1500);
  ui->decodedTextLabel->setText("UTC     dB   T  Freq   Message");
  ui->decodedTextLabel2->setText("UTC     dB   T  Freq   Message");
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_detector->setPeriod(m_TRperiod);  // TODO - not thread safe
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
  ui->label_6->setText("Band Activity");
  ui->label_7->setText("Rx Frequency");
  ui->sbTR->setVisible(true);
  ui->sbFtol->setVisible(true);
  ui->cbEME->setVisible(true);
  ui->ClrAvgButton->setVisible(false);
}

void MainWindow::on_actionJT65_triggered()
{
  if(m_mode=="JT4" or m_mode.mid(0,4)=="WSPR") {
// If coming from JT4 or WSPR mode, pretend temporarily that we're coming
// from JT9 and click the pbTxMode button
    m_modeTx="JT9";
    on_pbTxMode_clicked();
  }
  m_mode="JT65";
  switch_mode (Modes::JT65);
  if(m_modeTx!="JT65") on_pbTxMode_clicked();
  statusChanged();
  m_TRperiod=60;
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_detector->setPeriod(m_TRperiod);   // TODO - not thread safe
  m_nsps=6912;                   //For symspec only
  m_hsymStop=173;
  if(m_config.decode_at_52s()) m_hsymStop=179;
  m_toneSpacing=0.0;
  mode_label->setStyleSheet("QLabel{background-color: #66ff66}");
  QString t1=(QString)QChar(short(m_nSubMode+65));
  mode_label->setText(m_mode + " " + t1);
  ui->ClrAvgButton->setVisible(false);
  ui->actionJT65->setChecked(true);
  VHF_features_enabled(true);
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
  m_wideGraph->setMode(m_mode);
  m_wideGraph->setModeTx(m_modeTx);
  ui->pbTxMode->setVisible(false);
  bool bVHF=m_config.enable_VHF_features();
  m_bFastMode=false;
  m_bFast9=false;
  VHF_controls_visible(bVHF);
  ui->cbFast9->setVisible(false);
  WSPR_config(false);
  fast_config(false);
  ui->sbSubmode->setMaximum(2);
  if(bVHF) {
    ui->sbSubmode->setValue(m_nSubMode);
  } else {
    ui->sbSubmode->setValue(0);
    ui->sbTR->setValue(0);
  }
  ui->label_6->setText("Band Activity");
  ui->label_7->setText("Rx Frequency");
}

void MainWindow::on_actionJT9_JT65_triggered()
{
  m_mode="JT9+JT65";
  switch_mode (Modes::JT65);
  if(m_modeTx != "JT65") {
    ui->pbTxMode->setText("Tx JT9  @");
    m_modeTx="JT9";
  }
  m_nSubMode=0;                    //Dual-mode always means JT9 and JT65A
  statusChanged();
  m_TRperiod=60;
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_detector->setPeriod(m_TRperiod);  // TODO - not thread safe
  m_nsps=6912;
  m_hsymStop=173;
  if(m_config.decode_at_52s()) m_hsymStop=179;
  m_toneSpacing=0.0;
  mode_label->setStyleSheet("QLabel{background-color: #ffff66}");
  mode_label->setText(m_mode);
  ui->actionJT9_JT65->setChecked(true);
  VHF_features_enabled(false);
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
  m_wideGraph->setMode(m_mode);
  m_wideGraph->setModeTx(m_modeTx);
  ui->pbTxMode->setVisible(true);
  m_bFastMode=false;
  m_bFast9=false;
  VHF_controls_visible(false);
  WSPR_config(false);
  fast_config(false);
  ui->sbSubmode->setValue(0);
  ui->sbTR->setValue(0);
  ui->label_6->setText("Band Activity");
  ui->label_7->setText("Rx Frequency");
  ui->ClrAvgButton->setVisible(false);
}

void MainWindow::on_actionJT4_triggered()
{
  m_mode="JT4";
  switch_mode (Modes::JT4);
  m_modeTx="JT4";
  mode_label->setStyleSheet("QLabel{background-color: #cc99ff}");
  statusChanged();
  m_TRperiod=60;
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_detector->setPeriod(m_TRperiod);  // TODO - not thread safe
  m_nsps=6912;                   //For symspec only
  m_hsymStop=179;
  m_toneSpacing=0.0;
  ui->actionJT4->setChecked(true);
  VHF_features_enabled(true);
  ui->ClrAvgButton->setVisible(true);
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
  m_wideGraph->setMode(m_mode);
  m_wideGraph->setModeTx(m_modeTx);
  ui->pbTxMode->setVisible(false);
  m_bFastMode=false;
  m_bFast9=false;
  bool bVHF=m_config.enable_VHF_features();
  VHF_controls_visible(bVHF);
  WSPR_config(false);
  fast_config(false);
  ui->cbFast9->setVisible(false);
  ui->cbShMsgs->setVisible(true);
  ui->cbTx6->setVisible(true);
  ui->sbTR->setVisible(false);
  ui->sbSubmode->setVisible(true);
  ui->sbSubmode->setMaximum(6);
  ui->label_6->setText("Single-Period Decodes");
  ui->label_7->setText("Average Decodes");
  if(bVHF) {
    ui->sbSubmode->setValue(m_nSubMode);
  } else {
    ui->sbSubmode->setValue(0);
    ui->sbTR->setValue(0);
  }
  QString t1=(QString)QChar(short(m_nSubMode+65));
  mode_label->setText(m_mode + " " + t1);
}

void MainWindow::on_actionWSPR_2_triggered()
{
  m_mode="WSPR-2";
  switch_mode (Modes::WSPR);
  m_modeTx="WSPR-2";                                    //### not needed ?? ###
  statusChanged();
  m_TRperiod=120;
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_detector->setPeriod(m_TRperiod);  // TODO - not thread safe
  m_nsps=6912;                   //For symspec only
  m_hsymStop=396;
  m_toneSpacing=12000.0/8192.0;
  mode_label->setStyleSheet("QLabel{background-color: #ff66ff}");
  mode_label->setText(m_mode);
  ui->actionWSPR_2->setChecked(true);
  VHF_features_enabled(false);
  ui->ClrAvgButton->setVisible(false);
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
  m_wideGraph->setMode(m_mode);
  m_wideGraph->setModeTx(m_modeTx);
  m_bFastMode=false;
  m_bFast9=false;
  WSPR_config(true);
  fast_config(false);
  ui->TxFreqSpinBox->setValue(ui->WSPRfreqSpinBox->value());
}

void MainWindow::on_actionWSPR_15_triggered()
{
  msgBox("WSPR-15 is not yet available");
  switch_mode (Modes::WSPR);
}

void MainWindow::on_actionEcho_triggered()
{
  on_actionJT4_triggered();
  m_mode="Echo";
  ui->actionEcho->setChecked(true);
  mode_label->setStyleSheet("QLabel{background-color: #66ffff}");
  mode_label->setText(m_mode);
  m_TRperiod=3;
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_detector->setPeriod(m_TRperiod);  // TODO - not thread safe
  m_nsps=6912;                   //For symspec only
  m_hsymStop=10;
  m_toneSpacing=1.0;
  switch_mode(Modes::Echo);
  m_modeTx="Echo";
  m_wideGraph->setMode(m_mode);
  m_wideGraph->setModeTx(m_modeTx);
  ui->TxFreqSpinBox->setValue(1500);
  ui->TxFreqSpinBox->setEnabled (false);
  statusChanged();
  if(!m_echoGraph->isVisible()) m_echoGraph->show();
  on_actionAstronomical_data_triggered ();
  m_bFastMode=false;
  m_bFast9=false;
  VHF_controls_visible(false);
  WSPR_config(true);                       //Make some irrelevant controls invisible
  fast_config(false);
  ui->decodedTextLabel->setText("   UTC      N   Level    Sig      DF    Width   Q");
  auto_tx_label->setText("");
}

void MainWindow::on_actionISCAT_triggered()
{
  m_mode="ISCAT";
  m_modeTx="ISCAT";
  ui->actionISCAT->setChecked(true);
  m_TRperiod=ui->sbTR->cleanText().toInt();
  m_modulator->setPeriod(m_TRperiod);
  m_detector->setPeriod(m_TRperiod);
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
  m_nsps=6912;                   //For symspec only
  m_hsymStop=103;
  m_toneSpacing=11025.0/256.0;
  switch_mode(Modes::ISCAT);
  m_wideGraph->setMode(m_mode);
  m_wideGraph->setModeTx(m_modeTx);
  statusChanged();
  if(!m_fastGraph->isVisible()) m_fastGraph->show();
  if(m_wideGraph->isVisible()) m_wideGraph->hide();
  mode_label->setStyleSheet("QLabel{background-color: #ff9933}");
  mode_label->setText(m_mode);
  VHF_controls_visible(true);
  WSPR_config(false);
  fast_config(true);
  ui->pbTxMode->setVisible(false);
  ui->cbFast9->setVisible(false);
  ui->sbTR->setVisible(true);
  ui->sbFtol->setVisible(true);
  ui->sbSubmode->setVisible(true);
  ui->cbShMsgs->setVisible(false);
  ui->cbTx6->setVisible(false);
  ui->cbEME->setVisible(false);
  ui->decodedTextBrowser2->setVisible(false);
  ui->decodedTextLabel2->setVisible(false);
  ui->decodedTextLabel->setText(
        "  UTC  Sync dB   DT   DF  F1                                   N  L  A   T");
  auto_tx_label->setText("");
  ui->tabWidget->setCurrentIndex(0);
  ui->sbSubmode->setMaximum(1);
  QString t1=(QString)QChar(short(m_nSubMode+65));
  mode_label->setText(m_mode + " " + t1);
  if(m_nSubMode==0) ui->TxFreqSpinBox->setValue(1012);
  if(m_nSubMode==1) ui->TxFreqSpinBox->setValue(560);
  ui->TxFreqSpinBox->setEnabled (false);
}

void MainWindow::switch_mode (Mode mode)
{
  auto f = m_dialFreq;
  m_config.frequencies ()->filter (mode);
  auto const& row = m_config.frequencies ()->best_working_frequency (f);
  if (row >= 0) {
    ui->bandComboBox->setCurrentIndex (row);
    on_bandComboBox_activated (row);
  }
  bool b=m_mode=="JTMSK";
  ui->sbCQRxFreq->setVisible(b);
  ui->cbCQRx->setVisible(b);
  ui->syncSpinBox->setVisible(!b);
  ui->pbR2T->setVisible(!b);
  ui->pbT2R->setVisible(!b);
  ui->cbTxLock->setVisible(!b);
  ui->TxFreqSpinBox->setVisible(!b);
}

void MainWindow::WSPR_config(bool b)
{
  ui->decodedTextBrowser2->setVisible(!b);
  ui->decodedTextLabel2->setVisible(!b);
  ui->controls_stack_widget->setCurrentIndex (b && m_mode != "Echo" ? 1 : 0);
  ui->QSO_controls_widget->setVisible (!b);
  ui->DX_controls_widget->setVisible (!b);
  ui->WSPR_controls_widget->setVisible (b);
  ui->label_6->setVisible(!b);
  ui->label_7->setVisible(!b);
  ui->logQSOButton->setVisible(!b);
  ui->DecodeButton->setEnabled(!b);
  if(b and (m_mode!="Echo")) {
    ui->decodedTextLabel->setText(
          "UTC    dB   DT     Freq     Drift  Call          Grid    dBm   Dist");
    auto_tx_label->setText("");
    Q_EMIT m_config.transceiver_tx_frequency (0); // turn off split
    m_bSimplex = true;
  } else {
    ui->decodedTextLabel->setText("UTC   dB   DT Freq   Message");
    auto_tx_label->setText (m_config.quick_call () ? "Auto-Tx-Enable Armed" : "Auto-Tx-Enable Disarmed");
    m_bSimplex = false;
  }
  enable_DXCC_entity (m_config.DXCC ());  // sets text window proportions and (re)inits the logbook
}

void MainWindow::fast_config(bool b)
{
  m_bFastMode=b;
  ui->ClrAvgButton->setVisible(!b);
  ui->TxFreqSpinBox->setEnabled(!b);
  if(b) {
    ui->cbEME->setText("Auto Seq");
    ui->sbTR->setVisible(true);
  } else {
    ui->cbEME->setText("EME delay");
    ui->sbTR->setVisible(false);
  }
  if(b and (m_bFast9 or m_mode=="JTMSK" or m_mode=="ISCAT")) {
    ui->sbTR->setValue(m_TRindex);
    m_wideGraph->hide();
    m_fastGraph->show();
  } else {
    m_wideGraph->show();
    m_fastGraph->hide();
  }
}

void MainWindow::on_TxFreqSpinBox_valueChanged(int n)
{
  m_wideGraph->setTxFreq(n);
  if(m_lockTxFreq) ui->RxFreqSpinBox->setValue(n);
  Q_EMIT transmitFrequency (n - m_XIT);
}

void MainWindow::on_RxFreqSpinBox_valueChanged(int n)
{
  m_wideGraph->setRxFreq(n);
  if (m_lockTxFreq && ui->TxFreqSpinBox->isEnabled ())
    {
      ui->TxFreqSpinBox->setValue (n);
    }
}

void MainWindow::on_actionQuickDecode_triggered()
{
  m_ndepth=1;
  ui->actionQuickDecode->setChecked(true);
}

void MainWindow::on_actionMediumDecode_triggered()
{
  m_ndepth=2;
  ui->actionMediumDecode->setChecked(true);
}

void MainWindow::on_actionDeepestDecode_triggered()
{
  m_ndepth=3;
  ui->actionDeepestDecode->setChecked(true);
}

void MainWindow::on_actionInclude_averaging_triggered()
{
  m_ndepth=4;
  ui->actionInclude_averaging->setChecked(true);
}

void MainWindow::on_actionInclude_correlation_triggered()
{
  m_ndepth=5;
  ui->actionInclude_correlation->setChecked(true);
}

void MainWindow::on_inGain_valueChanged(int n)
{
  m_inGain=n;
}

void MainWindow::on_actionErase_ALL_TXT_triggered()          //Erase ALL.TXT
{
  int ret = QMessageBox::warning(this, "Confirm Erase",
                                 "Are you sure you want to erase file ALL.TXT ?",
                                 QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
  if(ret==QMessageBox::Yes) {
    QFile f {m_dataDir.absoluteFilePath ("ALL.TXT")};
    f.remove();
    m_RxLog=1;
  }
}

void MainWindow::on_actionErase_wsjtx_log_adi_triggered()
{
  int ret = QMessageBox::warning(this, "Confirm Erase",
                                 "Are you sure you want to erase file wsjtx_log.adi ?",
                                 QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
  if(ret==QMessageBox::Yes) {
    QFile f {m_dataDir.absoluteFilePath ("wsjtx_log.adi")};
    f.remove();
  }
}

void MainWindow::on_actionOpen_log_directory_triggered ()
{
  QDesktopServices::openUrl (QUrl::fromLocalFile (m_dataDir.absolutePath ()));
}

bool MainWindow::gridOK(QString g)
{
  bool b=false;
  if(g.length()>=4) {
    b=g.mid(0,1).compare("A")>=0 and
        g.mid(0,1).compare("R")<=0 and
        g.mid(1,1).compare("A")>=0 and
        g.mid(1,1).compare("R")<=0 and
        g.mid(2,1).compare("0")>=0 and
        g.mid(2,1).compare("9")<=0 and
        g.mid(3,1).compare("0")>=0 and
        g.mid(3,1).compare("9")<=0;
  }
  return b;
}

void MainWindow::on_bandComboBox_currentIndexChanged (int index)
{
  auto const& frequencies = m_config.frequencies ();
  auto const& source_index = frequencies->mapToSource (frequencies->index (index, FrequencyList::frequency_column));
  Frequency frequency {m_dialFreq};
  if (source_index.isValid ())
    {
      frequency = frequencies->frequency_list ()[source_index.row ()].frequency_;
      m_dialFreq0=frequency;
    }

  // Lookup band
  auto const& band  = m_config.bands ()->find (frequency);
  if (!band.isEmpty ())
    {
      ui->bandComboBox->lineEdit ()->setStyleSheet ({});
      ui->bandComboBox->setCurrentText (band);
    }
  else
    {
      ui->bandComboBox->lineEdit ()->setStyleSheet ("QLineEdit {color: yellow; background-color : red;}");
      ui->bandComboBox->setCurrentText (m_config.bands ()->oob ());
    }
  displayDialFrequency ();
}

void MainWindow::on_bandComboBox_activated (int index)
{
  auto const& frequencies = m_config.frequencies ();
  auto const& source_index = frequencies->mapToSource (frequencies->index (index, FrequencyList::frequency_column));
  Frequency frequency {m_dialFreq};
  if (source_index.isValid ())
    {
      frequency = frequencies->frequency_list ()[source_index.row ()].frequency_;
    }
  m_bandEdited = true;
  band_changed (frequency);
  m_wideGraph->setRxBand (m_config.bands ()->find (frequency));
}

void MainWindow::band_changed (Frequency f)
{
  if (m_bandEdited) {
    if (!m_mode.startsWith ("WSPR")) {
      ui->stopTxButton->click (); // halt any transmission
      auto_tx_mode (false);       // disable auto Tx
    }
    m_bandEdited = false;
    psk_Reporter->sendReport();      // Upload any queued spots before changing band
    if (!m_transmitting) monitor (true);
    Q_EMIT m_config.transceiver_frequency (f);
    qsy (f);
    setXIT (ui->TxFreqSpinBox->value ());
    m_repeatMsg = 0;            // reset Tx watchdog
  }
}

void MainWindow::enable_DXCC_entity (bool on)
{
  if (on and m_mode.mid(0,4)!="WSPR" and m_mode!="Echo") {
    m_logBook.init();                        // re-read the log and cty.dat files
    ui->gridLayout->setColumnStretch(0,55);  // adjust proportions of text displays
    ui->gridLayout->setColumnStretch(1,45);
  } else {
    ui->gridLayout->setColumnStretch(0,0);
    ui->gridLayout->setColumnStretch(1,0);
  }
  updateGeometry ();
}

void MainWindow::on_pbCallCQ_clicked()
{
  genStdMsgs(m_rpt);
  ui->genMsg->setText(ui->tx6->text());
  m_ntx=7;
  ui->rbGenMsg->setChecked(true);
  if(m_transmitting) m_restart=true;
}

void MainWindow::on_pbAnswerCaller_clicked()
{
  genStdMsgs(m_rpt);
  QString t=ui->tx3->text();
  int i0=t.indexOf(" R-");
  if(i0<0) i0=t.indexOf(" R+");
  t=t.mid(0,i0+1)+t.mid(i0+2,3);
  ui->genMsg->setText(t);
  m_ntx=7;
  ui->rbGenMsg->setChecked(true);
  if(m_transmitting) m_restart=true;
}

void MainWindow::on_pbSendRRR_clicked()
{
  genStdMsgs(m_rpt);
  ui->genMsg->setText(ui->tx4->text());
  m_ntx=7;
  ui->rbGenMsg->setChecked(true);
  if(m_transmitting) m_restart=true;
}

void MainWindow::on_pbAnswerCQ_clicked()
{
  genStdMsgs(m_rpt);
  ui->genMsg->setText(ui->tx1->text());
  QString t=ui->tx2->text();
  int i0=t.indexOf("/");
  int i1=t.indexOf(" ");
  if(i0>0 and i0<i1) ui->genMsg->setText(t);
  m_ntx=7;
  ui->rbGenMsg->setChecked(true);
  if(m_transmitting) m_restart=true;
}

void MainWindow::on_pbSendReport_clicked()
{
  genStdMsgs(m_rpt);
  ui->genMsg->setText(ui->tx3->text());
  m_ntx=7;
  ui->rbGenMsg->setChecked(true);
  if(m_transmitting) m_restart=true;
}

void MainWindow::on_pbSend73_clicked()
{
  genStdMsgs(m_rpt);
  ui->genMsg->setText(ui->tx5->currentText());
  m_ntx=7;
  ui->rbGenMsg->setChecked(true);
  if(m_transmitting) m_restart=true;
}

void MainWindow::on_rbGenMsg_clicked(bool checked)
{
  m_freeText=!checked;
  if(!m_freeText) {
    if(m_ntx != 7 && m_transmitting) m_restart=true;
    m_ntx=7;
  }
}

void MainWindow::on_rbFreeText_clicked(bool checked)
{
  m_freeText=checked;
  if(m_freeText) {
    m_ntx=8;
    if (m_transmitting) m_restart=true;
  }
}

void MainWindow::on_freeTextMsg_currentTextChanged (QString const& text)
{
  msgtype(text, ui->freeTextMsg->lineEdit ());
}

void MainWindow::on_rptSpinBox_valueChanged(int n)
{
  m_rpt=QString::number(n);
  int ntx0=m_ntx;
  QString t=ui->tx5->currentText();
  genStdMsgs(m_rpt);
  ui->tx5->setCurrentText(t);
  m_ntx=ntx0;
  if(m_ntx==1) ui->txrb1->setChecked(true);
  if(m_ntx==2) ui->txrb2->setChecked(true);
  if(m_ntx==3) ui->txrb3->setChecked(true);
  if(m_ntx==4) ui->txrb4->setChecked(true);
  if(m_ntx==5) ui->txrb5->setChecked(true);
  if(m_ntx==6) ui->txrb6->setChecked(true);
  statusChanged();
}

void MainWindow::on_tuneButton_clicked (bool checked)
{
  if (m_tune) {
    tuneButtonTimer->start(250);
  } else {
    m_sentFirst73=false;
    m_repeatMsg=0;
    itone[0]=0;
    on_monitorButton_clicked (true);
    m_tune_attenuation_restore = ui->outAttenuation->value();
    if (m_tune_attenuation)
      {
        m_block_pwr_tooltip = true;
        ui->outAttenuation->setValue(m_tune_attenuation);
        m_block_pwr_tooltip = false;
      }
    m_tune=true;
  }
  Q_EMIT tune (checked);
}

void MainWindow::stop_tuning ()
{
  on_tuneButton_clicked(false);
  ui->tuneButton->setChecked (false);
  m_bTxTime=false;
  m_tune=false;
  m_block_pwr_tooltip = true;
  ui->outAttenuation->setValue(m_tune_attenuation_restore);
  m_block_pwr_tooltip = false;
}

void MainWindow::stopTuneATU()
{
  on_tuneButton_clicked(false);
  m_bTxTime=false;
}

void MainWindow::on_stopTxButton_clicked()                    //Stop Tx
{
  if (m_tune) stop_tuning ();
  if (m_auto and !m_tuneup) auto_tx_mode (false);
  m_btxok=false;
  m_repeatMsg=0;
}

void MainWindow::rigOpen ()
{
  update_dynamic_property (ui->readFreq, "state", "warning");
  ui->readFreq->setText ("");
  ui->readFreq->setEnabled (true);
  m_config.transceiver_online (true);
  Q_EMIT m_config.sync_transceiver (true);
}

void MainWindow::on_pbR2T_clicked()
{
  if (ui->TxFreqSpinBox->isEnabled ()) ui->TxFreqSpinBox->setValue(ui->RxFreqSpinBox->value ());
}

void MainWindow::on_pbT2R_clicked()
{
  if (ui->RxFreqSpinBox->isEnabled ())
    {
      ui->RxFreqSpinBox->setValue (ui->TxFreqSpinBox->value ());
    }
}


void MainWindow::on_readFreq_clicked()
{
  if (m_transmitting) return;

  if (m_config.transceiver_online (true))
    {
      Q_EMIT m_config.sync_transceiver (true);
    }
}

void MainWindow::on_pbTxMode_clicked()
{
  if(m_modeTx=="JT9") {
    m_modeTx="JT65";
    ui->pbTxMode->setText("Tx JT65  #");
  } else {
    m_modeTx="JT9";
    ui->pbTxMode->setText("Tx JT9  @");
  }
  m_wideGraph->setModeTx(m_modeTx);
  statusChanged();
}

void MainWindow::setXIT(int n)
{
  m_XIT = 0;
  if (!m_bSimplex) {
    // m_bSimplex is false, so we can use split mode if requested
    if (m_config.split_mode () && m_mode != "JT4") {
      // Don't use XIT in JT4, we may be using Doppler control
      m_XIT=(n/500)*500 - 1500;
    }

    if (m_monitoring || m_transmitting) {
      if (m_config.transceiver_online ()) {
        if (m_config.split_mode ()) {
          // All conditions are met, reset the transceiver dial frequency:
          Q_EMIT m_config.transceiver_tx_frequency (m_dialFreq + m_XIT);
        }
      }
    }
  }
  //Now set the audio Tx freq
  Q_EMIT transmitFrequency (ui->TxFreqSpinBox->value () - m_XIT);
}

void MainWindow::setFreq4(int rxFreq, int txFreq)
{
  if (ui->RxFreqSpinBox->isEnabled ())
    {
      ui->RxFreqSpinBox->setValue(rxFreq);
    }

  if(m_mode.mid(0,4)=="WSPR") {
    ui->WSPRfreqSpinBox->setValue(txFreq);
  } else {
    if (ui->TxFreqSpinBox->isEnabled ()) {
      ui->TxFreqSpinBox->setValue(txFreq);
    }
  }
}

void MainWindow::on_cbTxLock_clicked(bool checked)
{
  m_lockTxFreq=checked;
  m_wideGraph->setLockTxFreq(m_lockTxFreq);
  if(m_lockTxFreq) on_pbR2T_clicked();
}

void MainWindow::handle_transceiver_update (Transceiver::TransceiverState s)
{
  transmitDisplay (s.ptt ());
  if ((s.frequency () - m_dialFreq) || s.split () != m_splitMode)
    {
      m_splitMode = s.split ();
      qsy (s.frequency ());
    }
  update_dynamic_property (ui->readFreq, "state", "ok");
  ui->readFreq->setEnabled (false);
  ui->readFreq->setText (s.split () ? "S" : "");
}

void MainWindow::handle_transceiver_failure (QString reason)
{
  update_dynamic_property (ui->readFreq, "state", "error");
  ui->readFreq->setEnabled (true);
  on_stopTxButton_clicked ();
  rigFailure ("Rig Control Error", reason);

  // disable WSPR band hopping so that spots are not sent on the wrong
  // band
  ui->band_hopping_group_box->setChecked (false);
}

void MainWindow::rigFailure (QString const& reason, QString const& detail)
{
  static bool first_error {true};
  if (first_error)
    {
      // one automatic retry
      QTimer::singleShot (0, this, SLOT (rigOpen ()));
      first_error = false;
    }
  else
    {
      m_rigErrorMessageBox.setText (reason);
      m_rigErrorMessageBox.setDetailedText (detail);

      // don't call slot functions directly to avoid recursion
      switch (m_rigErrorMessageBox.exec ())
        {
        case QMessageBox::Ok:
          QTimer::singleShot (0, this, SLOT (on_actionSettings_triggered ()));
          break;

        case QMessageBox::Retry:
          QTimer::singleShot (0, this, SLOT (rigOpen ()));
          break;

        case QMessageBox::Cancel:
          QTimer::singleShot (0, this, SLOT (close ()));
          break;
        }
      first_error = true;       // reset
    }
}

void MainWindow::transmit (double snr)
{
  double toneSpacing=0.0;
  if (m_modeTx == "JT65") {
    if(m_nSubMode==0) toneSpacing=11025.0/4096.0;
    if(m_nSubMode==1) toneSpacing=2*11025.0/4096.0;
    if(m_nSubMode==2) toneSpacing=4*11025.0/4096.0;
    Q_EMIT sendMessage (NUM_JT65_SYMBOLS,
           4096.0*12000.0/11025.0, ui->TxFreqSpinBox->value () - m_XIT,
           toneSpacing, m_soundOutput, m_config.audio_output_channel (),
           true, false, snr, m_TRperiod);
  }
  if (m_modeTx == "JT9") {
    int nsub=pow(2,m_nSubMode);
    int nsps[]={480,240,120,60};
    double sps=m_nsps;
    m_toneSpacing=nsub*12000.0/6912.0;
    bool fastmode=false;
    if(m_bFast9 and (m_nSubMode>=4)) {
      fastmode=true;
      sps=nsps[m_nSubMode-4];
      m_toneSpacing=12000.0/sps;
    }
    Q_EMIT sendMessage (NUM_JT9_SYMBOLS, sps,
                        ui->TxFreqSpinBox->value() - m_XIT, m_toneSpacing,
                        m_soundOutput, m_config.audio_output_channel (),
                        true, fastmode, snr, m_TRperiod);
  }

  if (m_modeTx == "JTMSK") {
    m_nsps=6;
    m_toneSpacing=6000.0/m_nsps;
    double f0=1000.0;
    int nsym=NUM_JTMSK_SYMBOLS;
    if(itone[35] < 0) nsym=35;
    Q_EMIT sendMessage (nsym, double(m_nsps), f0, m_toneSpacing,
                        m_soundOutput, m_config.audio_output_channel (),
                        true, true, snr, m_TRperiod);
  }

  if (m_modeTx == "JT4") {
    if(m_nSubMode==0) toneSpacing=4.375;
    if(m_nSubMode==1) toneSpacing=2*4.375;
    if(m_nSubMode==2) toneSpacing=4*4.375;
    if(m_nSubMode==3) toneSpacing=9*4.375;
    if(m_nSubMode==4) toneSpacing=18*4.375;
    if(m_nSubMode==5) toneSpacing=36*4.375;
    if(m_nSubMode==6) toneSpacing=72*4.375;
    Q_EMIT sendMessage (NUM_JT4_SYMBOLS,
           2520.0*12000.0/11025.0, ui->TxFreqSpinBox->value () - m_XIT,
           toneSpacing, m_soundOutput, m_config.audio_output_channel (),
           true, false, snr, m_TRperiod);
  }
  if (m_mode=="WSPR-2") {                                      //### Similar code needed for WSPR-15 ###

    Q_EMIT sendMessage (NUM_WSPR_SYMBOLS, 8192.0,
                        ui->TxFreqSpinBox->value() - 1.5 * 12000 / 8192, m_toneSpacing,
                        m_soundOutput, m_config.audio_output_channel(),
                        true, false, snr, m_TRperiod);
  }
  if(m_mode=="Echo") {
    //??? should use "fastMode = true" here ???
    Q_EMIT sendMessage (27, 1024.0, 1500.0, 0.0, m_soundOutput,
                        m_config.audio_output_channel(),
                        false, false, snr, m_TRperiod);
  }

  if(m_mode=="ISCAT") {
    double sps,f0;
    if(m_nSubMode==0) {
      sps=512.0*12000.0/11025.0;
      toneSpacing=11025.0/512.0;
      f0=47*toneSpacing;
    } else {
      sps=256.0*12000.0/11025.0;
      toneSpacing=11025.0/256.0;
      f0=13*toneSpacing;
    }
    Q_EMIT sendMessage (NUM_ISCAT_SYMBOLS, sps, f0, toneSpacing, m_soundOutput,
                        m_config.audio_output_channel(),
                        true, true, snr, m_TRperiod);
  }

// In auto-sequencing mode, stop after 5 transmissions of "73" message.
  if(m_mode=="JT9" and m_bFast9 and ui->cbEME->isChecked()) {
    if(m_ntx==5) {
      m_nTx73 += 1;
    } else {
      m_nTx73=0;
    }
  }
}

void MainWindow::on_outAttenuation_valueChanged (int a)
{
  QString tt_str;
  qreal dBAttn {a / 10.};       // slider interpreted as dB / 100
  if (m_tune && Qt::ShiftModifier == QGuiApplication::keyboardModifiers ())
    {
      // special attenuation value for Tune button
      m_tune_attenuation = a;
      if (a)
        {
          tt_str = tr ("Tune digital gain ")
            + (a ? QString::number (-dBAttn, 'f', 1) : "0") + "dB\n"
            "Set at top to cancel";
        }
      else
        {
          tt_str = tr ("Tune power = Tx power");
        }
    }
  else
    {
      tt_str = tr ("Transmit digital gain ")
        + (a ? QString::number (-dBAttn, 'f', 1) : "0") + "dB";
    }
  if (!m_block_pwr_tooltip)
    {
      QToolTip::showText (QCursor::pos (), tt_str, ui->outAttenuation);
    }
  Q_EMIT outAttenuationChanged (dBAttn);
}

void MainWindow::on_actionShort_list_of_add_on_prefixes_and_suffixes_triggered()
{
  if (!m_prefixes)
    {
      m_prefixes.reset (new HelpTextWindow {tr ("Prefixes"), ":/prefixes.txt", {"Courier", 10}});
    }
  m_prefixes->showNormal();
  m_prefixes->raise ();
}

void MainWindow::getpfx()
{
  m_prefix <<"1A" <<"1S" <<"3A" <<"3B6" <<"3B8" <<"3B9" <<"3C" <<"3C0" \
           <<"3D2" <<"3D2C" <<"3D2R" <<"3DA" <<"3V" <<"3W" <<"3X" <<"3Y" \
           <<"3YB" <<"3YP" <<"4J" <<"4L" <<"4S" <<"4U1I" <<"4U1U" <<"4W" \
           <<"4X" <<"5A" <<"5B" <<"5H" <<"5N" <<"5R" <<"5T" <<"5U" \
           <<"5V" <<"5W" <<"5X" <<"5Z" <<"6W" <<"6Y" <<"7O" <<"7P" \
           <<"7Q" <<"7X" <<"8P" <<"8Q" <<"8R" <<"9A" <<"9G" <<"9H" \
           <<"9J" <<"9K" <<"9L" <<"9M2" <<"9M6" <<"9N" <<"9Q" <<"9U" \
           <<"9V" <<"9X" <<"9Y" <<"A2" <<"A3" <<"A4" <<"A5" <<"A6" \
           <<"A7" <<"A9" <<"AP" <<"BS7" <<"BV" <<"BV9" <<"BY" <<"C2" \
           <<"C3" <<"C5" <<"C6" <<"C9" <<"CE" <<"CE0X" <<"CE0Y" <<"CE0Z" \
           <<"CE9" <<"CM" <<"CN" <<"CP" <<"CT" <<"CT3" <<"CU" <<"CX" \
           <<"CY0" <<"CY9" <<"D2" <<"D4" <<"D6" <<"DL" <<"DU" <<"E3" \
           <<"E4" <<"EA" <<"EA6" <<"EA8" <<"EA9" <<"EI" <<"EK" <<"EL" \
           <<"EP" <<"ER" <<"ES" <<"ET" <<"EU" <<"EX" <<"EY" <<"EZ" \
           <<"F" <<"FG" <<"FH" <<"FJ" <<"FK" <<"FKC" <<"FM" <<"FO" \
           <<"FOA" <<"FOC" <<"FOM" <<"FP" <<"FR" <<"FRG" <<"FRJ" <<"FRT" \
           <<"FT5W" <<"FT5X" <<"FT5Z" <<"FW" <<"FY" <<"M" <<"MD" <<"MI" \
           <<"MJ" <<"MM" <<"MU" <<"MW" <<"H4" <<"H40" <<"HA" \
           <<"HB" <<"HB0" <<"HC" <<"HC8" <<"HH" <<"HI" <<"HK" <<"HK0" \
           <<"HK0M" <<"HL" <<"HM" <<"HP" <<"HR" <<"HS" <<"HV" <<"HZ" \
           <<"I" <<"IS" <<"IS0" <<"J2" <<"J3" <<"J5" <<"J6" \
           <<"J7" <<"J8" <<"JA" <<"JDM" <<"JDO" <<"JT" <<"JW" \
           <<"JX" <<"JY" <<"K" <<"KG4" <<"KH0" <<"KH1" <<"KH2" <<"KH3" \
           <<"KH4" <<"KH5" <<"KH5K" <<"KH6" <<"KH7" <<"KH8" <<"KH9" <<"KL" \
           <<"KP1" <<"KP2" <<"KP4" <<"KP5" <<"LA" <<"LU" <<"LX" <<"LY" \
           <<"LZ" <<"OA" <<"OD" <<"OE" <<"OH" <<"OH0" <<"OJ0" <<"OK" \
           <<"OM" <<"ON" <<"OX" <<"OY" <<"OZ" <<"P2" <<"P4" <<"PA" \
           <<"PJ2" <<"PJ7" <<"PY" <<"PY0F" <<"PT0S" <<"PY0T" <<"PZ" <<"R1F" \
           <<"R1M" <<"S0" <<"S2" <<"S5" <<"S7" <<"S9" <<"SM" <<"SP" \
           <<"ST" <<"SU" <<"SV" <<"SVA" <<"SV5" <<"SV9" <<"T2" <<"T30" \
           <<"T31" <<"T32" <<"T33" <<"T5" <<"T7" <<"T8" <<"T9" <<"TA" \
           <<"TF" <<"TG" <<"TI" <<"TI9" <<"TJ" <<"TK" <<"TL" \
           <<"TN" <<"TR" <<"TT" <<"TU" <<"TY" <<"TZ" <<"UA" <<"UA2" \
           <<"UA9" <<"UK" <<"UN" <<"UR" <<"V2" <<"V3" <<"V4" <<"V5" \
           <<"V6" <<"V7" <<"V8" <<"VE" <<"VK" <<"VK0H" <<"VK0M" <<"VK9C" \
           <<"VK9L" <<"VK9M" <<"VK9N" <<"VK9W" <<"VK9X" <<"VP2E" <<"VP2M" <<"VP2V" \
           <<"VP5" <<"VP6" <<"VP6D" <<"VP8" <<"VP8G" <<"VP8H" <<"VP8O" <<"VP8S" \
           <<"VP9" <<"VQ9" <<"VR" <<"VU" <<"VU4" <<"VU7" <<"XE" <<"XF4" \
           <<"XT" <<"XU" <<"XW" <<"XX9" <<"XZ" <<"YA" <<"YB" <<"YI" \
           <<"YJ" <<"YK" <<"YL" <<"YN" <<"YO" <<"YS" <<"YU" <<"YV" \
           <<"YV0" <<"Z2" <<"Z3" <<"ZA" <<"ZB" <<"ZC4" <<"ZD7" <<"ZD8" \
           <<"ZD9" <<"ZF" <<"ZK1N" <<"ZK1S" <<"ZK2" <<"ZK3" <<"ZL" <<"ZL7" \
           <<"ZL8" <<"ZL9" <<"ZP" <<"ZS" <<"ZS8" <<"KC4" <<"E5";

  m_suffix << "P" << "0" << "1" << "2" << "3" << "4" << "5" << "6" \
           << "7" << "8" << "9" << "A";

  for(int i=0; i<12; i++) {
    m_sfx.insert(m_suffix[i],true);
  }
  for(int i=0; i<339; i++) {
    m_pfx.insert(m_prefix[i],true);
  }
}

bool MainWindow::shortList(QString callsign)
{
  int n=callsign.length();
  int i1=callsign.indexOf("/");
  Q_ASSERT(i1>0 and i1<n);
  QString t1=callsign.mid(0,i1);
  QString t2=callsign.mid(i1+1,n-i1-1);
  bool b=(m_pfx.contains(t1) or m_sfx.contains(t2));
  return b;
}

void MainWindow::pskSetLocal ()
{
  // find the station row, if any, that matches the band we are on
  auto stations = m_config.stations ();
  auto matches = stations->match (stations->index (0, StationList::band_column)
                                  , Qt::DisplayRole
                                  , ui->bandComboBox->currentText ()
                                  , 1
                                  , Qt::MatchExactly);
  QString antenna_description;
  if (!matches.isEmpty ()) {
    antenna_description = stations->index (matches.first ().row ()
                                           , StationList::description_column).data ().toString ();
  }
  psk_Reporter->setLocalStation(m_config.my_callsign (), m_config.my_grid (),
        antenna_description, QString {"WSJT-X v" + version() + " " +
        m_revision}.simplified ());
}

void MainWindow::transmitDisplay (bool transmitting)
{

  if (transmitting == m_transmitting) {
    if (transmitting) {
      ui->signal_meter_widget->setValue(0);
      if (m_monitoring) monitor (false);
      m_btxok=true;
    }

    auto QSY_allowed = !transmitting or m_config.tx_QSY_allowed () or
        !m_config.split_mode ();
    if (ui->cbTxLock->isChecked ()) {
      ui->RxFreqSpinBox->setEnabled (QSY_allowed);
      ui->pbT2R->setEnabled (QSY_allowed);
    }

    if(m_mode=="JT4" and (m_dialFreq/1000000 >= 432)) {
//    if(m_mode=="JT4") {
      ui->TxFreqSpinBox->setValue(1000);
      ui->TxFreqSpinBox->setEnabled (false);
      ui->cbTxLock->setChecked(false);
      ui->cbTxLock->setEnabled(false);
    } else if(m_mode!="WSPR") {
      ui->TxFreqSpinBox->setEnabled (QSY_allowed and !m_bFastMode);
      ui->pbR2T->setEnabled (QSY_allowed);
      ui->cbTxLock->setEnabled (QSY_allowed);
    }

      // the following are always disallowed in transmit
    ui->menuMode->setEnabled (!transmitting);
    ui->bandComboBox->setEnabled (!transmitting);
      if (!transmitting) {
        if ("JT9+JT65" == m_mode) {
              // allow mode switch in Rx when in dual mode
          ui->pbTxMode->setEnabled (true);
        }
      } else {
        ui->pbTxMode->setEnabled (false);
      }
  }
}

void MainWindow::on_sbFtol_valueChanged(int index)
{
  int tol[] = {10,20,50,100,200,500,1000};
  m_FtolIndex=index;
  m_Ftol=tol[index-21];
  m_wideGraph->setTol(m_Ftol);
}

void::MainWindow::VHF_controls_visible(bool b)
{
  ui->VHFControls_widget->setVisible (b);
}

void::MainWindow::VHF_features_enabled(bool b)
{
  if(!b and (ui->actionInclude_averaging->isChecked() or
             ui->actionInclude_correlation->isChecked())) {
    on_actionDeepestDecode_triggered();
  }
  ui->actionInclude_averaging->setEnabled(b);
  ui->actionInclude_correlation->setEnabled(b);
  ui->actionMessage_averaging->setEnabled(b);
  if(!b and m_msgAvgWidget!=NULL) {
    if(m_msgAvgWidget->isVisible()) m_msgAvgWidget->close();
  }
}

void MainWindow::on_cbEME_toggled(bool b)
{
  m_bEME=b;
}

void MainWindow::on_sbTR_valueChanged(int index)
{
  m_TRindex=index;
//  if(!m_bFastMode and n>m_nSubMode) m_MinW=m_nSubMode;
  if(m_bFastMode) {
    m_TRperiod=ui->sbTR->cleanText().toInt();
    if(m_TRperiod<5 or m_TRperiod>30) m_TRperiod=30;
    m_TRperiodFast=m_TRperiod;
    progressBar->setMaximum(m_TRperiod);
  }
  if(m_monitoring) {
    on_stopButton_clicked();
    on_monitorButton_clicked(true);
  }
  if(m_transmitting) {
    on_stopTxButton_clicked();
  }
  m_modulator->setPeriod(m_TRperiod); // TODO - not thread safe
  m_detector->setPeriod(m_TRperiod);  // TODO - not thread safe
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
}

void MainWindow::on_sbSubmode_valueChanged(int n)
{
  m_nSubMode=n;
  m_wideGraph->setSubMode(m_nSubMode);
  QString t1=(QString)QChar(short(m_nSubMode+65));
  mode_label->setText(m_mode + " " + t1);
  if(m_mode=="ISCAT") {
    if(m_nSubMode==0) ui->TxFreqSpinBox->setValue(1012);
    if(m_nSubMode==1) ui->TxFreqSpinBox->setValue(560);
  }
  if(m_mode=="JT9") {
    if(m_nSubMode<4) {
      ui->cbFast9->setChecked(false);
      on_cbFast9_clicked(false);
      ui->cbFast9->setEnabled(false);
      ui->sbTR->setVisible(false);
      m_TRperiod=60;
    } else {
      ui->cbFast9->setEnabled(true);
    }
    ui->sbTR->setVisible(m_bFast9);
    if(m_bFast9) ui->TxFreqSpinBox->setValue(700);
  }
  if(m_transmitting and m_bFast9 and m_nSubMode>=4) transmit(99.0);
}

void MainWindow::on_cbFast9_clicked(bool b)
{
  if(m_mode=="JT9") {
    m_bFast9=b;
    on_actionJT9_triggered();
  }

  if(b) {
/*
    if(m_mode!="JTMSK") {
      Q_EMIT m_config.transceiver_tx_frequency (0); // turn off split
    }
*/
    ui->cbEME->setText("Auto Seq");
    if(m_TRperiodFast>0) m_TRperiod=m_TRperiodFast;
  } else {
    ui->cbEME->setText("EME delay");
    m_TRperiod=60;
  }
  progressBar->setMaximum(m_TRperiod);
  m_wideGraph->setPeriod(m_TRperiod,m_nsps);
  fast_config(b);
}


void MainWindow::on_cbShMsgs_toggled(bool b)
{
  ui->cbTx6->setEnabled(b);
  m_bShMsgs=b;
  if(m_bShMsgs and m_mode=="JTMSK") ui->rptSpinBox->setValue(26);
  int itone0=itone[0];
  int ntx=m_ntx;
  genStdMsgs(m_rpt);
  itone[0]=itone0;
  if(ntx==1) ui->txrb1->setChecked(true);
  if(ntx==2) ui->txrb2->setChecked(true);
  if(ntx==3) ui->txrb3->setChecked(true);
  if(ntx==4) ui->txrb4->setChecked(true);
  if(ntx==5) ui->txrb5->setChecked(true);
  if(ntx==6) ui->txrb6->setChecked(true);
}

void MainWindow::on_cbTx6_toggled(bool b)
{
  QString t;
  if(b) {
    t="@1250  (SEND MSGS)";
  } else {
    t="@1000  (TUNE)";
  }
  ui->tx6->setText(t);
}

// Takes a decoded CQ line and sets it up for reply
void MainWindow::replyToCQ (QTime time, qint32 snr, float delta_time, quint32 delta_frequency, QString const& mode, QString const& message_text)
{
  if (!m_config.accept_udp_requests ())
    {
      return;
    }

  auto decode_parts = message_text.split (' ', QString::SkipEmptyParts);

  if (decode_parts.contains ("CQ") || decode_parts.contains ("QRZ"))
    {
      // a message we are willing to accept
      QString format_string {"%1 %2 %3 %4 %5 %6"};
      auto cqtext = format_string.arg (time.toString ("hhmm"))
                                                    .arg (snr, 3)
                                                    .arg (delta_time, 4, 'f', 1)
                                                    .arg (delta_frequency, 4)
                                                    .arg (mode)
                                                    .arg (message_text);
      auto messages = ui->decodedTextBrowser->toPlainText ();
      auto position = messages.lastIndexOf (cqtext);
      if (position < 0)
        {
          // try again with with -0.0 delta time
          position = messages.lastIndexOf (format_string.arg (time.toString ("hhmm"))
                                           .arg (snr, 3)
                                           .arg ('-' + QString::number (delta_time, 'f', 1), 4)
                                           .arg (delta_frequency, 4)
                                           .arg (mode)
                                           .arg (message_text));
        }
      if (position >= 0)
        {
          if (m_config.udpWindowToFront ())
            {
              show ();
              raise ();
              activateWindow ();
            }
          if (m_config.udpWindowRestore () && isMinimized ())
            {
              showNormal ();
              raise ();
            }
          // find the linefeed at the end of the line
          position = ui->decodedTextBrowser->toPlainText().indexOf("\n",position);
          processMessage (messages, position, false);
        }
      else
        {
          qDebug () << "reply to CQ request ignored, decode not found:" << cqtext;
        }
    }
  else
    {
      qDebug () << "rejecting UDP request to reply as decode is not a CQ or QRZ";
    }
}

void MainWindow::replayDecodes ()
{
  // we accept this request even if the setting to accept UDP requests
  // is not checked

  // attempt to parse the decoded text
  Q_FOREACH (auto const& message, ui->decodedTextBrowser->toPlainText ().split ('\n', QString::SkipEmptyParts))
    {
      if (message.size() >= 4 && message.left (4) != "----")
        {
          auto const& parts = message.split (' ', QString::SkipEmptyParts);
          if (parts.size () >= 5 && parts[3].contains ('.')) // WSPR
            {
              postWSPRDecode (false, parts);
            }
          else
            {
              auto eom_pos = message.indexOf (' ', 35);
              // we always want at least the characters to position 35
              if (eom_pos < 35)
                {
                  eom_pos = message.size () - 1;
                }
              postDecode (false, message.left (eom_pos + 1));
            }
        }
    }
  statusChanged ();
}

void MainWindow::postDecode (bool is_new, QString const& message)
{
  auto const& decode = message.trimmed ();
  auto const& parts = decode.left (21).split (' ', QString::SkipEmptyParts);
  if (parts.size () >= 5)
    {
      m_messageClient->decode (is_new, QTime::fromString (parts[0], "hhmm"), parts[1].toInt ()
                               , parts[2].toFloat (), parts[3].toUInt (), parts[4], decode.mid (21));
    }
}

void MainWindow::postWSPRDecode (bool is_new, QStringList parts)
{
  if (parts.size () < 8)
    {
      parts.insert (6, "");
    }
  m_messageClient->WSPR_decode (is_new, QTime::fromString (parts[0], "hhmm"), parts[1].toInt ()
                                , parts[2].toFloat (), Radio::frequency (parts[3].toFloat (), 6)
                                , parts[4].toInt (), parts[5].remove ("&lt;").remove ("&gt;")
                                , parts[6], parts[7].toInt ());
}

void MainWindow::networkError (QString const& e)
{
  if (QMessageBox::Retry == QMessageBox::warning (this, tr ("Network Error")
                                                  , tr ("Error: %1\nUDP server %2:%3")
                                                  .arg (e)
                                                  .arg (m_config.udp_server_name ())
                                                  .arg (m_config.udp_server_port ())
                                                  , QMessageBox::Cancel | QMessageBox::Retry, QMessageBox::Cancel))
    {
      // retry server lookup
      m_messageClient->set_server (m_config.udp_server_name ());
    }
}

void MainWindow::on_syncSpinBox_valueChanged(int n)
{
  m_minSync=n;
}

void MainWindow::p1ReadFromStderr()                        //p1readFromStderr
{
  QByteArray t=p1.readAllStandardError();
  msgBox(t);
}

void MainWindow::p1Error (QProcess::ProcessError e)
{
  if(!m_killAll) {
    msgBox("Error starting or running\n" + m_appDir + "/wsprd");
    qDebug() << e;                           // silence compiler warning
    exit(1);
  }
}

void MainWindow::p1ReadFromStdout()                        //p1readFromStdout
{
  QString t1;
  while(p1.canReadLine()) {
    QString t(p1.readLine());
    if(t.indexOf("<DecodeFinished>") >= 0) {
      m_bDecoded = m_nWSPRdecodes > 0;
      if(!m_diskData) {
        WSPR_history(m_dialFreqRxWSPR, m_nWSPRdecodes);
        if(m_nWSPRdecodes==0 and ui->band_hopping_group_box->isChecked()) {
          t = " Receiving " + m_mode + " ----------------------- " +
              m_config.bands ()->find (m_dialFreqRxWSPR);
          t=WSPR_hhmm(-60) + ' ' + t.rightJustified (66, '-');
          ui->decodedTextBrowser->appendText(t);
        }
        killFileTimer->start (45*1000); //Kill in 45s
      }
      m_nWSPRdecodes=0;
      ui->DecodeButton->setChecked (false);
      if(m_uploadSpots) {
        float x=qrand()/((double)RAND_MAX + 1.0);
        int msdelay=20000*x;
        uploadTimer->start(msdelay);                         //Upload delay
      } else {
        QFile f(QDir::toNativeSeparators(m_dataDir.absolutePath()) + "/wspr_spots.txt");
        if(f.exists()) f.remove();
      }
      m_RxLog=0;
      m_startAnother=m_loopall;
      m_blankLine=true;
      m_messageClient->status_update (m_dialFreq, m_mode, m_hisCall,
                                      QString::number (ui->rptSpinBox->value ()),
                                      m_modeTx, ui->autoButton->isChecked (),
                                      m_transmitting, (m_decoderBusy = false));
    } else {

      int n=t.length();
      t=t.mid(0,n-2) + "                                                  ";
      t.remove(QRegExp("\\s+$"));
      QStringList rxFields = t.split(QRegExp("\\s+"));
      QString rxLine;
      QString grid="";
      if ( rxFields.count() == 8 ) {
          rxLine = QString("%1 %2 %3 %4 %5   %6  %7  %8")
                  .arg(rxFields.at(0), 4)
                  .arg(rxFields.at(1), 4)
                  .arg(rxFields.at(2), 5)
                  .arg(rxFields.at(3), 11)
                  .arg(rxFields.at(4), 4)
                  .arg(rxFields.at(5).leftJustified (12).replace ('<', "&lt;").replace ('>', "&gt;"))
                  .arg(rxFields.at(6), -6)
                  .arg(rxFields.at(7), 3);
          postWSPRDecode (true, rxFields);
          grid = rxFields.at(6);
      } else if ( rxFields.count() == 7 ) { // Type 2 message
          rxLine = QString("%1 %2 %3 %4 %5   %6  %7  %8")
                  .arg(rxFields.at(0), 4)
                  .arg(rxFields.at(1), 4)
                  .arg(rxFields.at(2), 5)
                  .arg(rxFields.at(3), 11)
                  .arg(rxFields.at(4), 4)
                  .arg(rxFields.at(5).leftJustified (12).replace ('<', "&lt;").replace ('>', "&gt;"))
                  .arg("", -6)
                  .arg(rxFields.at(6), 3);
          postWSPRDecode (true, rxFields);
      } else {
          rxLine = t;
      }
      if(grid!="") {
        double utch=0.0;
        int nAz,nEl,nDmiles,nDkm,nHotAz,nHotABetter;
        azdist_(const_cast <char *> (m_config.my_grid ().toLatin1().constData()),
                const_cast <char *> (grid.toLatin1().constData()),&utch,
                &nAz,&nEl,&nDmiles,&nDkm,&nHotAz,&nHotABetter,6,6);
        QString t1;
        if(m_config.miles()) {
          t1.sprintf("%7d",nDmiles);
        } else {
          t1.sprintf("%7d",nDkm);
        }
        rxLine += t1;
      }

      if (m_config.insert_blank () && m_blankLine) {
        QString band;
        Frequency f=1000000.0*rxFields.at(3).toDouble()+0.5;
        band = ' ' + m_config.bands ()->find (f);
        ui->decodedTextBrowser->appendText(band.rightJustified (71, '-'));
        m_blankLine = false;
      }
      m_nWSPRdecodes += 1;
      ui->decodedTextBrowser->appendText(rxLine);
    }
  }
}

QString MainWindow::WSPR_hhmm(int n)
{
  QDateTime t=QDateTime::currentDateTimeUtc().addSecs(n);
  int m=t.toString("hhmm").toInt()/2;
  QString t1;
  t1.sprintf("%04d",2*m);
  return t1;
}

void MainWindow::WSPR_history(Frequency dialFreq, int ndecodes)
{
  QDateTime t=QDateTime::currentDateTimeUtc().addSecs(-60);
  QString t1=t.toString("yyMMdd");
  QString t2=WSPR_hhmm(-60);
  QString t3;
  t3.sprintf("%13.6f",0.000001*dialFreq);
  if(ndecodes<0) {
    t1=t1 + " " + t2 + t3 + "  T";
  } else {
    QString t4;
    t4.sprintf("%4d",ndecodes);
    t1=t1 + " " + t2 + t3 + "  R" + t4;
  }
  QFile f {m_dataDir.absoluteFilePath ("WSPR_history.txt")};
  if (f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
    QTextStream out(&f);
    out << t1 << endl;
    f.close();
  } else {
    msgBox("Cannot open \"" + f.fileName () + "\" for append:" + f.errorString ());
  }
}


void MainWindow::uploadSpots()
{
  if(m_diskData) return;
  if(m_uploading) {
    qDebug() << "Previous upload has not completed, spots were lost";
    wsprNet->abortOutstandingRequests ();
    m_uploading = false;
  }
  QString rfreq = QString("%1").arg(0.000001*(m_dialFreqRxWSPR + 1500), 0, 'f', 6);
  QString tfreq = QString("%1").arg(0.000001*(m_dialFreqRxWSPR +
                        ui->TxFreqSpinBox->value()), 0, 'f', 6);
  wsprNet->upload(m_config.my_callsign(), m_config.my_grid(), rfreq, tfreq,
                  m_mode, QString::number(ui->autoButton->isChecked() ? m_pctx : 0),
                  QString::number(m_dBm), version(),
                  QDir::toNativeSeparators(m_dataDir.absolutePath()) + "/wspr_spots.txt");
  m_uploading = true;
}

void MainWindow::uploadResponse(QString response)
{
  if (response == "done") {
    m_uploading=false;
  } else {
    if (response.startsWith ("Upload Failed")) {
      m_uploading=false;
    }
    qDebug () << "WSPRnet.org status:" << response;
  }
}


void MainWindow::p3ReadFromStdout()                        //p3readFromStdout
{
  QByteArray t=p3.readAllStandardOutput();
  if(t.length()>0) {
    msgBox("user_hardware stdout:\n\n"+t+"\n"+m_cmnd);
  }
}

void MainWindow::p3ReadFromStderr()                        //p3readFromStderr
{
  QByteArray t=p3.readAllStandardError();
  if(t.length()>0) {
    msgBox("user_hardware stderr:\n\n"+t+"\n"+m_cmnd);
  }
}

void MainWindow::p3Error(QProcess::ProcessError e)                                     //p3rror
{
  msgBox("Error attempting to run user_hardware.\n\n"+m_cmnd);
  qDebug() << e;                           // silence compiler warning
}


void MainWindow::on_TxPowerComboBox_currentIndexChanged(const QString &arg1)
{
  int i1=arg1.indexOf(" ");
  m_dBm=arg1.mid(0,i1).toInt();
}

void MainWindow::on_sbTxPercent_valueChanged(int n)
{
  m_pctx=n;
  if(m_pctx>0) {
    ui->pbTxNext->setEnabled(true);
  } else {
    m_txNext=false;
    ui->pbTxNext->setChecked(false);
    ui->pbTxNext->setEnabled(false);
  }
}

void MainWindow::on_cbUploadWSPR_Spots_toggled(bool b)
{
  m_uploadSpots=b;
  if(m_uploadSpots) ui->cbUploadWSPR_Spots->setStyleSheet("");
  if(!m_uploadSpots) ui->cbUploadWSPR_Spots->setStyleSheet(
        "QCheckBox{background-color: yellow}");
}

void MainWindow::on_WSPRfreqSpinBox_valueChanged(int n)
{
  ui->TxFreqSpinBox->setValue(n);
}

void MainWindow::on_pbTxNext_clicked(bool b)
{
  m_txNext=b;
}

void MainWindow::WSPR_scheduling ()
{
  m_WSPR_tx_next = false;
  if (ui->band_hopping_group_box->isChecked ()) {
    // qDebug () << "hop data: period:" << hop_data.period_name_
    // << "frequencies index:" << hop_data.frequencies_index_
    // << "tune:" << hop_data.tune_required_
    // << "tx:" << hop_data.tx_next_;
    auto hop_data = m_WSPR_band_hopping.next_hop (m_auto);
    m_WSPR_tx_next = hop_data.tx_next_;
    if (hop_data.frequencies_index_ >= 0) { // new band
      ui->bandComboBox->setCurrentIndex (hop_data.frequencies_index_);
      on_bandComboBox_activated (hop_data.frequencies_index_);
      m_cmnd.clear ();
      QStringList prefixes {".bat", ".cmd", ".exe", ""};
      for (auto const& prefix : prefixes)
        {
          auto const& path = m_appDir + "/user_hardware" + prefix;
          QFile f {path};
          if (f.exists ()) {
            m_cmnd = QDir::toNativeSeparators (f.fileName ()) + ' ' +
              m_config.bands ()->find (m_dialFreq).remove ('m');
          }
        }
      if(m_cmnd!="") p3.start(m_cmnd);     // Execute user's hardware controller

      // Produce a short tuneup signal
      m_tuneup = false;
      if (hop_data.tune_required_) {
        m_tuneup = true;
        on_tuneButton_clicked (true);
        tuneATU_Timer->start (2500);
      }
    }

    // Display grayline status
    auto_tx_label->setText (hop_data.period_name_);
  }
  else {
    m_WSPR_tx_next = m_WSPR_band_hopping.next_is_tx ();
  }
}

void MainWindow::DopplerTracking_toggled (bool enabled)
{
  if (!enabled) {
    // do one astro update and last adjustment
    astroCalculations (QDateTime::currentDateTimeUtc(), true);
  }
}

void MainWindow::astroCalculations (QDateTime const& time, bool adjust)
{
  if (m_astroWidget) {
    auto astro_correction = m_astroWidget->astroUpdate(time, m_config.my_grid(),
                 m_hisGrid, m_dialFreq, "Echo" == m_mode, m_transmitting);
    // Adjust frequency only if requested, allowed by mode, and freq > 50MHz.
    if (adjust && !m_bSimplex && (m_dialFreq >= 50000000) &&
        m_astroWidget->trackVFO()) {
      if(m_transmitting) {
        m_dialFreqTx = m_freqNominal + astro_correction;
        ui->labDialFreq->setText (Radio::pretty_frequency_MHz_string (m_dialFreqTx));
        Q_EMIT m_config.transceiver_tx_frequency (m_dialFreqTx);
      } else {
        m_dialFreq = m_freqNominal + astro_correction;
        ui->labDialFreq->setText (Radio::pretty_frequency_MHz_string (m_dialFreq));
        Q_EMIT m_config.transceiver_frequency(m_dialFreq);
      }
    }
//    qDebug() << "A" << 0.000001*m_dialFreq << 0.000001*m_dialFreqTx << astro_correction;
  }
}

void MainWindow::fastPick(int x0, int x1, int y)
{
  if(m_mode!="ISCAT") return;
  if(!m_decoderBusy) {
    dec_data.params.newdat=0;
    dec_data.params.nagain=1;
    m_blankLine=false;                 // don't insert the separator again
    m_nPick=1;
    if(y > 120) m_nPick=2;
    m_t0Pick=x0*512.0/12000.0;
    m_t1Pick=x1*512.0/12000.0;
    decode();
  }
}

void MainWindow::on_actionSave_reference_spectrum_triggered()
{
  msgBox("Reference spectrum not presently implemented");
}

void MainWindow::on_sbCQRxFreq_valueChanged(int n)
{
  m_freqCQ=n;
  genStdMsgs(m_rpt);
  CQRxFreq();
}

void MainWindow::on_cbCQRx_toggled(bool b)
{
  ui->sbCQRxFreq->setEnabled(b);
  genStdMsgs(m_rpt);
  if(b) {
    ui->txrb6->setChecked(true);
    m_ntx=6;
  }
  CQRxFreq();
}

void MainWindow::CQRxFreq()
{
  if(m_config.offsetRxFreq() and ui->cbCQRx->isChecked()) {
    int MHz=int(m_dialFreq/1000000);
    m_dialFreq = 1000000*MHz + 1000*m_freqCQ;
  } else {
    m_dialFreq = m_dialFreq0;
  }
  ui->labDialFreq->setText (Radio::pretty_frequency_MHz_string (m_dialFreq));
  Q_EMIT m_config.transceiver_frequency(m_dialFreq);
}

