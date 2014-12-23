//------------------------------------------------------------- MainWindow
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "devsetup.h"
#include "plotter.h"
#include "about.h"
#include "astro.h"
#include "widegraph.h"
#include "echospec.h"
#include "portaudio.h"

extern "C" {
  void   fil4_(qint16*, qint32*, qint16*, qint32*);
}

int itone[162];                       //Tx audio tones
int icw[250];                         //Dits for CW ID
bool btxok;                           //True if OK to transmit
bool btxMute;
double inputLatency;                  //Latency in seconds
double outputLatency;                 //Latency in seconds

Astro*     g_pAstro = NULL;
WideGraph* g_pWideGraph = NULL;
FILE*      fp = NULL;

QString ver="0.5";
QString rev="$Rev$";
QString Program_Title_Version="  EMEcho   v" + ver + "  r" + rev.mid(6,4) +
                              "    by K1JT";
QString Version=ver + "_r" + rev.mid(6,4);

//-------------------------------------------------- MainWindow constructor
MainWindow::MainWindow(QWidget *parent) :
  QMainWindow(parent),
  ui(new Ui::MainWindow)
{
  ui->setupUi(this);

  on_eraseButton_clicked();
  ui->labUTC->setStyleSheet( \
        "QLabel { background-color : \
        black; color : yellow; border: 3px ridge gray}");

  setWindowTitle(Program_Title_Version);
  connect(&soundInThread, SIGNAL(dataReady(int)),this, SLOT(dataSink()));
  connect(&soundInThread, SIGNAL(error(QString)), this,
          SLOT(showSoundInError(QString)));
  connect(&soundInThread, SIGNAL(status(QString)), this,
          SLOT(showStatusMessage(QString)));
  connect(&soundOutThread, SIGNAL(endTx()),this, SLOT(stopTx()));

  createStatusBar();

  connect(&p1, SIGNAL(readyReadStandardOutput()),
                    this, SLOT(p1ReadFromStdout()));
  connect(&p1, SIGNAL(readyReadStandardError()),
          this, SLOT(p1ReadFromStderr()));
  connect(&p1, SIGNAL(error(QProcess::ProcessError)),
          this, SLOT(p1Error()));

  connect(&p3, SIGNAL(readyReadStandardOutput()),
                    this, SLOT(p3ReadFromStdout()));
  connect(&p3, SIGNAL(readyReadStandardError()),
          this, SLOT(p3ReadFromStderr()));
  connect(&p3, SIGNAL(error(QProcess::ProcessError)),
          this, SLOT(p3Error()));

  QTimer *guiTimer = new QTimer(this);
  connect(guiTimer, SIGNAL(timeout()), this, SLOT(guiUpdate()));
  guiTimer->start(10);
  ptt0Timer = new QTimer(this);
  ptt0Timer->setSingleShot(true);
  connect(ptt0Timer, SIGNAL(timeout()), this, SLOT(stopTx2()));
  ptt1Timer = new QTimer(this);
  ptt1Timer->setSingleShot(true);
  connect(ptt1Timer, SIGNAL(timeout()), this, SLOT(startTx2()));

  m_auto=false;
  btxMute=false;
  btxok=false;
  m_Costas=0;
  m_transmitting=false;
  m_network=false;
  m_diskData=false;
  m_transmitted=false;
  m_myGrid="FN20qi";
  m_appDir = QApplication::applicationDirPath();
  m_saveDir = m_appDir + "/save";
  m_txFreq=1500;
  m_sec0=-1;
  m_inGain=0;
  m_RxOK=true;
  m_TxOK=false;
  m_grid6=false;
  m_loopall=0;
  m_band=3;
  m_rig=-1;
  m_iptt=0;
  m_COMportOpen=0;

  signalMeter = new SignalMeter(ui->meterFrame);
  signalMeter->resize(50, 160);

  PaError paerr=Pa_Initialize();                    //Initialize Portaudio
  if(paerr!=paNoError) {
    msgBox("Unable to initialize PortAudio.");
  }
  readSettings();		             //Restore user's setup params

  on_actionWide_Waterfall_triggered();                   //###
  on_actionAstronomical_data_triggered();
  g_pAstro->setFontSize(m_astroFont);

  future1 = new QFuture<bool>;
  watcher1 = new QFutureWatcher<void>;
  connect(watcher1, SIGNAL(finished()),this,SLOT(specReady()));

  m_txEnable_style="QPushButton{background-color: #ff0000; \
      border-style: outset; border-width: 1px; border-radius: 3px; \
      border-color: black; padding: 4px;}";
  soundInThread.setNetwork(m_network);
  soundInThread.setInputDevice(m_paInDevice);
  soundInThread.start(QThread::HighestPriority);

  soundOutThread.setOutputDevice(m_paOutDevice);
  soundOutThread.setTxFreq(m_txFreq);
  soundOutThread.setCostas(m_Costas);
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
    soundOutThread.quit();
    soundOutThread.wait(3000);
  }
  delete ui;
}

//-------------------------------------------------------- writeSettings()
void MainWindow::writeSettings()
{
  QString inifile = m_appDir + "/emecho.ini";
  QSettings settings(inifile, QSettings::IniFormat);

  settings.beginGroup("MainWindow");
  settings.setValue("geometry", saveGeometry());
  settings.setValue("MRUdir", m_path);

  if(g_pAstro->isVisible()) {
    m_astroGeom = g_pAstro->geometry();
    settings.setValue("AstroGeom",m_astroGeom);
  }

  if(g_pWideGraph->isVisible()) {
    m_wideGraphGeom = g_pWideGraph->geometry();
    settings.setValue("WideGraphGeom",m_wideGraphGeom);
  }
  settings.endGroup();

  settings.beginGroup("Common");
  settings.setValue("MyGrid",m_myGrid);
  settings.setValue("PTTmethod",m_pttMethodIndex);
  settings.setValue("PTTport",m_pttPort);
  settings.setValue("SaveDir",m_saveDir);
  settings.setValue("AstroFont",m_astroFont);
  settings.setValue("SoundInIndex",m_nDevIn);
  settings.setValue("paInDevice",m_paInDevice);
  settings.setValue("SoundOutIndex",m_nDevOut);
  settings.setValue("paOutDevice",m_paOutDevice);
  settings.setValue("Mode",m_mode);
  settings.setValue("TxFreq",m_txFreq);
  settings.setValue("InGain",m_inGain);
  settings.setValue("TxEnable",m_TxOK);
  settings.setValue("Grid6",m_grid6);
  settings.setValue("Iband",m_band);
  settings.setValue("catEnabled",m_catEnabled);
  settings.setValue("Rig",m_rig);
  settings.setValue("RigIndex",m_rigIndex);
  settings.setValue("CATport",m_catPort);
  settings.setValue("CATportIndex",m_catPortIndex);
  settings.setValue("SerialRate",m_serialRate);
  settings.setValue("SerialRateIndex",m_serialRateIndex);
  settings.setValue("DataBits",m_dataBits);
  settings.setValue("DataBitsIndex",m_dataBitsIndex);
  settings.setValue("StopBits",m_stopBits);
  settings.setValue("StopBitsIndex",m_stopBitsIndex);
  settings.setValue("Handshake",m_handshake);
  settings.setValue("HandshakeIndex",m_handshakeIndex);
  settings.setValue("Dither",ui->sbDither->value());
  settings.setValue("MyGrid",m_myGrid);
  settings.setValue("RIT",m_RIT);
  settings.setValue("Costas27",m_Costas);
  settings.setValue("Save",m_bSave);
  settings.setValue("MAP65",m_network);
  settings.endGroup();
}

//---------------------------------------------------------- readSettings()
void MainWindow::readSettings()
{
  QString inifile = m_appDir + "/emecho.ini";
  QSettings settings(inifile, QSettings::IniFormat);
  settings.beginGroup("MainWindow");
  restoreGeometry(settings.value("geometry").toByteArray());
  m_astroGeom = settings.value("AstroGeom", QRect(71,390,227,403)).toRect();
  m_wideGraphGeom = settings.value("WideGraphGeom", \
                                   QRect(45,30,726,301)).toRect();
  m_path = settings.value("MRUdir", m_appDir + "/save").toString();
  settings.endGroup();

  settings.beginGroup("Common");
  m_myGrid=settings.value("MyGrid","").toString();
  m_pttMethodIndex=settings.value("PTTmethod",1).toInt();
  m_pttPort=settings.value("PTTport",0).toInt();
  m_saveDir=settings.value("SaveDir",m_appDir + "/save").toString();
  m_astroFont=settings.value("AstroFont",20).toInt();
  m_nDevIn = settings.value("SoundInIndex", 0).toInt();
  m_paInDevice = settings.value("paInDevice",0).toInt();
  m_nDevOut = settings.value("SoundOutIndex", 0).toInt();
  m_paOutDevice = settings.value("paOutDevice",0).toInt();
  m_txFreq=settings.value("TxFreq",1500).toInt();
  m_txFreq=1500.0;
  soundOutThread.setTxFreq(m_txFreq);
  m_inGain=settings.value("InGain",0).toInt();
  ui->inGain->setValue(m_inGain);
  m_TxOK=settings.value("TxEnable",false).toBool();
  m_rxavg=1.0;
  m_band=settings.value("Iband",6).toInt();
  m_grid6=settings.value("Grid6",false).toBool();
  m_Costas=settings.value("Costas27",false).toInt();
  ui->rbCW->setChecked(m_Costas==0);
  ui->rb27->setChecked(m_Costas>0);
  soundOutThread.setCostas(m_Costas);
  m_catEnabled=settings.value("catEnabled",false).toBool();
  m_network=settings.value("MAP65",false).toBool();
  m_bSave=settings.value("Save",false).toBool();
  ui->actionSave_data->setChecked(m_bSave);
  m_rig=settings.value("Rig",214).toInt();
  m_rigIndex=settings.value("RigIndex",100).toInt();
  m_catPort=settings.value("CATport","None").toString();
  m_catPortIndex=settings.value("CATportIndex",0).toInt();
  m_serialRate=settings.value("SerialRate",4800).toInt();
  m_serialRateIndex=settings.value("SerialRateIndex",1).toInt();
  m_dataBits=settings.value("DataBits",8).toInt();
  m_dataBitsIndex=settings.value("DataBitsIndex",1).toInt();
  m_stopBits=settings.value("StopBits",2).toInt();
  m_stopBitsIndex=settings.value("StopBitsIndex",1).toInt();
  m_handshake=settings.value("Handshake","None").toString();
  m_handshakeIndex=settings.value("HandshakeIndex",0).toInt();
  ui->bandComboBox->setCurrentIndex(m_band);
  ui->sbDither->setValue(settings.value("Dither",1500).toInt());
  m_myGrid=settings.value("MyGrid","FN20qi").toString();
  ui->locator->setText(m_myGrid);
  m_RIT=settings.value("RIT",0).toInt();
  ui->sbRIT->setValue(m_RIT);
  settings.endGroup();
}

//-------------------------------------------------------------- dataSink()
void MainWindow::dataSink()
{
//  static int n1=260000;              //260000/48000 = 5.417 s
//  static int n2=0;

  //  qDebug() << "4. Rx done:" << QDateTime::currentMSecsSinceEpoch() % 6000;
  lab1->setStyleSheet("");
  lab1->setText("");

  int k0=0;
  float x=float(d2com_.kstop)/48000.0;
  if(x>6.0) {
    x=x-6.0;
    k0=576000/2;
  }

  d2com_.kstop=d2com_.k;
//  if(!m_diskData) fil4_(&d2com_.d2a[k0],&n1,&datcom_.d2[0],&n2);
  bool bSave=m_bSave and !m_diskData;
  *future1 = QtConcurrent::run(echospec,bSave,m_fname,m_network);
  watcher1->setFuture(*future1);               // call specReady() when done
}

void MainWindow::specReady()
{
  if(m_bSave and !m_diskData and !future1->result()) {
    on_stopButton_clicked();
    msgBox("Cannot create file\n" + m_fname);
  }


  g_pWideGraph->plotSpec();
//  qDebug() << "5. Spectrum plotted:" << QDateTime::currentMSecsSinceEpoch() % 6000;
  float level=-99.0;
  if(datcom_.rms>0.0) level=10.0*log10(double(datcom_.rms)) - 20.0;
  QString t;
  t.sprintf("%3d %5.1f %5.1f %6.1f %5.1f %3d",
            datcom_.nsum,level,datcom_.snrdb,datcom_.dfreq,
            datcom_.width,datcom_.nqual);
  ui->decodedTextBrowser->append(t);
  if(m_loopall>0) on_actionRead_next_data_in_file_triggered();
}

void MainWindow::showSoundInError(const QString& errorMsg)
 {QMessageBox::critical(this, tr("Error in SoundIn"), errorMsg);}

void MainWindow::showStatusMessage(const QString& statusMsg)
 {statusBar()->showMessage(statusMsg);}

void MainWindow::on_actionSettings_triggered()                  //Setup Dialog
{
  DevSetup dlg(this);
  dlg.m_pttMethodIndex=m_pttMethodIndex;
  dlg.m_pttPort=m_pttPort;
  dlg.m_saveDir=m_saveDir;
  dlg.m_nDevIn=m_nDevIn;
  dlg.m_nDevOut=m_nDevOut;
  dlg.m_grid6=m_grid6;
  dlg.m_catEnabled=m_catEnabled;
  dlg.m_rig=m_rig;
  dlg.m_rigIndex=m_rigIndex;
  dlg.m_catPort=m_catPort;
  dlg.m_catPortIndex=m_catPortIndex;
  dlg.m_serialRate=m_serialRate;
  dlg.m_serialRateIndex=m_serialRateIndex;
  dlg.m_dataBits=m_dataBits;
  dlg.m_dataBitsIndex=m_dataBitsIndex;
  dlg.m_stopBits=m_stopBits;
  dlg.m_stopBitsIndex=m_stopBitsIndex;
  dlg.m_handshake=m_handshake;
  dlg.m_handshakeIndex=m_handshakeIndex;
  dlg.m_network=m_network;

  dlg.initDlg();
  if(dlg.exec() == QDialog::Accepted) {
    m_pttMethodIndex=dlg.m_pttMethodIndex;
    m_pttPort=dlg.m_pttPort;
    m_saveDir=dlg.m_saveDir;
    m_nDevIn=dlg.m_nDevIn;
    m_paInDevice=dlg.m_paInDevice;
    m_nDevOut=dlg.m_nDevOut;
    m_paOutDevice=dlg.m_paOutDevice;
    m_grid6=dlg.m_grid6;
    m_catEnabled=dlg.m_catEnabled;
    m_rig=dlg.m_rig;
    m_rigIndex=dlg.m_rigIndex;
    m_catPort=dlg.m_catPort;
    m_catPortIndex=dlg.m_catPortIndex;
    m_serialRate=dlg.m_serialRate;
    m_serialRateIndex=dlg.m_serialRateIndex;
    m_dataBits=dlg.m_dataBits;
    m_dataBitsIndex=dlg.m_dataBitsIndex;
    m_stopBits=dlg.m_stopBits;
    m_stopBitsIndex=dlg.m_stopBitsIndex;
    m_handshake=dlg.m_handshake;
    m_handshakeIndex=dlg.m_handshakeIndex;
    m_network=dlg.m_network;

    if(dlg.m_restartSoundIn) {
      m_auto=false;
      soundInThread.quit();
      soundInThread.wait(300);
      soundInThread.setInputDevice(m_paInDevice);
      soundInThread.setNetwork(m_network);
      soundInThread.start(QThread::HighestPriority);
    }
    if(dlg.m_restartSoundOut) soundOutThread.setOutputDevice(m_paOutDevice);
  }
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
  lab1 = new QLabel("");
  lab1->setAlignment(Qt::AlignHCenter);
  lab1->setMinimumSize(QSize(100,18));
  lab1->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(lab1);

  lab2 = new QLabel("");
  lab2->setAlignment(Qt::AlignHCenter);
  lab2->setMinimumSize(QSize(60,18));
  lab2->setFrameStyle(QFrame::Panel | QFrame::Sunken);
  statusBar()->addWidget(lab2);

  lab3 = new QLabel("");
  lab3->setAlignment(Qt::AlignHCenter);
  lab3->setMinimumSize(QSize(150,18));
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
  soundInThread.quit();
  soundInThread.wait(300);
  soundInThread.terminate();
  soundOutThread.terminate();
  Pa_Terminate();
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
  "http://www.physics.princeton.edu/pulsar/K1JT/WSPR-X_Users_Guide.pdf",
                              QUrl::TolerantMode));
}

void MainWindow::on_actionWide_Waterfall_triggered()      //Display Waterfalls
{
  if(g_pWideGraph==NULL) {
    g_pWideGraph = new WideGraph(0);
    g_pWideGraph->setWindowTitle("EMEcho Waterfall");
    g_pWideGraph->setGeometry(m_wideGraphGeom);
    Qt::WindowFlags flags = Qt::WindowCloseButtonHint |
        Qt::WindowMinimizeButtonHint;
    g_pWideGraph->setWindowFlags(flags);

  }
  g_pWideGraph->show();
}

void MainWindow::p1ReadFromStdout()                        //p1readFromStdout
{
  QString t1;
  while(p1.canReadLine()) {
    QString t(p1.readLine());
    ui->decodedTextBrowser->append(t);
  }
}

void MainWindow::p1ReadFromStderr()                        //p1readFromStderr
{
  QByteArray t=p1.readAllStandardError();
  msgBox(t);
}

void MainWindow::p1Error()                                     //p1Error
{
  msgBox("Error starting or running\n" + m_appDir + "/wsprd");
}

void MainWindow::p3ReadFromStdout()                        //p3readFromStdout
{
  QByteArray t=p3.readAllStandardOutput();
  if(t.length()>0) {
    msgBox("rigctl stdout:\n\n"+t+"\n"+m_cmnd);
  }
}

void MainWindow::p3ReadFromStderr()                        //p3readFromStderr
{
  QByteArray t=p3.readAllStandardError();
  if(t.length()>0) {
    msgBox("rigctl stderr:\n\n"+t+"\n"+m_cmnd);
  }
}

void MainWindow::p3Error()                                     //p3rror
{
  msgBox("Error attempting to run rigctl.\n\n"+m_cmnd);
}

void MainWindow::on_eraseButton_clicked()                          //Erase
{
  ui->decodedTextBrowser->clear();
  datcom_.nclearave=1;
  datcom_.nsum=0;
  if(g_pWideGraph!=NULL) g_pWideGraph->plotSpec();
}

void MainWindow::on_inGain_valueChanged(int n)
{
  m_inGain=n;
}

//------------------------------------------------------------- //guiUpdate()
void MainWindow::guiUpdate()
{
  static double s6z=-99.0;

  qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
  double tsec=0.001*ms;
  int nsec=tsec;
  m_s6=fmod(tsec,6.0);

//  qDebug() << "a" << m_s6 << s6z << m_s6-s6z;
// When m_s6 has wrapped back to zero, start a new cycle.
  if(m_auto and m_s6<s6z) {

    if(m_fname=="") {
      QDateTime t = QDateTime::currentDateTimeUtc();
      m_fname=m_saveDir + "/" + t.date().toString("yyMMdd") + "_" +
          t.time().toString("hhmmss") + ".eco";
    }
//Raise PTT
    if(m_pttMethodIndex==0) {
      m_cmnd=rig_command() + " T 1";
      p3.start(m_cmnd);
      p3.waitForFinished();
    }
    if(m_pttMethodIndex==1 or m_pttMethodIndex==2) {
      ptt(m_pttPort,1,&m_iptt,&m_COMportOpen);
    }
//Wait 0.2 s, then send a 2.304 s Tx pulse
    ptt1Timer->start(200);                       //Sequencer delay
    lab1->setStyleSheet("QLabel{background-color: #ff0000}");
    lab1->setText("Transmitting");
    signalMeter->setValue(0);
  }

  if(m_transmitted and m_s6 > 5.4) {
    m_transmitted=false;
    dataSink();
  }

  float px=20.0*log10(datcom_.rms)- 20.0;
  signalMeter->setValue(px);                   // Update signalmeter

  if(nsec != m_sec0) {
    QDateTime t = QDateTime::currentDateTimeUtc();
    QString utc = t.date().toString("yyyy MMM dd") + " \n " +
        t.time().toString();
    ui->labUTC->setText(utc);
    if(!m_receiving) signalMeter->setValue(0);
    datcom_.nfrit = ui->sbRIT->value();
    g_pAstro->astroUpdate(t, m_myGrid, m_freq);
//    qDebug() << "a" << datcom_.rms << px;
    m_sec0=nsec;
  }
  s6z=m_s6;
} //End of guiUpdate()

//------------------------------------------------------------- startTx2()
void MainWindow::startTx2()
{
  double r = ((double) rand() / (RAND_MAX));
  int freq=1500.0 + (r-0.5)*ui->sbDither->value();
  datcom_.f1=float(freq);
  soundOutThread.setTxFreq(freq);
  soundOutThread.setCostas(m_Costas);
  soundOutThread.start(QThread::HighPriority);
  m_transmitting=true;
//  qDebug() << "1. Start Tx audio:" << QDateTime::currentMSecsSinceEpoch() % 6000;

}

void MainWindow::stopTx()
{
//Tx pulse is finished.
//  qDebug() << "2. Tx audio finished:" << QDateTime::currentMSecsSinceEpoch() % 6000;
  m_transmitting=false;
  lab1->setStyleSheet("");
  lab1->setText("");
// Wait 0.1 s, then lower PTT and start the Rx sequence
  ptt0Timer->start(100);                       //Sequencer delay
}

void MainWindow::stopTx2()
{
//Lower PTT
  if(m_pttMethodIndex==0) {
    m_cmnd=rig_command() + " T 0";
    p3.start(m_cmnd);
    p3.waitForFinished();
  }
  if(m_pttMethodIndex==1 or m_pttMethodIndex==2) {
    ptt(m_pttPort,0,&m_iptt,&m_COMportOpen);
  }
  m_transmitted=true;
  QString t;
  t.sprintf(" Receiving ");
  lab1->setStyleSheet("QLabel{background-color: #00ff00}");
  lab1->setText(t);
  soundInThread.start(QThread::HighPriority);
  soundInThread.setReceiving(true);
  m_receiving=true;
//  qDebug() << "3. Start Rx:" << QDateTime::currentMSecsSinceEpoch() % 6000;
}

void MainWindow::on_bandComboBox_currentIndexChanged(int n)
{
  m_band=n;
  QString t=ui->bandComboBox->currentText();
  int i=t.indexOf(" MHz");
  m_freq=t.mid(0,i).toDouble();
}

QString MainWindow::rig_command()
{
  QString cmnd1,cmnd2;
  cmnd1.sprintf("rigctl -m %d -r ",m_rig);
  cmnd1+=m_catPort;
  cmnd2.sprintf(" -s %d -C data_bits=%d -C stop_bits=%d -C serial_handshake=",
                m_serialRate,m_dataBits,m_stopBits);
  cmnd2+=m_handshake;
  return cmnd1+cmnd2;
}

void MainWindow::on_txEnableButton_clicked()
{
  m_auto = !m_auto;
  if(m_auto) {
    m_fname="";
    ui->txEnableButton->setStyleSheet(m_txEnable_style);
    m_diskData=false;
  } else {
    m_TxOK=false;
    ui->txEnableButton->setStyleSheet("");
  }
}

void MainWindow::on_stopButton_clicked()
{
  if(m_auto) {
    on_txEnableButton_clicked();
  }
  m_loopall=0;
}

void MainWindow::on_actionAstronomical_data_triggered()
{
  if(g_pAstro==NULL) {
    g_pAstro = new Astro(0);
    g_pAstro->setWindowTitle("Astronomical Data");
    Qt::WindowFlags flags = Qt::Dialog | Qt::WindowCloseButtonHint |
        Qt::WindowMinimizeButtonHint;
    g_pAstro->setWindowFlags(flags);
    g_pAstro->setGeometry(m_astroGeom);
  }
  g_pAstro->show();
}

void MainWindow::on_locator_editingFinished()
{
  m_myGrid=ui->locator->text();
}

void MainWindow::on_sbRIT_valueChanged(int arg1)
{
  m_RIT=arg1;
}

void MainWindow::on_rbCW_toggled(bool checked)
{
  if(checked) m_Costas=0;
}

void MainWindow::on_rb27_toggled(bool checked)
{
  if(checked) m_Costas=4;
}


void MainWindow::on_actionSave_data_triggered(bool checked)
{
  m_bSave=checked;
}

void MainWindow::on_actionOpen_triggered()
{
  m_auto=false;
  QString fname;
  fname=QFileDialog::getOpenFileName(this, "Open File", m_path,
                                       "WSPR Files (*.eco)");
  if(fname != "") {
    m_path=fname;
    char name[80];
    strcpy(name,fname.toLatin1());
    fp=fopen(name,"rb");
    if(fp != NULL) {
      int n=datcom_.nsum;
      uint nbytes=fread(datcom_.d2,1,67600,fp);
      if(nbytes!=67600) return;
      datcom_.nsum=n;
      m_diskData=true;
      datcom_.nclearave=1;
      dataSink();
    }
  }
}

void MainWindow::on_actionDelete_eco_files_triggered()
{
  int i;
  QString fname;
  int ret = QMessageBox::warning(this, "Confirm Delete",
      "Are you sure you want to delete all *.eco files in\n" +
       QDir::toNativeSeparators(m_saveDir) + " ?",
       QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
  if(ret==QMessageBox::Yes) {
    QDir dir(m_saveDir);
    QStringList files=dir.entryList(QDir::Files);
    QList<QString>::iterator f;
    for(f=files.begin(); f!=files.end(); ++f) {
      fname=*f;
      i=(fname.indexOf(".eco"));
      if(i>1) dir.remove(fname);
    }
  }
}

void MainWindow::on_measureButton_clicked()
{
}

void MainWindow::on_actionRead_next_data_in_file_triggered()
{
  if(fp != NULL) {
    int n=datcom_.nsum;
    int nbytes=fread(datcom_.d2,1,67600,fp);
    datcom_.nsum=n;
    if(nbytes == 67600) {
      dataSink();
      m_loopall--;
    } else {
      fclose(fp);
      fp=NULL;
      if(m_loopall==0) msgBox("End of echo data.");
      m_loopall=0;
    }
  }
}

void MainWindow::on_actionRead_all_remaining_records_triggered()
{
  m_loopall=9999999;
  on_actionRead_next_data_in_file_triggered();
}

void MainWindow::on_actionRead10_triggered()
{
  m_loopall=10;
  on_actionRead_next_data_in_file_triggered();
}
