#ifndef MAINWINDOW_H
#define MAINWINDOW_H
#include <QtGui>
#include <QTimer>
//#include <QUrl>
#include <QtNetwork>
#include <QDateTime>
#include "soundin.h"
#include "soundout.h"
#include "commons.h"

//--------------------------------------------------------------- MainWindow
namespace Ui {
    class MainWindow;
}

class MainWindow : public QMainWindow
{
  Q_OBJECT

public:
  explicit MainWindow(QWidget *parent = 0);
  ~MainWindow();

public slots:
  void showSoundInError(const QString& errorMsg);
  void showStatusMessage(const QString& statusMsg);
  void dataSink(int k);
  void diskDat();
  void diskWriteFinished();
  void freezeDecode(int n);
  void guiUpdate();
  void p1ReadFromStdout();
  void p1ReadFromStderr();
  void p1Error();
  void p2ReadFromStdout();
  void p2ReadFromStderr();
  void p2Error();

protected:
  virtual void keyPressEvent( QKeyEvent *e );
  void  closeEvent(QCloseEvent*);
  virtual bool eventFilter(QObject *object, QEvent *event);

private slots:
  void on_actionDeviceSetup_triggered();
  void on_actionExit_triggered();
  void on_actionAbout_triggered();
  void OnExit();
  void on_actionLinrad_triggered();
  void on_actionCuteSDR_triggered();
  void on_actionOnline_Users_Guide_triggered();
  void on_actionWide_Waterfall_triggered();
  void on_actionOpen_triggered();
  void on_actionOpen_next_in_directory_triggered();
  void on_actionDecode_remaining_files_in_directory_triggered();
  void on_actionDelete_all_wav_files_in_SaveDir_triggered();
  void on_actionNone_triggered();
  void on_actionSave_all_triggered();
  void on_EraseButton_clicked();
  void on_actionAFMHot_triggered();
  void on_actionBlue_triggered();
  void on_actionWSPR_2_triggered();
  void on_actionWSPR_15_triggered();
  void on_actionSave_decoded_triggered();
  void on_inGain_valueChanged(int n);
  void on_TxNextButton_clicked();
  void onNetworkReply(QNetworkReply* reply);
  void on_sbPctTx_valueChanged(int arg1);
  void on_cbIdle_toggled(bool b);
  void on_cbTxEnable_toggled(bool b);
  void startTx2();
  void loggit(QString t);
  void p2Start();

  void on_dialFreqLineEdit_editingFinished();

  void on_cbUpload_toggled(bool checked);

  void on_cbBandHop_toggled(bool checked);

  void on_TuneButton_clicked();

  void on_txFreqLineEdit_editingFinished();

private:
    Ui::MainWindow *ui;

    double  m_dialFreq;
    float   m_rxavg;
    qint32  m_nDevIn;
    qint32  m_nDevOut;
    qint32  m_idInt;
    qint32  m_waterfallAvg;
    qint32  m_pttPort;
    qint32  m_txFreq;
    qint32  m_setftx;
    qint32  m_sec0;
    qint32  m_RxLog;
    qint32  m_nutc0;
    qint32  m_nrx;
    qint32  m_hsym0;
    qint32  m_paInDevice;
    qint32  m_paOutDevice;
    qint32  m_NBslider;
    qint32  m_TRseconds;
    qint32  m_nsps;
    qint32  m_hsymStop;
    qint32  m_inGain;
    qint32  m_nsave;
    qint32  m_nseq;
    qint32  m_ncal;
    qint32  m_ntr;
    qint32  m_nseqdone;
    qint32  m_ntune;
    qint32  m_pctx;
    qint32  m_iptt;
    qint32  m_txFreq0;

    bool    m_receiving;
    bool    m_transmitting;
    bool    m_switching;
    bool    m_diskData;
    bool    m_loopall;
    bool    m_auto;
    bool    m_restart;
    bool    m_startAnother;
    bool    m_saveDecoded;
    bool    m_saveAll;
    bool    m_bdecoded;
    bool    m_rxdone;
    bool    m_rxnormal;
    bool    m_idle;
    bool    m_txdone;
    bool    m_txnext;
    bool    m_hopping;
    bool    m_TxOK;
    bool    m_uploadSpots;
    bool    m_uploading;
    bool    m_bandHop;

    char    m_decoded[80];

    QRect   m_wideGraphGeom;

    QLabel* lab1;                            // labels in status bar
    QLabel* lab2;
    QLabel* lab3;
    QLabel* lab4;
    QLabel* lab5;
    QLabel* lab6;

    QMessageBox msgBox0;

    QFuture<void>* future1;
    QFuture<void>* future2;
    QFuture<void>* future3;
    QFutureWatcher<void>* watcher1;
    QFutureWatcher<void>* watcher2;
    QFutureWatcher<void>* watcher3;

    QNetworkReply* reply;
    QNetworkAccessManager* mNetworkManager;
    QProcess p1;
    QProcess p2;
    QStringList m_decodedList;

    QTimer* pttTimer;
    QTimer* uploadTimer;

    QString m_path;
    QString m_myCall;
    QString m_myGrid;
    QString m_appDir;
    QString m_saveDir;
    QString m_palette;
    QString m_dateTime;
    QString m_mode;
    QString m_fname;

    SoundInThread soundInThread;             //Instantiate the audio threads
    SoundOutThread soundOutThread;

//---------------------------------------------------- private functions
    void readSettings();
    void writeSettings();
    void createStatusBar();
    void updateStatusBar();
    void msgBox(QString t);
    void oneSec();
//    void startRx();
    void startTx();
    void stopTx();
    double tsec();
    void ba2msg(QByteArray ba, char* message);


};

extern void getfile(QString fname, int ntrperiod);
extern void savewav(QString fname, int ntrperiod);
extern void getDev(int* numDevices,char hostAPI_DeviceName[][50],
                   int minChan[], int maxChan[],
                   int minSpeed[], int maxSpeed[]);
extern int ptt(int nport, int itx, int* iptt);


extern "C" {
//----------------------------------------------------- C and Fortran routines
void symspec_(int* k, int* nsps, int* ingain, float* px, float s[],
              float* df3, int* nhsym);
void genwsprx_(char* msg, int itone[], int len1);
}

#endif // MAINWINDOW_H
