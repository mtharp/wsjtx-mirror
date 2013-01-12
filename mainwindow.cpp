//--------------------------------------------------------------- MainWindow
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
double dFreq[]={0.136,0.4742,1.8366,3.5926,5.2872,7.0386,10.1387,14.0956,
           18.1046,21.0946,24.9246,28.1246,50.293,70.091,144.489,0.0};

WideGraph* g_pWideGraph = NULL;

QString ver="0.6";
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

  connect(&p2, SIGNAL(readyReadStandardOutput()),
                    this, SLOT(p2ReadFromStdout()));
  connect(&p2, SIGNAL(readyReadStandardError()),
          this, SLOT(p2ReadFromStderr()));
  connect(&p2, SIGNAL(error(QProcess::ProcessError)),
          this, SLOT(p2Error()));

  mNetworkManager = new QNetworkAccessManager(this);
  QObject::connect(mNetworkManager, SIGNAL(finished(QNetworkReply*)),
                   this, SLOT(onNetworkReply(QNetworkReply*)));

  QTimer *guiTimer = new QTimer(this);
  connect(guiTimer, SIGNAL(timeout()), this, SLOT(guiUpdate()));
  guiTimer->start(100);                            //Don't change the 100 ms!
  ptt0Timer = new QTimer(this);
  ptt0Timer->setSingleShot(true);
  connect(ptt0Timer, SIGNAL(timeout()), this, SLOT(stopTx2()));
  ptt1Timer = new QTimer(this);
  ptt1Timer->setSingleShot(true);
  connect(ptt1Timer, SIGNAL(timeout()), this, SLOT(startTx2()));
  tuneTimer = new QTimer(this);
  tuneTimer->setSingleShot(true);
  connect(tuneTimer, SIGNAL(timeout()), this, SLOT(stopTx()));
  uploadTimer = new QTimer(this);
  uploadTimer->setSingleShot(true);
  connect(uploadTimer, SIGNAL(timeout()), this, SLOT(p2Start()));

  m_auto=false;
  m_waterfallAvg = 1;
  btxMute=false;
  btxok=false;
  m_restart=false;
  m_transmitting=false;
  m_tuning=false;
  m_myCall="K1JT";
  m_myGrid="FN20qi";
  m_appDir = QApplication::applicationDirPath();
  m_saveDir="/users/joe/wsprx/install/save";
  m_txFreq=1500;
  m_loopall=false;
  m_startAnother=false;
  m_save=0;
  m_sec0=-1;
  m_palette="CuteSDR";
  m_RxLog=1;                     //Write Date and Time to RxLog
  m_nutc0=9999;
  m_mode="WSPR-2";
  m_TRseconds=120;
  m_inGain=0;
  m_hopping=false;
  m_rxdone=false;
  m_idle=false;
  m_RxOK=true;
  m_TxOK=false;
  m_nrx=1;
  m_ntx=0;
  m_txnext=false;
  m_uploading=false;
  m_grid6=false;
  m_band=6;
  m_nseq=0;
  m_ntr=0;
  m_BFO=1500;

  ui->xThermo->setFillBrush(Qt::green);

  for(int i=0; i<28; i++)  {                      //Initialize dBm values
    float dbm=(10.0*i)/3.0 - 30.0;
    int ndbm=0;
    if(dbm<0) ndbm=int(dbm-0.5);
    if(dbm>=0) ndbm=int(dbm+0.5);
    QString t;
    t.sprintf("%d dBm",ndbm);
    ui->dBmComboBox->addItem(t);
  }

  int band[] ={2200,630,160,80,60,40,30,20,17,15,12,10,6,4,2};
  for(int i=0; i<15; i++) {
    QString t;
    t.sprintf("%4d m",band[i]);
    ui->bandComboBox->addItem(t);
  }
  ui->bandComboBox->addItem("Other");

  PaError paerr=Pa_Initialize();                    //Initialize Portaudio
  if(paerr!=paNoError) {
    msgBox("Unable to initialize PortAudio.");
  }
  readSettings();		             //Restore user's setup params

  on_actionWide_Waterfall_triggered();                   //###
  g_pWideGraph->setTxFreq(m_txFreq);
  g_pWideGraph->setBFO(m_BFO);
  g_pWideGraph->setDialFreq(m_dialFreq);
  if(m_mode=="WSPR-2") on_actionWSPR_2_triggered();
  if(m_mode=="WSPR-15") on_actionWSPR_15_triggered();
  future1 = new QFuture<void>;
  watcher1 = new QFutureWatcher<void>;
  connect(watcher1, SIGNAL(finished()),this,SLOT(diskDat()));

  future2 = new QFuture<void>;
  watcher2 = new QFutureWatcher<void>;
  connect(watcher2, SIGNAL(finished()),this,SLOT(diskWriteFinished()));

  /*
  future3 = new QFuture<void>;
  watcher3 = new QFutureWatcher<void>;
  connect(watcher3, SIGNAL(finished()),this,SLOT(uploadFinished()));
  */

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
  m_diskData=false;

  if(ui->actionLinrad->isChecked()) on_actionLinrad_triggered();
  if(ui->actionCuteSDR->isChecked()) on_actionCuteSDR_triggered();
  if(ui->actionAFMHot->isChecked()) on_actionAFMHot_triggered();
  if(ui->actionBlue->isChecked()) on_actionBlue_triggered();
  freezeDecode(2);
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
  settings.setValue("SaveWav",ui->actionSave_wav->isChecked());
  settings.setValue("SaveC2",ui->actionSave_c2->isChecked());
  settings.setValue("SaveAll",ui->actionSave_all->isChecked());
  settings.setValue("NBslider",m_NBslider);
  settings.setValue("TxFreq",m_txFreq);
  settings.setValue("DialFreq",m_dialFreq);
  settings.setValue("InGain",m_inGain);
  settings.setValue("UploadSpots",m_uploadSpots);
  settings.setValue("TxEnable",m_TxOK);
  settings.setValue("PctTx",m_pctx);
  settings.setValue("dBm",m_dBm);
  settings.setValue("Grid6",m_grid6);
  settings.setValue("Iband",m_band);
  settings.setValue("BFO",m_BFO);
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
  ui->actionSave_wav->setChecked(settings.value("SaveWav",false).toBool());
  ui->actionSave_c2->setChecked(settings.value("SaveC2",false).toBool());
  ui->actionSave_all->setChecked(settings.value("SaveAll",false).toBool());
  m_save=0;
  if(ui->actionSave_wav->isChecked()) m_save=1;
  if(ui->actionSave_c2->isChecked()) m_save=2;
  if(ui->actionSave_all->isChecked()) m_save=3;
  m_NBslider=settings.value("NBslider",40).toInt();
  m_txFreq=settings.value("TxFreq",1500).toInt();
  m_dialFreq=settings.value("DialFreq",10.1387).toDouble();
  QString t;
  t.sprintf("%.6f ",m_dialFreq);
  ui->dialFreqLineEdit->setText(t);
  soundOutThread.setTxFreq(m_txFreq);
  m_inGain=settings.value("InGain",0).toInt();
  ui->inGain->setValue(m_inGain);
  m_uploadSpots=settings.value("UploadSpots",false).toBool();
  ui->cbUpload->setChecked(m_uploadSpots);
  m_TxOK=settings.value("TxEnable",false).toBool();
  ui->cbTxEnable->setChecked(m_TxOK);
  ui->TuneButton->setEnabled(m_TxOK);
  m_pctx=settings.value("PctTx",25).toInt();
  m_rxavg=1.0;
  if(m_pctx>0) m_rxavg=100.0/m_pctx - 1.0;  //Average # of Rx's per Tx
  ui->sbPctTx->setValue(m_pctx);
  m_dBm=settings.value("dBm",37).toInt();
  ui->dBmComboBox->setCurrentIndex(int(0.3*(m_dBm + 30.0)+0.2));
  m_band=settings.value("Iband",6).toInt();
  ui->bandComboBox->setCurrentIndex(m_band);
  m_grid6=settings.value("Grid6",false).toBool();
  m_BFO=settings.value("BFO",1500).toInt();
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

  if(m_diskData) {
    datcom_.ndiskdat=1;
  } else {
    datcom_.ndiskdat=0;
  }

// Get power, spectrum, and ihsym
  symspec_(&k, &m_nsps, &m_inGain, &px, s, &df3, &ihsym);
  if(ihsym <=0) return;
  QString t;
  t.sprintf(" Receiving: %5.1f dB ",px);
  lab1->setStyleSheet("QLabel{background-color: #00ff00}");
  lab1->setText(t);
  ui->xThermo->setValue((double)px);                    //Update thermometer
  if(m_receiving || m_diskData) {
    g_pWideGraph->dataSink2(s,df3,ihsym,m_diskData);
  }

  if(ihsym == m_hsymStop) {
    QDateTime t = QDateTime::currentDateTimeUtc();
    m_dateTime=t.toString("yyyy-MMM-dd hh:mm");
    QString t2;

    if(!m_diskData) {                        //Always save; may delete later
      int ihr=t.time().toString("hh").toInt();
      int imin=t.time().toString("mm").toInt();
      imin=imin - (imin%(m_TRseconds/60));
      t2.sprintf("%2.2d%2.2d",ihr,imin);
      m_fname=m_saveDir + "/" + t.date().toString("yyMMdd") + "_" +
            t2 + ".wav";
      m_c2name=m_saveDir + "/" + t.date().toString("yyMMdd") + "_" +
            t2 + ".c2";
      *future2 = QtConcurrent::run(savewav, m_fname, m_TRseconds);
      watcher2->setFuture(*future2);
      int len1=m_c2name.length();
      char c2name[80];
      strcpy(c2name,m_c2name.toAscii());
      savec2_(c2name,&m_TRseconds,&m_dialFreq,len1);
    }

    lab3->setStyleSheet("QLabel{background-color:cyan}");
    lab3->setText("Decoding");
    m_rxdone=true;
    loggit("Start Decoder");
    QString cmnd;
    if(m_diskData) {
      t2.sprintf(" -f %.6f ",m_dialFreq);

      cmnd='"' + m_appDir + '"' + "/wsprd " + m_path + '"';
      if(m_TRseconds==900) cmnd='"' + m_appDir + '"' + "/wsprd -m 15" + t2 +
          m_path + '"';
    } else {
      cmnd='"' + m_appDir + '"' + "/wsprd " + m_c2name + '"';
    }
    p1.start(QDir::toNativeSeparators(cmnd));
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
  dlg.m_grid6=m_grid6;
  dlg.m_BFO=m_BFO;

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
    m_grid6=dlg.m_grid6;
    m_BFO=dlg.m_BFO;
    g_pWideGraph->setBFO(m_BFO);

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
  lab3->setMinimumSize(QSize(120,18));
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
    g_pWideGraph->setWindowTitle("WSPR-X Waterfall");
    g_pWideGraph->setGeometry(m_wideGraphGeom);
    Qt::WindowFlags flags = Qt::WindowCloseButtonHint |
        Qt::WindowMinimizeButtonHint;
    g_pWideGraph->setWindowFlags(flags);
    connect(g_pWideGraph, SIGNAL(freezeDecode2(int)),this,
            SLOT(freezeDecode(int)));
  }
  g_pWideGraph->show();
}

void MainWindow::on_actionOpen_triggered()                     //Open File
{
  m_receiving=false;
  soundInThread.setReceiving(false);
  m_RxOK=false;
  QString fname;
  fname=QFileDialog::getOpenFileName(this, "Open File", m_path,
                                       "WSPR Files (*.wav *.c2)");
  if(fname != "") {
    m_path=fname;
    int i;
    i=fname.indexOf(".wav") - 11;
    if(i>=0) {
      lab1->setStyleSheet("QLabel{background-color: #66ff66}");
      lab1->setText(" " + fname.mid(i,15) + " ");
    }
    on_cbIdle_toggled(true);
    m_diskData=true;
    *future1 = QtConcurrent::run(getfile, fname, m_TRseconds);
    watcher1->setFuture(*future1);         // call diskDat() when done
  }
}

void MainWindow::freezeDecode(int n)                          //freezeDecode()
{
  m_txFreq=g_pWideGraph->txFreq();
  ui->sbTxAudio->setValue(m_txFreq);
}

void MainWindow::on_actionOpen_next_in_directory_triggered()   //Open Next
{
  int i,len;
  QFileInfo fi(m_path);
  QStringList list;
//  list= fi.dir().entryList().filter(".wav");
  list= fi.dir().entryList();
  for (i = 0; i < list.size()-1; ++i) {
    if(i==list.size()-2) m_loopall=false;
    len=list.at(i).length();
    if(list.at(i)==m_path.right(len)) {
      int n=m_path.length();
      QString fname=m_path.replace(n-len,len,list.at(i+1));
      m_path=fname;
      if(fname.indexOf(".wav")>1 or fname.indexOf(".c2")>1) {
        m_diskData=true;
        *future1 = QtConcurrent::run(getfile, fname, m_TRseconds);
        watcher1->setFuture(*future1);
        return;
      }
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
  k=m_path.length();
  if(m_path.mid(k-4,-1)==".wav") {
    for(int n=1; n<=m_hsymStop; n++) {              // Do the half-symbol FFTs
      k=(n+1)*kstep;
      dataSink(k);
      if(n%10 == 1 or n == m_hsymStop) qApp->processEvents(); //Keep GUI alive
    }
  } else {
    lab3->setStyleSheet("QLabel{background-color:cyan}");
    lab3->setText("Decoding");
    QString cmnd='"' + m_appDir + '"' + "/wsprd " + m_path + '"';
    p1.start(QDir::toNativeSeparators(cmnd));
  }
}

void MainWindow::diskWriteFinished()                       //diskWriteFinished
{
}

//Delete ../save/*.wav, *.c2
void MainWindow::on_actionDelete_all_wav_files_in_SaveDir_triggered()
{
  int i;
  QString fname;
  int ret = QMessageBox::warning(this, "Confirm Delete",
      "Are you sure you want to delete all *.wav and *.c2 files in\n" +
       QDir::toNativeSeparators(m_saveDir) + " ?",
       QMessageBox::Yes | QMessageBox::No, QMessageBox::Yes);
  if(ret==QMessageBox::Yes) {
    QDir dir(m_saveDir);
    QStringList files=dir.entryList(QDir::Files);
    QList<QString>::iterator f;
    for(f=files.begin(); f!=files.end(); ++f) {
      fname=*f;
      i=(fname.indexOf(".wav"));
      if(i>1) dir.remove(fname);
      i=(fname.indexOf(".c2"));
      if(i>1) dir.remove(fname);    }
  }
}

void MainWindow::on_actionNone_triggered()                    //Save None
{
  m_save=0;
  ui->actionNone->setChecked(true);
}

void MainWindow::on_actionSave_wav_triggered()
{
  m_save=1;
  ui->actionSave_wav->setChecked(true);
}

void MainWindow::on_actionSave_c2_triggered()
{
  m_save=2;
  ui->actionSave_c2->setChecked(true);
}

void MainWindow::on_actionSave_all_triggered()                //Save All
{
  m_save=3;
  ui->actionSave_all->setChecked(true);
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
      if(m_uploadSpots) {
        float x=rand()/((double)RAND_MAX + 1);
        int msdelay=20000*x;
        uploadTimer->start(msdelay);                         //Upload delay
      } else {
        QFile f("wsprd.out");
        if(f.exists()) f.remove();
      }
      if(m_save!=1 and m_save!=3) {
        QFile savedWav(m_fname);
        savedWav.remove();
      }
      if(m_save!=2 and m_save!=3) {
        int i1=m_fname.indexOf(".wav");
        QString sc2=m_fname.mid(0,i1) + ".c2";
        QFile savedC2(sc2);
        savedC2.remove();
      }
      m_RxLog=0;
      m_startAnother=m_loopall;
      return;
    } else {
      int n=t.length();
      t=t.mid(0,n-2) + "                                                  ";
      ui->decodedTextBrowser->append(t);
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

void MainWindow::p2Start()
{
  if(m_uploading) return;
  QString cmnd='"' + m_appDir + '"' + "/curl -s -S -F allmept=@" + m_appDir +
      "/wsprd.out -F call=" + m_myCall + " -F grid=" + m_myGrid;
  cmnd=QDir::toNativeSeparators(cmnd) + " http://wsprnet.org/meptspots.php";
  loggit("Start curl");
  m_uploading=true;
  lab3->setStyleSheet("QLabel{background-color:yellow}");
  lab3->setText("Uploading Spots");
  p2.start(cmnd);
}

void MainWindow::p2ReadFromStdout()                        //p2readFromStdout
{
  while(p2.canReadLine()) {
    QString t(p2.readLine());
    if(t.indexOf("spot(s) added") > 0) {
      QFile f("wsprd.out");
      f.remove();
    }
  }
  lab3->setStyleSheet("");
  lab3->setText("");
  m_uploading=false;
}

void MainWindow::p2ReadFromStderr()                        //p2readFromStderr
{
  QByteArray t=p2.readAllStandardError();
  if(t.length()>0) {
    loggit(t);
//    msgBox(t);
  }
  m_uploading=false;
}

void MainWindow::p2Error()                                     //p2rror
{
  msgBox("Error attempting to start curl.");
  m_uploading=false;
}

void MainWindow::on_EraseButton_clicked()                          //Erase
{
  ui->decodedTextBrowser->clear();
}


void MainWindow::on_actionWSPR_2_triggered()
{
  m_mode="WSPR-2";
  m_TRseconds=120;
  m_nsps=8192;
  m_nseqdone=114;
  m_hsymStop=int(2.0*m_nseqdone*12000.0/m_nsps);
  soundInThread.setPeriod(m_TRseconds,m_nsps);
  soundOutThread.setPeriod(m_TRseconds,m_nsps);
  g_pWideGraph->setPeriod(m_TRseconds,m_nsps);
  lab2->setStyleSheet("QLabel{background-color: #ffff00}");
  lab2->setText("WSPR-2");
  ui->actionWSPR_2->setChecked(true);
  if(m_transmitting) stopTx();
}

void MainWindow::on_actionWSPR_15_triggered()
{
  m_mode="WSPR-15";
  m_TRseconds=900;
  m_nsps=65536;
  m_nseqdone=890;
  m_hsymStop=int(2.0*m_nseqdone*12000.0/m_nsps);
  soundInThread.setPeriod(m_TRseconds,m_nsps);
  soundOutThread.setPeriod(m_TRseconds,m_nsps);
  g_pWideGraph->setPeriod(m_TRseconds,m_nsps);
  lab2->setStyleSheet("QLabel{background-color: #ee82ee}");
  lab2->setText("WSPR-15");
  ui->actionWSPR_15->setChecked(true);
  if(m_transmitting) stopTx();
}

void MainWindow::on_inGain_valueChanged(int n)
{
  m_inGain=n;
}

void MainWindow::on_TxNextButton_clicked()
{
  /* The following was for testing direct access to WSPRnet:
  QString t("http://wsprnet.org/post?function=wsprstat&rcall=K1JT&");
  t += "rgrid=FN20qi&rqrg=10.140200&tpct=0&tqrg=10.140200&dbm=20&";
  t += "version=" + Version;
  QUrl url(t);
//  qDebug() << "A" << t;
  reply = mNetworkManager->get(QNetworkRequest(url));
  */
  m_txnext=!m_txnext;
  if(m_txnext) ui->TxNextButton->setStyleSheet(m_txNext_style);
  if(!m_txnext) ui->TxNextButton->setStyleSheet("");
}

void MainWindow::onNetworkReply(QNetworkReply* reply)
{
  qDebug() << "Network Reply:" << reply->error();
  QString replyString;
  if(reply->error() == QNetworkReply::NoError) {
    int httpstatuscode = reply->attribute(
          QNetworkRequest::HttpStatusCodeAttribute).toUInt();
    qDebug() << "http status code:" << httpstatuscode;
    switch(httpstatuscode)
    {
    case 0:                                   //RESPONSE_OK:
      if (reply->isReadable()) {
  //Assuming this is a human readable file replyString now contains the file
        replyString = QString::fromUtf8(reply->readAll().data());
        qDebug() << "Network reply string:" << replyString;
      }
      break;
    default:
      //httpstatuscode is nonzero...
      break;
    }
  }
  reply->deleteLater();
}

void MainWindow::oneSec() {
  QDateTime t = QDateTime::currentDateTimeUtc();
  QString utc = t.date().toString("yyyy MMM dd") + " \n " +
          t.time().toString();
  ui->labUTC->setText(utc);
  if(!m_receiving and !m_diskData) {
    ui->xThermo->setValue(0.0);
  }
}

//------------------------------------------------------------- //guiUpdate()
void MainWindow::guiUpdate()
{
  int nsec=int(tsec());
  m_nseq = nsec % m_TRseconds;
  if(nsec != m_sec0) {
    oneSec();
    m_sec0=nsec;
  }

  if(m_nseq==0 and !m_idle and !m_receiving and !m_transmitting and
     m_ntr==0) {
    if(m_pctx==0) m_nrx=1;             //Always receive if pctx=0

    if(m_TxOK and (m_pctx>0) and (m_txnext or ((m_nrx==0) and (m_ntr!=-1))) or
       (m_TxOK and (m_pctx==100))) {

//This will be a normal Tx sequence. Compute # of Rx's that will follow.
      float x=(float)rand()/RAND_MAX;
      if(m_pctx<50) {
        m_nrx=int(m_rxavg + 3.0*(x-0.5) + 0.5);
      } else {
        m_nrx=0;
        if(x<m_rxavg) m_nrx=1;
      }

      m_ntr=-1;                         //This says we will have transmitted
      m_txnext=false;
      ui->TxNextButton->setStyleSheet("");
      startTx();                        //Start a normal Tx sequence
    } else {
      m_ntr=1;
      startRx();                        //Start a normal Rx sequence
    }
  }

  if(!m_tuning and (m_nseq >= m_nseqdone)) {   //Reached sequence end time?
    if(m_transmitting) stopTx();
    m_transmitting=false;
    m_receiving=false;
    m_ntr=0;
    soundInThread.setReceiving(false);
  }

}

void MainWindow::startRx()
{
  if(m_RxOK) {
    m_receiving=true;
    soundInThread.setReceiving(true);
    m_ntr=1;
    loggit("Start Rx");
    m_nrx=m_nrx-1;
  }
}

double MainWindow::tsec()
{
  qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
  return 0.001*ms;
}

void MainWindow::on_sbPctTx_valueChanged(int arg1)
{
  m_pctx=ui->sbPctTx->value();
  m_rxavg=1.0;
  if(m_pctx>0) m_rxavg=100.0/m_pctx - 1.0;  //Average # of Rx's per Tx
}

void MainWindow::startTx()
{
  static char msg[23];
  QString sdBm,msg1,msg0,message;
  sdBm.sprintf(" %d",m_dBm);
  m_ntx=1-m_ntx;
  int i2=m_myCall.indexOf("/");
  if(i2>0 or m_grid6) {
    // This is a "type 2" WSPR message
    if(i2<0) {
      msg1=m_myCall + " " + m_myGrid.mid(0,4) + sdBm;
    } else {
      msg1=m_myCall + sdBm;
    }
    msg0="<" + m_myCall + "> " + m_myGrid + sdBm;
    if(m_ntx==0) message=msg0;
    if(m_ntx==1) message=msg1;
  } else {
    // Normal WSPR message
    message=m_myCall + " " + m_myGrid.mid(0,4) + sdBm;
  }
  QByteArray ba=message.toAscii();
  ba2msg(ba,msg);
  int len1=22;
  genwsprx_(msg,itone,len1);
  ptt(m_pttPort,1,&m_iptt);                   // Raise PTT
  ptt1Timer->start(200);                       //Sequencer delay
  loggit("Start Tx");
  lab1->setStyleSheet("QLabel{background-color: #ff0000}");
  lab1->setText("Transmitting:  " + message);
  ui->xThermo->setValue(0.0);                    //Update thermometer
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
  ui->TuneButton->setStyleSheet("");
  ptt0Timer->start(200);                       //Sequencer delay
  loggit("Stop Tx");
//  startRx();
  m_receiving=true;
  soundInThread.setReceiving(true);
}

void MainWindow::stopTx2()
{
  loggit("Stop Tx2");
  ptt(m_pttPort,0,&m_iptt);                   //Lower PTT
}
void MainWindow::on_cbIdle_toggled(bool b)
{
  m_idle=b;
  ui->cbIdle->setChecked(b);
}

void MainWindow::on_cbTxEnable_toggled(bool b)
{
  m_TxOK=b;
  ui->TuneButton->setEnabled(m_TxOK);
  btxok=b;
  if(!m_TxOK and m_transmitting) stopTx();
}

void MainWindow::on_dialFreqLineEdit_editingFinished()
{
  m_dialFreq=ui->dialFreqLineEdit->text().toDouble();
  g_pWideGraph->setDialFreq(m_dialFreq);
}

void MainWindow::on_txFreqLineEdit_editingFinished()
{
  double txMHz=ui->txFreqLineEdit->text().toDouble();
  m_txFreq=int(1.0e6 * (txMHz-m_dialFreq) + 0.5);
}

void MainWindow::on_cbUpload_toggled(bool b)
{
  m_uploadSpots=b;
}

void MainWindow::on_cbBandHop_toggled(bool b)
{
  m_bandHop=b;
}

void MainWindow::on_dBmComboBox_currentIndexChanged(const QString &arg1)
{
  int i1=arg1.indexOf(" ");
  m_dBm=arg1.mid(0,i1).toInt();
}

void MainWindow::on_bandComboBox_currentIndexChanged(int n)
{
  m_band=n;
  m_dialFreq=dFreq[n];
  g_pWideGraph->setDialFreq(m_dialFreq);
  QString t;
  t.sprintf("%.6f ",m_dialFreq);
  ui->dialFreqLineEdit->setText(t);
  t.sprintf("%.6f",m_dialFreq+0.000001*m_txFreq);
  ui->txFreqLineEdit->setText(t);
}

void MainWindow::on_sbTxAudio_valueChanged(int n)
{
  m_txFreq=n;
  soundOutThread.setTxFreq(m_txFreq);
  double x=ui->dialFreqLineEdit->text().toDouble()+0.000001*m_txFreq;
  QString t;
  t.sprintf("%.6f",x);
  ui->txFreqLineEdit->setText(t);
}

void MainWindow::on_startRxButton_clicked()
{
  m_RxOK=true;
  startRx();
}

void MainWindow::loggit(QString t)
{
/*
  QDateTime t2 = QDateTime::currentDateTimeUtc();
  qDebug() << t2.time().toString("hh:mm:ss.zzz") << t;
*/

  /*
  QFile f("wsprx.log");
  if(f.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append)) {
    //    message=MyCall + MyGrid + "ndbm";
        //linetx = yymmdd + hhmm + ftx(f11.6) + "  Transmitting on "
    f.write(t);
    */
}

void MainWindow::on_TuneButton_clicked()
{
  m_tuning=!m_tuning;
  if(m_tuning) {
    on_cbIdle_toggled(true);
    m_receiving=false;
    ui->TuneButton->setStyleSheet(m_tune_style);
    m_tuning=true;
    startTx();
    itone[0]=-1;
  } else {
    stopTx();
  }
}
