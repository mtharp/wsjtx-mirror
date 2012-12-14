#ifndef MAINWINDOW_H
#define MAINWINDOW_H
#include <QtGui>
#include <QTimer>
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
  void guiUpdate();
  void readFromStdout();
  void readFromStderr();
  void jt9_error();

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
  void on_actionF4_sets_Tx6_triggered();
  void on_actionNo_shorthands_if_Tx1_triggered();
  void on_actionNone_triggered();
  void on_actionSave_all_triggered();
  void on_actionKeyboard_shortcuts_triggered();
  void on_actionSpecial_mouse_commands_triggered();
  void on_actionAvailable_suffixes_and_add_on_prefixes_triggered();
  void decode();
  void decodeBusy(bool b);
  void on_EraseButton_clicked();
  void set_ntx(int n);
  void on_actionErase_wsjtx_rx_log_triggered();
  void on_actionErase_wsjtx_tx_log_triggered();
  void on_actionAFMHot_triggered();
  void on_actionBlue_triggered();
  void on_actionWSPR_2_triggered();
  void on_actionWSPR_30_triggered();
  void on_actionWSPR_15_triggered();
  void on_actionSave_decoded_triggered();
  void on_actionQuickDecode_triggered();
  void on_actionMediumDecode_triggered();
  void on_actionDeepestDecode_triggered();
  void on_inGain_valueChanged(int n);
  void on_actionMonitor_OFF_at_startup_triggered();
  void on_TxNextButton_clicked();

private:
    Ui::MainWindow *ui;
    qint32  m_nDevIn;
    qint32  m_nDevOut;
    qint32  m_idInt;
    qint32  m_waterfallAvg;
    qint32  m_tol;
    qint32  m_QSOfreq0;
    qint32  m_ntx;
    qint32  m_pttPort;
    qint32  m_timeout;
    qint32  m_txFreq;
    qint32  m_setftx;
    qint32  m_ndepth;
    qint32  m_sec0;
    qint32  m_RxLog;
    qint32  m_nutc0;
    qint32  m_nrx;
    qint32  m_hsym0;
    qint32  m_paInDevice;
    qint32  m_paOutDevice;
    qint32  m_NBslider;
    qint32  m_TRperiod;
    qint32  m_nsps;
    qint32  m_hsymStop;
    qint32  m_len1;
    qint32  m_inGain;
    qint32  m_nsave;

    bool    m_monitoring;
    bool    m_transmitting;
    bool    m_diskData;
    bool    m_loopall;
    bool    m_decoderBusy;
    bool    m_txFirst;
    bool    m_auto;
    bool    m_restart;
    bool    m_startAnother;
    bool    m_saveDecoded;
    bool    m_saveAll;
    bool    m_widebandDecode;
    bool    m_kb8rq;
    bool    m_NB;
    bool    m_call3Modified;
    bool    m_dataAvailable;
    bool    m_bsynced;
    bool    m_bdecoded;
    bool    m_monitorStartOFF;

    char    m_decoded[80];

    float   m_pctZap;

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

    QProcess proc_jt9;

    QString m_path;
    QString m_pbdecoding_style1;
    QString m_pbmonitor_style;
    QString m_pbAutoOn_style;
    QString m_myCall;
    QString m_myGrid;
    QString m_hisCall;
    QString m_hisGrid;
    QString m_appDir;
    QString m_saveDir;
    QString m_dxccPfx;
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
    void ba2msg(QByteArray ba, char* message);
    void msgtype(QString t, QLineEdit* tx);
    void stub();
};

extern void getfile(QString fname, int ntrperiod);
extern void savewav(QString fname, int ntrperiod);
extern int killbyname(const char* progName);
extern void getDev(int* numDevices,char hostAPI_DeviceName[][50],
                   int minChan[], int maxChan[],
                   int minSpeed[], int maxSpeed[]);
extern int ptt(int nport, int itx, int* iptt);


extern "C" {
//----------------------------------------------------- C and Fortran routines
void symspec_(int* k, int* ntrperiod, int* nsps, int* ingain, int* nb,
              int* m_NBslider, float* px, float s[], float red[],
              float* df3, int* nhsym, int* nzap, float* slimit,
              uchar lstrong[], int* npts8);
/*
void genjt9_(char* msg, int* ichk, char* msgsent, int itone[],
             int* itext, int len1, int len2);
*/
//void decoder_(int* ntrperiod, int* ndepth, int* mRxLog, float c0[]);
}

#endif // MAINWINDOW_H
