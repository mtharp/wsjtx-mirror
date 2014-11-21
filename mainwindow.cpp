//-------------------------------------------------------------- MainWindow
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "devsetup.h"
#include "plotter.h"
#include "about.h"
#include "widegraph.h"
#include "getfile.h"
#include "portaudio.h"

int itone[162];                       //Tx audio tones
int icw[250];                         //Dits for CW ID
bool btxok;                           //True if OK to transmit
bool btxMute;
double outputLatency;                 //Latency in seconds
double dFreq[]={0.136,0.4742,1.8366,3.5926,5.2872,7.0386,10.1387,14.0956,
           18.1046,21.0946,24.9246,28.1246,50.293,70.091,144.489,0.0};

WideGraph* g_pWideGraph = NULL;

QString ver="0.9";
QString rev="$Rev$";
QString Program_Title_Version="  ECHO   v" + ver + "  r" + rev.mid(6,4) +
                              "    by K1JT";
QString Version=ver + "_r" + rev.mid(6,4);

//-------------------------------------------------- MainWindow constructor
MainWindow::MainWindow(QWidget *parent) :
  QMainWindow(parent),
  ui(new Ui::MainWindow)
{
  ui->setupUi(this);

/*
#ifdef WIN32
  freopen("wsprx.log","w",stderr);
#endif
*/

  on_eraseButton_clicked();
  ui->labUTC->setStyleSheet( \
        "QLabel { background-color : \
        black; color : yellow; border: 3px ridge gray}");

  QActionGroup* paletteGroup = new QActionGroup(this);
  ui->actionCuteSDR->setActionGroup(paletteGroup);
  ui->actionLinrad->setActionGroup(paletteGroup);
  ui->actionAFMHot->setActionGroup(paletteGroup);
  ui->actionBlue->setActionGroup(paletteGroup);

  QActionGroup* modeGroup = new QActionGroup(this);
  ui->actionWSPR_15->setActionGroup(modeGroup);

  QActionGroup* saveGroup = new QActionGroup(this);
  ui->actionNone->setActionGroup(saveGroup);
  ui->actionSave_wav->setActionGroup(saveGroup);
  ui->actionSave_c2->setActionGroup(saveGroup);
  ui->actionSave_all->setActionGroup(saveGroup);

  setWindowTitle(Program_Title_Version);
  connect(&soundInThread, SIGNAL(readyForFFT(int)),
             this, SLOT(dataSink(int)));
  connect(&soundInThread, SIGNAL(error(QString)), this,
          SLOT(showSoundInError(QString)));
  connect(&soundInThread, SIGNAL(status(QString)), this,
          SLOT(showStatusMessage(QString)));
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
  guiTimer->start(100);                            //Don't change the 100 ms!
  ptt0Timer = new QTimer(this);
  ptt0Timer->setSingleShot(true);
  connect(ptt0Timer, SIGNAL(timeout()), this, SLOT(stopTx2()));
  ptt1Timer = new QTimer(this);
  ptt1Timer->setSingleShot(true);
  connect(ptt1Timer, SIGNAL(timeout()), this, SLOT(startTx2()));

  m_auto=false;
  m_waterfallAvg = 1;
  btxMute=false;
  btxok=false;
  m_transmitting=false;
  m_myGrid="FN20qi";
  m_appDir = QApplication::applicationDirPath();
  m_txFreq=1500;
  m_sec0=-1;
  m_palette="CuteSDR";
  m_mode="WSPR-2";
  m_inGain=0;
  m_RxOK=true;
  m_TxOK=false;
  m_grid6=false;
  m_band=6;
  m_rig=-1;
  m_iptt=0;
  m_COMportOpen=0;

  signalMeter = new SignalMeter(ui->meterFrame);
  signalMeter->resize(50, 160);
//  qDebug() << signalMeter->isVisible() << signalMeter->size();

  PaError paerr=Pa_Initialize();                    //Initialize Portaudio
  if(paerr!=paNoError) {
    msgBox("Unable to initialize PortAudio.");
  }
  readSettings();		             //Restore user's setup params

  on_actionWide_Waterfall_triggered();                   //###
  g_pWideGraph->setTxFreq(m_txFreq);
  g_pWideGraph->setDialFreq(m_dialFreq);

  m_txNext_style="QPushButton{background-color: #00ff00; \
      border-style: outset; border-width: 1px; border-radius: 3px; \
      border-color: black; padding: 4px;}";
  m_tune_style="QPushButton{background-color: #ff0000; \
      border-style: outset; border-width: 1px; border-radius: 3px; \
      border-color: black; padding: 4px;}";

  soundInThread.setInputDevice(m_paInDevice);
  soundInThread.start(QThread::HighestPriority);
  soundOutThread.setOutputDevice(m_paOutDevice);
  soundOutThread.setTxFreq(m_txFreq);
  m_receiving=true;                        //Start with Rx ON
  soundInThread.setReceiving(true);

  if(ui->actionLinrad->isChecked()) on_actionLinrad_triggered();
  if(ui->actionCuteSDR->isChecked()) on_actionCuteSDR_triggered();
  if(ui->actionAFMHot->isChecked()) on_actionAFMHot_triggered();
  if(ui->actionBlue->isChecked()) on_actionBlue_triggered();

  //ui->legendLabel->setFont(ui->decodedTextBrowser->font());
  //ui->legendLabel->setText(" UTC   dB    DT        Freq   DF   Call          Grid    dBm");

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
  QString inifile = m_appDir + "/echox.ini";
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
  settings.setValue("MyGrid",m_myGrid);
  settings.setValue("IDint",m_idInt);
  settings.setValue("PTTmethod",m_pttMethodIndex);
  settings.setValue("PTTport",m_pttPort);
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
  settings.setValue("SaveWav",ui->actionSave_wav->isChecked());
  settings.setValue("SaveC2",ui->actionSave_c2->isChecked());
  settings.setValue("SaveAll",ui->actionSave_all->isChecked());
  settings.setValue("TxFreq",m_txFreq);
  settings.setValue("DialFreq",m_dialFreq);
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
  settings.endGroup();
}

//---------------------------------------------------------- readSettings()
void MainWindow::readSettings()
{
  QString inifile = m_appDir + "/echox.ini";
  QSettings settings(inifile, QSettings::IniFormat);
  settings.beginGroup("MainWindow");
  restoreGeometry(settings.value("geometry").toByteArray());
  m_wideGraphGeom = settings.value("WideGraphGeom", \
                                   QRect(45,30,726,301)).toRect();
  m_path = settings.value("MRUdir", m_appDir + "/save").toString();
  settings.endGroup();

  settings.beginGroup("Common");
  m_myGrid=settings.value("MyGrid","").toString();
  m_idInt=settings.value("IDint",0).toInt();
  m_pttMethodIndex=settings.value("PTTmethod",1).toInt();
  m_pttPort=settings.value("PTTport",0).toInt();
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
  ui->actionSave_wav->setChecked(settings.value("SaveWav",false).toBool());
  ui->actionSave_c2->setChecked(settings.value("SaveC2",false).toBool());
  ui->actionSave_all->setChecked(settings.value("SaveAll",false).toBool());
  m_txFreq=settings.value("TxFreq",1500).toInt();
  m_dialFreq=settings.value("DialFreq",10.1387).toDouble();
  QString t;
  t.sprintf("%.6f ",m_dialFreq);
  soundOutThread.setTxFreq(m_txFreq);
  m_inGain=settings.value("InGain",0).toInt();
  ui->inGain->setValue(m_inGain);
  m_TxOK=settings.value("TxEnable",false).toBool();
  m_rxavg=1.0;
  m_band=settings.value("Iband",6).toInt();
  m_grid6=settings.value("Grid6",false).toBool();
  m_catEnabled=settings.value("catEnabled",false).toBool();
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
  static float s[1366];
  static int ihsym=0;
  static float px=0.0;
  static float df3;

// Get power, spectrum, and ihsym
//  symspec_(&k, &m_nsps, &m_BFO, &m_inGain, &px, s, &df3, &ihsym);
  if(ihsym <=0) return;
  QString t;
  t.sprintf(" Receiving: %5.1f dB ",px);
  lab1->setStyleSheet("QLabel{background-color: #00ff00}");
  lab1->setText(t);
  signalMeter->setValue(px);                   // Update signalmeter
  if(m_receiving) {
    g_pWideGraph->dataSink2(s,df3,ihsym,false);
  }

  if(ihsym == 999) {
    QDateTime t = QDateTime::currentDateTimeUtc();
    m_dateTime=t.toString("yyyy-MMM-dd hh:mm");
//    double f0m1500=m_dialFreq + 0.000001*(m_BFO - 1500);
    QString t2;

    lab3->setStyleSheet("QLabel{background-color:cyan}");
    lab3->setText("Decoding");
    loggit("Start Decoder");
  }
  soundInThread.m_dataSinkBusy=false;
}

void MainWindow::showSoundInError(const QString& errorMsg)
 {QMessageBox::critical(this, tr("Error in SoundIn"), errorMsg);}

void MainWindow::showStatusMessage(const QString& statusMsg)
 {statusBar()->showMessage(statusMsg);}

void MainWindow::on_actionSettings_triggered()                  //Setup Dialog
{
  DevSetup dlg(this);
  dlg.m_idInt=m_idInt;
  dlg.m_pttMethodIndex=m_pttMethodIndex;
  dlg.m_pttPort=m_pttPort;
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

  dlg.initDlg();
  if(dlg.exec() == QDialog::Accepted) {
    m_idInt=dlg.m_idInt;
    m_pttMethodIndex=dlg.m_pttMethodIndex;
    m_pttPort=dlg.m_pttPort;
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
  lab1->setMinimumSize(QSize(150,18));
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
    g_pWideGraph->setWindowTitle("ECHO Waterfall");
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
    if(t.indexOf("<DecodeFinished>") >= 0) {
      lab3->setStyleSheet("");
      lab3->setText("");
      loggit("Decoder Finished");
      return;
    } else {
      int n=t.length();
      t=t.mid(0,n-2) + "                                                  ";
      t.remove(QRegExp("\\s+$"));
      QStringList rxFields = t.split(QRegExp("\\s+"));
      //qDebug() << "++> Rx: " << rxFields;
      QString rxLine;
      if ( rxFields.count() == 8 ) {
          rxLine = QString("%1 %2 %3 %4 %5   %6  %7  %8")
                  .arg(rxFields.at(0), 4)
                  .arg(rxFields.at(1), 4)
                  .arg(rxFields.at(2), 5)
                  .arg(rxFields.at(3), 11)
                  .arg(rxFields.at(4), 4)
                  .arg(rxFields.at(5), -12)
                  .arg(rxFields.at(6), -6)
                  .arg(rxFields.at(7), 3);
      } else if ( rxFields.count() == 7 ) { // Type 2 message
          rxLine = QString("%1 %2 %3 %4 %5   %6  %7  %8")
                  .arg(rxFields.at(0), 4)
                  .arg(rxFields.at(1), 4)
                  .arg(rxFields.at(2), 5)
                  .arg(rxFields.at(3), 11)
                  .arg(rxFields.at(4), 4)
                  .arg(rxFields.at(5), -12)
                  .arg("", -6)
                  .arg(rxFields.at(6), 3);
      } else {
          rxLine = t;
      }
      ui->decodedTextBrowser->append(rxLine);
    }
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
}

void MainWindow::on_inGain_valueChanged(int n)
{
  m_inGain=n;
}

void MainWindow::oneSec() {
  QDateTime t = QDateTime::currentDateTimeUtc();
  QString utc = t.date().toString("yyyy MMM dd") + " \n " +
          t.time().toString();
  ui->labUTC->setText(utc);
  if(!m_receiving) signalMeter->setValue(0);
}

//------------------------------------------------------------- //guiUpdate()
void MainWindow::guiUpdate()
{
  qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
  double tsec=0.001*ms;
  int nsec=tsec;
  double t2p=fmod(tsec,6.0);

//  qDebug() << "A" << t2p;
  if(nsec != m_sec0) {
    oneSec();
    m_sec0=nsec;
  }

  int nstop=2;
  if(1) {   //Reached sequence end time?
    if(m_transmitting) stopTx();
    m_transmitting=false;
    m_receiving=false;
    soundInThread.setReceiving(false);
  }

} //End of guiUpdate()

void MainWindow::startRx()
{
  if(m_RxOK) {
    m_receiving=true;
    soundInThread.setReceiving(true);
    loggit("Start Rx");
  }
}

void MainWindow::startTx()
{

//Raise PTT
  if(m_pttMethodIndex==0) {
    m_cmnd=rig_command() + " T 1";
    p3.start(m_cmnd);
    p3.waitForFinished();
  }
  if(m_pttMethodIndex==1 or m_pttMethodIndex==2) {
    ptt(m_pttPort,1,&m_iptt,&m_COMportOpen);
  }
  ptt1Timer->start(200);                       //Sequencer delay
  loggit("Start Tx");
  lab1->setStyleSheet("QLabel{background-color: #ff0000}");
  lab1->setText("Transmitting");
  signalMeter->setValue(0);
}

void MainWindow::ba2msg(QByteArray ba, char message[])             //ba2msg()
{
  int iz=ba.length();
  for(int i=0;i<22; i++) {
    if(i<iz) {
      message[i]=ba[i];
    } else {
      message[i]=32;
    }
  }
  message[22]=0;
}

void MainWindow::startTx2()
{
  if(!soundOutThread.isRunning()) {
    double snr=99.0;
    QFile f("test.snr");
    if(f.open(QIODevice::ReadOnly | QIODevice::Text)) {
      char c[20];
      f.readLine(c,sizeof(c));
      QString t=QString(c);
      snr=t.toDouble();
    }
    soundOutThread.setTxSNR(snr);
    soundOutThread.start(QThread::HighPriority);
    m_transmitting=true;
    loggit("Start Tx2");
  }
}

void MainWindow::stopTx()
{
  g_pWideGraph->setTxed();
  if (soundOutThread.isRunning()) {
    soundOutThread.quitExecution=true;
    soundOutThread.wait(3000);
  }
  m_transmitting=false;
  lab1->setStyleSheet("");
  lab1->setText("");
  ptt0Timer->start(200);                       //Sequencer delay
  loggit("Stop Tx");
//  startRx();
  m_receiving=true;
  soundInThread.setReceiving(true);
}

void MainWindow::stopTx2()
{
  loggit("Stop Tx2");
//Lower PTT
  if(m_pttMethodIndex==0) {
    m_cmnd=rig_command() + " T 0";
    p3.start(m_cmnd);
    p3.waitForFinished();
  }
  if(m_pttMethodIndex==1 or m_pttMethodIndex==2) {
    ptt(m_pttPort,0,&m_iptt,&m_COMportOpen);
  }
}

void MainWindow::on_bandComboBox_currentIndexChanged(int n)
{
  m_band=n;
  m_dialFreq=dFreq[n];
  if(m_catEnabled) {
    int nHz=int(1000000.0*m_dialFreq + 0.5);
    QString cmnd1,cmnd3;
    cmnd1=rig_command();
    cmnd3.sprintf(" F %d",nHz);
    m_cmnd=cmnd1 + cmnd3;
    p3.start(m_cmnd);
    p3.waitForFinished();
  }
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

void MainWindow::loggit(QString t)
{
/*
  QDateTime t2 = QDateTime::currentDateTimeUtc();
  qDebug() << t2.time().toString("hh:mm:ss.zzz") << t
           << m_catEnabled << (int)m_catEnabled;
*/

  /*
  QFile f("wsprx.log");
  if(f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
    //    message=MyCall + MyGrid + "ndbm";
        //linetx = yymmdd + hhmm + ftx(f11.6) + "  Transmitting on "
    f.write(t);
    */
}
