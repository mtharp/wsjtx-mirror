//---------------------------------------------------------------- MainWindow
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "devsetup.h"
#include "plotter.h"
#include "about.h"
#include "widegraph.h"
#include "sleep.h"
#include "getfile.h"
#include <portaudio.h>

int itone[162];                       //Tx audio tones
bool btxok;                           //True if OK to transmit
bool btxMute;
double outputLatency;                 //Latency in seconds
WideGraph* g_pWideGraph = NULL;

QString ver="0.5";
QString rev="$Rev$";
QString Program_Title_Version="  WSPR-X   v" + ver + "  r" + rev.mid(6,4) +
                              "    by K1JT";
QString Version=ver + "_r" + rev.mid(6,4);

//-------------------------------------------------- MainWindow constructor
MainWindow::MainWindow(QWidget *parent) :
  QMainWindow(parent),
  ui(new Ui::MainWindow)
{
  ui->setupUi(this);

#ifdef WIN32
  freopen("wsprx.log","w",stderr);
#endif
  on_EraseButton_clicked();
  ui->labUTC->setStyleSheet( \
        "QLabel { background-color : \
        black; color : yellow; border: 3px ridge gray}");

  QActionGroup* paletteGroup = new QActionGroup(this);
  ui->actionCuteSDR->setActionGroup(paletteGroup);
  ui->actionLinrad->setActionGroup(paletteGroup);
  ui->actionAFMHot->setActionGroup(paletteGroup);
  ui->actionBlue->setActionGroup(paletteGroup);

  QActionGroup* modeGroup = new QActionGroup(this);
  ui->actionWSPR_2->setActionGroup(modeGroup);
  ui->actionWSPR_15->setActionGroup(modeGroup);
  ui->actionWSPR_30->setActionGroup(modeGroup);

  QActionGroup* saveGroup = new QActionGroup(this);
  ui->actionNone->setActionGroup(saveGroup);
  ui->actionSave_decoded->setActionGroup(saveGroup);
  ui->actionSave_all->setActionGroup(saveGroup);

  QActionGroup* BandGroup = new QActionGroup(this);
  ui->action2200_m->setActionGroup(BandGroup);
  ui->action630_m->setActionGroup(BandGroup);
  ui->action160_m->setActionGroup(BandGroup);
  ui->action80_m->setActionGroup(BandGroup);
  ui->action60_m->setActionGroup(BandGroup);
  ui->action40_m->setActionGroup(BandGroup);
  ui->action30_m->setActionGroup(BandGroup);
  ui->action20_m->setActionGroup(BandGroup);
  ui->action17_m->setActionGroup(BandGroup);
  ui->action15_m->setActionGroup(BandGroup);
  ui->action12_m->setActionGroup(BandGroup);
  ui->action10_m->setActionGroup(BandGroup);
  ui->action6_m->setActionGroup(BandGroup);
  ui->action4_m->setActionGroup(BandGroup);
  ui->action2_m->setActionGroup(BandGroup);
  ui->actionOther->setActionGroup(BandGroup);

  setWindowTitle(Program_Title_Version);
  connect(&soundInThread, SIGNAL(readyForFFT(int)),
             this, SLOT(dataSink(int)));
  connect(&soundInThread, SIGNAL(error(QString)), this,
          SLOT(showSoundInError(QString)));
  connect(&soundInThread, SIGNAL(status(QString)), this,
          SLOT(showStatusMessage(QString)));
  createStatusBar();

  connect(&proc_jt9, SIGNAL(readyReadStandardOutput()),
                    this, SLOT(readFromStdout()));

  connect(&proc_jt9, SIGNAL(error(QProcess::ProcessError)),
          this, SLOT(jt9_error()));

  connect(&proc_jt9, SIGNAL(readyReadStandardError()),
          this, SLOT(readFromStderr()));

  mNetworkManager = new QNetworkAccessManager(this);
  QObject::connect(mNetworkManager, SIGNAL(finished(QNetworkReply*)),
                   this, SLOT(onNetworkReply(QNetworkReply*)));

  QTimer *guiTimer = new QTimer(this);
  connect(guiTimer, SIGNAL(timeout()), this, SLOT(guiUpdate()));
  guiTimer->start(100);                            //Don't change the 100 ms!
  m_auto=false;
  m_waterfallAvg = 1;
  btxMute=false;
  btxok=false;
  m_restart=false;
  m_transmitting=false;
  m_myCall="K1JT";
  m_myGrid="FN20qi";
  m_appDir = QApplication::applicationDirPath();
  m_saveDir="/users/joe/wsprx/install/save";
  m_txFreq=1500;
  m_setftx=0;
  m_loopall=false;
  m_startAnother=false;
  m_saveDecoded=false;
  m_saveAll=false;
  m_sec0=-1;
  m_palette="CuteSDR";
  m_RxLog=1;                     //Write Date and Time to RxLog
  m_nutc0=9999;
  m_mode="WSPR-2";
  m_TRperiod=120;
  m_inGain=0;

  ui->xThermo->setFillBrush(Qt::green);

  PaError paerr=Pa_Initialize();                    //Initialize Portaudio
  if(paerr!=paNoError) {
    msgBox("Unable to initialize PortAudio.");
  }
  readSettings();		             //Restore user's setup params

  on_actionWide_Waterfall_triggered();                   //###
  g_pWideGraph->setTxFreq(m_txFreq);
  if(m_mode=="WSPR-2") on_actionWSPR_2_triggered();
  if(m_mode=="WSPR-10") on_actionWSPR_15_triggered();
  if(m_mode=="WSPR-30") on_actionWSPR_30_triggered();
  future1 = new QFuture<void>;
  watcher1 = new QFutureWatcher<void>;
  connect(watcher1, SIGNAL(finished()),this,SLOT(diskDat()));

  future2 = new QFuture<void>;
  watcher2 = new QFutureWatcher<void>;
  connect(watcher2, SIGNAL(finished()),this,SLOT(diskWriteFinished()));

  soundInThread.setInputDevice(m_paInDevice);
  soundInThread.start(QThread::HighestPriority);
  soundOutThread.setOutputDevice(m_paOutDevice);
  soundOutThread.setTxFreq(m_txFreq);
  soundInThread.setMonitoring(m_monitoring);
  m_diskData=false;

  if(ui->actionLinrad->isChecked()) on_actionLinrad_triggered();
  if(ui->actionCuteSDR->isChecked()) on_actionCuteSDR_triggered();
  if(ui->actionAFMHot->isChecked()) on_actionAFMHot_triggered();
  if(ui->actionBlue->isChecked()) on_actionBlue_triggered();
}                                          // End of MainWindow constructor

//--------------------------------------------------- MainWindow destructor
MainWindow::~MainWindow()
{
  writeSettings();
  if (soundInThread.isRunning()) {
    soundInThread.quit();
    soundInThread.wait(3000);
  }
  if (soundOutThread.isRunning()) {
    soundOutThread.quitExecution=true;
    soundOutThread.wait(3000);
  }
  delete ui;
}

//-------------------------------------------------------- writeSettings()
void MainWindow::writeSettings()
{
  QString inifile = m_appDir + "/wsprx.ini";
  QSettings settings(inifile, QSettings::IniFormat);

  settings.beginGroup("MainWindow");
  settings.setValue("geometry", saveGeometry());
  settings.setValue("MRUdir", m_path);
  if(g_pWideGraph->isVisible()) {
    m_wideGraphGeom = g_pWideGraph->geometry();
    settings.setValue("WideGraphGeom",m_wideGraphGeom);
  }
  settings.endGroup();

  settings.beginGroup("Common");
  settings.setValue("MyCall",m_myCall);
  settings.setValue("MyGrid",m_myGrid);
  settings.setValue("IDint",m_idInt);
  settings.setValue("PTTport",m_pttPort);
  settings.setValue("SaveDir",m_saveDir);
  settings.setValue("SoundInIndex",m_nDevIn);
  settings.setValue("paInDevice",m_paInDevice);
  settings.setValue("SoundOutIndex",m_nDevOut);
  settings.setValue("paOutDevice",m_paOutDevice);
  settings.setValue("PaletteCuteSDR",ui->actionCuteSDR->isChecked());
  settings.setValue("PaletteLinrad",ui->actionLinrad->isChecked());
  settings.setValue("PaletteAFMHot",ui->actionAFMHot->isChecked());
  settings.setValue("PaletteBlue",ui->actionBlue->isChecked());
  settings.setValue("Mode",m_mode);
  settings.setValue("SaveNone",ui->actionNone->isChecked());
  settings.setValue("SaveDecoded",ui->actionSave_decoded->isChecked());
  settings.setValue("SaveAll",ui->actionSave_all->isChecked());
  settings.setValue("NBslider",m_NBslider);
  settings.setValue("TxFreq",m_txFreq);
  settings.setValue("InGain",m_inGain);
  settings.endGroup();
}

//---------------------------------------------------------- readSettings()
void MainWindow::readSettings()
{
  QString inifile = m_appDir + "/wsprx.ini";
  QSettings settings(inifile, QSettings::IniFormat);
  settings.beginGroup("MainWindow");
  restoreGeometry(settings.value("geometry").toByteArray());
  m_wideGraphGeom = settings.value("WideGraphGeom", \
                                   QRect(45,30,726,301)).toRect();
  m_path = settings.value("MRUdir", m_appDir + "/save").toString();
  settings.endGroup();

  settings.beginGroup("Common");
  m_myCall=settings.value("MyCall","").toString();
  m_myGrid=settings.value("MyGrid","").toString();
  m_idInt=settings.value("IDint",0).toInt();
  m_pttPort=settings.value("PTTport",0).toInt();
  m_saveDir=settings.value("SaveDir",m_appDir + "/save").toString();
  m_nDevIn = settings.value("SoundInIndex", 0).toInt();
  m_paInDevice = settings.value("paInDevice",0).toInt();
  m_nDevOut = settings.value("SoundOutIndex", 0).toInt();
  m_paOutDevice = settings.value("paOutDevice",0).toInt();
  ui->actionCuteSDR->setChecked(settings.value(
                                  "PaletteCuteSDR",true).toBool());
  ui->actionLinrad->setChecked(settings.value(
                                 "PaletteLinrad",false).toBool());
  ui->actionAFMHot->setChecked(settings.value(
                                 "PaletteAFMHot",false).toBool());
  ui->actionBlue->setChecked(settings.value(
                                 "PaletteBlue",false).toBool());
  m_mode=settings.value("Mode","WSPR-2").toString();
  ui->actionNone->setChecked(settings.value("SaveNone",true).toBool());
  ui->actionSave_decoded->setChecked(settings.value(
                                         "SaveDecoded",false).toBool());
  ui->actionSave_all->setChecked(settings.value("SaveAll",false).toBool());
  m_NBslider=settings.value("NBslider",40).toInt();
  m_txFreq=settings.value("TxFreq",1500).toInt();
  soundOutThread.setTxFreq(m_txFreq);
  m_saveDecoded=ui->actionSave_decoded->isChecked();
  m_saveAll=ui->actionSave_all->isChecked();
  m_inGain=settings.value("InGain",0).toInt();
  ui->inGain->setValue(m_inGain);
  settings.endGroup();

  if(!ui->actionLinrad->isChecked() && !ui->actionCuteSDR->isChecked() &&
    !ui->actionAFMHot->isChecked() && !ui->actionBlue->isChecked()) {
    on_actionLinrad_triggered();
    ui->actionLinrad->setChecked(true);
  }
}

//-------------------------------------------------------------- dataSink()
void MainWindow::dataSink(int k)
{
  static float s[NSMAX],red[NSMAX];
  static int ihsym=0;
  static int nzap=0;
  static int nb;
  static int trmin;
  static int npts8;
  static float px=0.0;
  static float df3;
  static uchar lstrong[1024];
  static float slimit;

  if(m_diskData) {
    jt9com_.ndiskdat=1;
  } else {
    jt9com_.ndiskdat=0;
  }

// Get power, spectrum, and ihsym
  nb=0;
  trmin=m_TRperiod/60;
  symspec_(&k, &trmin, &m_nsps, &m_inGain, &nb, &m_NBslider, &px, s, red,
           &df3, &ihsym, &nzap, &slimit, lstrong, &npts8);
  if(ihsym <=0) return;
  QString t;
  t.sprintf(" Receiving: %5.1f dB ",px);
  lab1->setText(t);
  ui->xThermo->setValue((double)px);                    //Update thermometer
  if(m_monitoring || m_diskData) {
    g_pWideGraph->dataSink2(s,red,df3,ihsym,m_diskData,lstrong);
  }

  if(ihsym == m_hsymStop) {
    jt9com_.npts8=(ihsym*m_nsps)/16;
    jt9com_.newdat=1;
    jt9com_.nagain=0;
    jt9com_.nzhsym=m_hsymStop;
    QDateTime t = QDateTime::currentDateTimeUtc();
    m_dateTime=t.toString("yyyy-MMM-dd hh:mm");
//    decode();                                                //Start decoder
    if(!m_diskData) {                        //Always save; may delete later
      int ihr=t.time().toString("hh").toInt();
      int imin=t.time().toString("mm").toInt();
      imin=imin - (imin%(m_TRperiod/60));
      QString t2;
      t2.sprintf("%2.2d%2.2d",ihr,imin);
      m_fname=m_saveDir + "/" + t.date().toString("yyMMdd") + "_" +
            t2 + ".wav";
      *future2 = QtConcurrent::run(savewav, m_fname, m_TRperiod);
      watcher2->setFuture(*future2);
    }
//    decode();                                                //Start decoder
    m_decodedList.clear();
    QString cmnd='"' + m_appDir + '"' + "/wspr0 D 0.474200 " + m_fname + '"';
    lab3->setStyleSheet("QLabel{background-color:cyan}");
    lab3->setText("Decoding");
    proc_jt9.start(QDir::toNativeSeparators(cmnd));
  }
  soundInThread.m_dataSinkBusy=false;
}

void MainWindow::showSoundInError(const QString& errorMsg)
 {QMessageBox::critical(this, tr("Error in SoundIn"), errorMsg);}

void MainWindow::showStatusMessage(const QString& statusMsg)
 {statusBar()->showMessage(statusMsg);}

void MainWindow::on_actionDeviceSetup_triggered()               //Setup Dialog
{
  DevSetup dlg(this);
  dlg.m_myCall=m_myCall;
  dlg.m_myGrid=m_myGrid;
  dlg.m_idInt=m_idInt;
  dlg.m_pttPort=m_pttPort;
  dlg.m_saveDir=m_saveDir;
  dlg.m_nDevIn=m_nDevIn;
  dlg.m_nDevOut=m_nDevOut;

  dlg.initDlg();
  if(dlg.exec() == QDialog::Accepted) {
    m_myCall=dlg.m_myCall;
    m_myGrid=dlg.m_myGrid;
    m_idInt=dlg.m_idInt;
    m_pttPort=dlg.m_pttPort;
    m_saveDir=dlg.m_saveDir;
    m_nDevIn=dlg.m_nDevIn;
    m_paInDevice=dlg.m_paInDevice;
    m_nDevOut=dlg.m_nDevOut;
    m_paOutDevice=dlg.m_paOutDevice;

    if(dlg.m_restartSoundIn) {
      soundInThread.quit();
      soundInThread.wait(1000);
      soundInThread.setInputDevice(m_paInDevice);
      soundInThread.start(QThread::HighestPriority);
    }

    if(dlg.m_restartSoundOut) {
      soundOutThread.quitExecution=true;
      soundOutThread.wait(1000);
      soundOutThread.setOutputDevice(m_paOutDevice);
    }
  }
}

void MainWindow::on_actionLinrad_triggered()                 //Linrad palette
{
  if(g_pWideGraph != NULL) g_pWideGraph->setPalette("Linrad");
}

void MainWindow::on_actionCuteSDR_triggered()                //CuteSDR palette
{
  if(g_pWideGraph != NULL) g_pWideGraph->setPalette("CuteSDR");
}

void MainWindow::on_actionAFMHot_triggered()
{
  if(g_pWideGraph != NULL) g_pWideGraph->setPalette("AFMHot");
}

void MainWindow::on_actionBlue_triggered()
{
  if(g_pWideGraph != NULL) g_pWideGraph->setPalette("Blue");
}

void MainWindow::on_actionAbout_triggered()                  //Display "About"
{
  CAboutDlg dlg(this,Program_Title_Version);
  dlg.exec();
}

void MainWindow::keyPressEvent( QKeyEvent *e )                //keyPressEvent
{
  switch(e->key())
  {
  case Qt::Key_F3:
    btxMute=!btxMute;
    break;
  case Qt::Key_F6:
    if(e->modifiers() & Qt::ShiftModifier) {
      on_actionDecode_remaining_files_in_directory_triggered();
    }
    break;
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
  lab1 = new QLabel("Receiving");
  lab1->setAlignment(Qt::AlignHCenter);
  lab1->setMinimumSize(QSize(85,18));
  lab1->setStyleSheet("QLabel{background-color: #00ff00}");
  lab1->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(lab1);

  lab2 = new QLabel("");
  lab2->setAlignment(Qt::AlignHCenter);
  lab2->setMinimumSize(QSize(60,18));
  lab2->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(lab2);

  lab3 = new QLabel("");
  lab3->setAlignment(Qt::AlignHCenter);
  lab3->setMinimumSize(QSize(80,18));
  lab3->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(lab3);
}

void MainWindow::on_actionExit_triggered()                     //Exit()
{
  OnExit();
}

void MainWindow::closeEvent(QCloseEvent*)
{
  OnExit();
}

void MainWindow::OnExit()
{
  g_pWideGraph->saveSettings();
  qApp->exit(0);                                      // Exit the event loop
}

void MainWindow::msgBox(QString t)                             //msgBox
{
  msgBox0.setText(t);
  msgBox0.exec();
}

void MainWindow::on_actionOnline_Users_Guide_triggered()      //Display manual
{
  QDesktopServices::openUrl(QUrl(
  "http://www.physics.princeton.edu/pulsar/K1JT/WSPR_3.0_User.pdf",
                              QUrl::TolerantMode));
}

void MainWindow::on_actionWide_Waterfall_triggered()      //Display Waterfalls
{
  if(g_pWideGraph==NULL) {
    g_pWideGraph = new WideGraph(0);
    g_pWideGraph->setWindowTitle("WSPR-X Waterfall");
    g_pWideGraph->setGeometry(m_wideGraphGeom);
    Qt::WindowFlags flags = Qt::WindowCloseButtonHint |
        Qt::WindowMinimizeButtonHint;
    g_pWideGraph->setWindowFlags(flags);
  }
  g_pWideGraph->show();
}

void MainWindow::on_actionOpen_triggered()                     //Open File
{
  m_monitoring=false;
  soundInThread.setMonitoring(m_monitoring);
  QString fname;
  fname=QFileDialog::getOpenFileName(this, "Open File", m_path,
                                       "WSJT Files (*.wav)");
  if(fname != "") {
    m_path=fname;
    int i;
    i=fname.indexOf(".wav") - 11;
    if(i>=0) {
      lab1->setStyleSheet("QLabel{background-color: #66ff66}");
      lab1->setText(" " + fname.mid(i,15) + " ");
    }
//    on_stopButton_clicked();
    m_diskData=true;
    *future1 = QtConcurrent::run(getfile, fname, m_TRperiod);
    watcher1->setFuture(*future1);         // call diskDat() when done
  }
}

void MainWindow::on_actionOpen_next_in_directory_triggered()   //Open Next
{
  int i,len;
  QFileInfo fi(m_path);
  QStringList list;
  list= fi.dir().entryList().filter(".wav");
  for (i = 0; i < list.size()-1; ++i) {
    if(i==list.size()-2) m_loopall=false;
    len=list.at(i).length();
    if(list.at(i)==m_path.right(len)) {
      int n=m_path.length();
      QString fname=m_path.replace(n-len,len,list.at(i+1));
      m_path=fname;
      int i;
      i=fname.indexOf(".wav") - 11;
      if(i>=0) {
        lab1->setStyleSheet("QLabel{background-color: #66ff66}");
        lab1->setText(" " + fname.mid(i,len) + " ");
      }
      m_diskData=true;
      *future1 = QtConcurrent::run(getfile, fname, m_TRperiod);
      watcher1->setFuture(*future1);
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
  int kstep=m_nsps/2;
  m_diskData=true;
  for(int n=1; n<=m_hsymStop; n++) {              // Do the half-symbol FFTs
    k=(n+1)*kstep;
    jt9com_.npts8=k/8;
    dataSink(k);
    if(n%10 == 1 or n == m_hsymStop)
        qApp->processEvents();                   //Keep GUI responsive
  }
}

void MainWindow::diskWriteFinished()                       //diskWriteFinished
{
}

//Delete ../save/*.wav
void MainWindow::on_actionDelete_all_wav_files_in_SaveDir_triggered()
{
  int i;
  QString fname;
  int ret = QMessageBox::warning(this, "Confirm Delete",
      "Are you sure you want to delete all *.wav files in\n" +
       QDir::toNativeSeparators(m_saveDir) + " ?",
       QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
  if(ret==QMessageBox::Yes) {
    QDir dir(m_saveDir);
    QStringList files=dir.entryList(QDir::Files);
    QList<QString>::iterator f;
    for(f=files.begin(); f!=files.end(); ++f) {
      fname=*f;
      i=(fname.indexOf(".wav"));
      if(i>10) dir.remove(fname);
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

void MainWindow::jt9_error()                                     //jt9_error
{
  msgBox("Error starting or running\n" + m_appDir + "/wspr0");
//  exit(1);
}

void MainWindow::readFromStderr()                             //readFromStderr
{
  QByteArray t=proc_jt9.readAllStandardError();
  msgBox(t);
}

void MainWindow::readFromStdout()                             //readFromStdout
{
  QString t1;
  while(proc_jt9.canReadLine()) {
    QString t(proc_jt9.readLine());
    if(t.indexOf("<DecodeFinished>") >= 0) {
      for(int i=0; i<m_decodedList.size(); i++) {
        t1=m_decodedList.at(i).toAscii();
        QStringList s=t1.split(" ",QString::SkipEmptyParts);
        int iutc=s.at(0).toInt();
        int sig=s.at(1).toInt();
        float dt=s.at(2).toFloat();
        double rqrg=s.at(3).toDouble();
        int drift=s.at(4).toInt();
        QString rcall=s.at(5).toAscii();
        QString rgrid=s.at(6).toAscii();
        int dbm=s.at(6).toInt();
//        qDebug() << i << iutc << sig << dt << rqrg << drift << rcall
//                    << rgrid << dbm;
        // Upload to WSPRnet here ...
      }
      m_decodedList.clear();

//      m_bdecoded = (t.mid(23,1).toInt()==1);
      bool keepFile=m_saveAll or (m_saveDecoded and m_bdecoded);
      if(!keepFile) {
        QFile savedFile(m_fname);
        savedFile.remove();
      }
      lab3->setStyleSheet("");
      lab3->setText("");
      m_RxLog=0;
      m_startAnother=m_loopall;
      return;
    } else {
      m_decodedList += t;
      int n=t.length();
      t=t.mid(0,n-2) + "                                                  ";
      ui->decodedTextBrowser->append(t);
    }
  }
}

void MainWindow::on_EraseButton_clicked()                          //Erase
{
  ui->decodedTextBrowser->clear();
}

//------------------------------------------------------------- //guiUpdate()
void MainWindow::guiUpdate()
{
  static int iptt0=0;
  static int iptt=0;
  static bool btxok0=false;
  static int nc0=1;
  static int nc1=1;
  static char message[29];
  static char msgsent[29];
  static int nsendingsh=0;
  int khsym=0;

  double tx1=0.0;
//  double tx2=m_TRperiod;
  double tx2=1.0 + 85.0*m_nsps/12000.0;

  qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
  int nsec=ms/1000;
  double tsec=0.001*ms;
  double t2p=fmod(tsec,2*m_TRperiod);
  bool bTxTime = (t2p >= tx1) && (t2p < tx2);

  if(m_auto) {

    QFile f("txboth");
    if(f.exists() and fmod(tsec,m_TRperiod)<1.0 + 85.0*m_nsps/12000.0)
      bTxTime=true;

    if(bTxTime and iptt==0 and !btxMute) {
      int itx=1;
      ptt(m_pttPort,itx,&iptt);       // Raise PTT
      if(!soundOutThread.isRunning()) {
        double snr=99.0;
        soundOutThread.setTxSNR(snr);
        soundOutThread.start(QThread::HighPriority);
      }
    }
    if(!bTxTime || btxMute) {
      btxok=false;
    }
  }

// Calculate Tx waveform when needed
  if((iptt==1 && iptt0==0) || m_restart) {
    QByteArray ba;

//    ba2msg(ba,message);
//    ba2msg(ba,msgsent);
//    int len1=22;
//    genjt9_(message,&ichk,msgsent,itone,&itext,len1,len1);
    msgsent[22]=0;
    lab5->setText("Last Tx:  " + QString::fromAscii(msgsent));
    if(m_restart) {
      QFile f("wsprx_tx.log");
      f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append);
      QTextStream out(&f);
      out << QDateTime::currentDateTimeUtc().toString("yyyy-MMM-dd hh:mm")
          << "  Tx message:  " << QString::fromAscii(msgsent) << endl;
      f.close();

    }

    m_restart=false;
  }

// If PTT was just raised, start a countdown for raising TxOK:
  if(iptt==1 && iptt0==0) nc1=-9;    // TxDelay = 0.8 s
  if(nc1 <= 0) nc1++;
  if(nc1 == 0) {
    ui->xThermo->setValue(0.0);   //Set Thermo to zero
    m_monitoring=false;
    soundInThread.setMonitoring(false);
    btxok=true;
    m_transmitting=true;

    QFile f("wsprx_tx.log");
    f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append);
    QTextStream out(&f);
    out << QDateTime::currentDateTimeUtc().toString("yyyy-MMM-dd hh:mm")
        << "  Tx message:  " << QString::fromAscii(msgsent) << endl;
    f.close();
  }

// If btxok was just lowered, start a countdown for lowering PTT
  if(!btxok && btxok0 && iptt==1) nc0=-11;  //RxDelay = 1.0 s
  if(nc0 <= 0) {
    nc0++;
  }
  if(nc0 == 0) {
    int itx=0;
    ptt(m_pttPort,itx,&iptt);       // Lower PTT
    if(!btxMute) soundOutThread.quitExecution=true;
    m_transmitting=false;
    if(m_auto) {
      m_monitoring=true;
      soundInThread.setMonitoring(m_monitoring);
    }
  }

  if(iptt == 0 && !btxok) {
    // sending=""
    // nsendingsh=0
  }

  if(m_monitoring) {
//    ui->monitorButton->setStyleSheet(m_pbmonitor_style);
  } else {
//    ui->monitorButton->setStyleSheet("");
  }

  if(m_startAnother) {
    m_startAnother=false;
    on_actionOpen_next_in_directory_triggered();
  }

  if(nsec != m_sec0) {                                     //Once per second
    QDateTime t = QDateTime::currentDateTimeUtc();
    if(m_transmitting) {
      if(nsendingsh==1) {
        lab1->setStyleSheet("QLabel{background-color: #66ffff}");
      } else if(nsendingsh==-1) {
        lab1->setStyleSheet("QLabel{background-color: #ffccff}");
      } else {
        lab1->setStyleSheet("QLabel{background-color: #ffff33}");
      }
      char s[37];
      sprintf(s,"Tx: %s",msgsent);
      lab1->setText(s);
    } else if(m_monitoring) {
      lab1->setStyleSheet("QLabel{background-color: #00ff00}");
//      lab1->setText("Receiving ");
    } else if (!m_diskData) {
      lab1->setStyleSheet("");
      lab1->setText("");
    }

    m_setftx=0;
    QString utc = t.date().toString("yyyy MMM dd") + " \n " +
            t.time().toString();
    ui->labUTC->setText(utc);
    if(!m_monitoring and !m_diskData) {
      ui->xThermo->setValue(0.0);
    }
    m_hsym0=khsym;
    m_sec0=nsec;
  }
  iptt0=iptt;
  btxok0=btxok;
}


                                                       //doubleClickOnCall
void MainWindow::on_actionWSPR_2_triggered()
{
  m_mode="WSPR-2";
  m_TRperiod=120;
  m_nsps=15360;
  m_hsymStop=178;
  soundInThread.setPeriod(m_TRperiod,m_nsps);
  soundOutThread.setPeriod(m_TRperiod,m_nsps);
  g_pWideGraph->setPeriod(m_TRperiod,m_nsps);
  lab2->setStyleSheet("QLabel{background-color: #ffff00}");
  lab2->setText("WSPR-2");
  ui->actionWSPR_2->setChecked(true);
}

void MainWindow::on_actionWSPR_15_triggered()
{
  m_mode="WSPR-15";
  m_TRperiod=900;
  m_nsps=82944;
  m_hsymStop=171;
  soundInThread.setPeriod(m_TRperiod,m_nsps);
  soundOutThread.setPeriod(m_TRperiod,m_nsps);
  g_pWideGraph->setPeriod(m_TRperiod,m_nsps);
  lab2->setStyleSheet("QLabel{background-color: #7fff00}");
  lab2->setText("WSPR-15");
  ui->actionWSPR_15->setChecked(true);
}

void MainWindow::on_actionWSPR_30_triggered()
{
  m_mode="WSPR-30";
  m_TRperiod=1800;
  m_nsps=252000;
  m_hsymStop=167;
  soundInThread.setPeriod(m_TRperiod,m_nsps);
  soundOutThread.setPeriod(m_TRperiod,m_nsps);
  g_pWideGraph->setPeriod(m_TRperiod,m_nsps);
  lab2->setStyleSheet("QLabel{background-color: #97ffff}");
  lab2->setText("WSPR-30");
  ui->actionWSPR_30->setChecked(true);
}

void MainWindow::on_inGain_valueChanged(int n)
{
  m_inGain=n;
}

void MainWindow::on_TxNextButton_clicked()
{
  QString t("http://wsprnet.org/post?function=wsprstat&rcall=K1JT&");
  t += "rgrid=FN20qi&rqrg=10.140200&tpct=0&tqrg=10.140200&dbm=20&";
  t += "version=" + Version;
  QUrl url(t);
//  qDebug() << "A" << t;
  reply = mNetworkManager->get(QNetworkRequest(url));
}

void MainWindow::onNetworkReply(QNetworkReply* reply)
{
  qDebug() << "B" << reply->error();
  QString replyString;
  if(reply->error() == QNetworkReply::NoError) {
    int httpstatuscode = reply->attribute(
          QNetworkRequest::HttpStatusCodeAttribute).toUInt();
    qDebug() << "C" << httpstatuscode;
    switch(httpstatuscode)
    {
    case 0:                                   //RESPONSE_OK:
      if (reply->isReadable()) {
  //Assuming this is a human readable file replyString now contains the file
        replyString = QString::fromUtf8(reply->readAll().data());
        qDebug() << "D" << replyString;
      }
      break;
    default:
      //httpstatuscode is nonzero...
      break;
    }
  }
  reply->deleteLater();
}
