#ifndef MAINWINDOW_H
#define MAINWINDOW_H
#include <QtWidgets>
#include <QTimer>
#include <QDateTime>
#include "soundin.h"
#include "soundout.h"
#include "signalmeter.h"
#include <QtConcurrent/QtConcurrent>
#include <QDebug>

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
  void guiUpdate();
  void p1ReadFromStdout();
  void p1ReadFromStderr();
  void p1Error();
  void p3ReadFromStdout();
  void p3ReadFromStderr();
  void p3Error();

protected:
  virtual void keyPressEvent( QKeyEvent *e );
  void  closeEvent(QCloseEvent*);
  virtual bool eventFilter(QObject *object, QEvent *event);

private slots:
  void on_actionExit_triggered();
  void on_actionAbout_triggered();
  void OnExit();
  void on_actionLinrad_triggered();
  void on_actionCuteSDR_triggered();
  void on_actionOnline_Users_Guide_triggered();
  void on_actionWide_Waterfall_triggered();
  void on_eraseButton_clicked();
  void on_actionAFMHot_triggered();
  void on_actionBlue_triggered();
  void on_inGain_valueChanged(int n);
  void startTx2();
  void stopTx();
  void stopTx2();
  void loggit(QString t);
  void on_bandComboBox_currentIndexChanged(int n);
  void on_actionSettings_triggered();

private:
    Ui::MainWindow *ui;

    double  m_dialFreq;
    float   m_rxavg;
    qint32  m_nDevIn;
    qint32  m_nDevOut;
    qint32  m_idInt;
    qint32  m_waterfallAvg;
    qint32  m_pttMethodIndex;
    qint32  m_pttPort;
    qint32  m_txFreq;
    qint32  m_paInDevice;
    qint32  m_paOutDevice;
    qint32  m_inGain;
    qint32  m_iptt;
    qint32  m_band;
    qint32  m_catPortIndex;
    qint32  m_rig;
    qint32  m_rigIndex;
    qint32  m_serialRate;
    qint32  m_serialRateIndex;
    qint32  m_dataBits;
    qint32  m_dataBitsIndex;
    qint32  m_stopBits;
    qint32  m_stopBitsIndex;
    qint32  m_handshakeIndex;
    qint32  m_COMportOpen;
    qint32  m_sec0;

    bool    m_receiving;
    bool    m_transmitting;
    bool    m_auto;
    bool    m_RxOK;
    bool    m_TxOK;
    bool    m_grid6;
    bool    m_catEnabled;

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

    QProcess p1;
    QProcess p3;

    QTimer* ptt0Timer;
    QTimer* ptt1Timer;

    QString m_path;
    QString m_appDir;
    QString m_palette;
    QString m_dateTime;
    QString m_mode;
    QString m_cmnd;
    QString m_txNext_style;
    QString m_tune_style;
    QString m_catPort;
    QString m_handshake;
    QString m_myGrid;

    SignalMeter *signalMeter;

    SoundInThread soundInThread;             //Instantiate the audio threads
    SoundOutThread soundOutThread;

//---------------------------------------------------- private functions
    void readSettings();
    void writeSettings();
    void createStatusBar();
    void updateStatusBar();
    void msgBox(QString t);
    void oneSec();
    void startRx();
    void startTx();
    void ba2msg(QByteArray ba, char* message);
    QString rig_command();
};

extern void getfile(QString fname, int ntrperiod);
extern void savewav(QString fname, int ntrperiod);
extern void getDev(int* numDevices,char hostAPI_DeviceName[][50],
                   int minChan[], int maxChan[],
                   int minSpeed[], int maxSpeed[]);
extern int ptt(int nport, int itx, int* iptt, int* nopen);


extern "C" {
//----------------------------------------------------- C and Fortran routines
void symspec_(int* k, int* nsps, int* nbfo, int* ingain, float* px,
              float s[], float* df3, int* nhsym);
void genwsprx_(char* msg, int itone[], int len1);
void savec2_(char* fname, int* m_TRseconds, double* m_dialFreq, int len1);
void morse_(char* msg, int* icw, int* ncw, int len);
}

#endif // MAINWINDOW_H
