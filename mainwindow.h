#ifndef MAINWINDOW_H
#define MAINWINDOW_H
#include <QtWidgets>
#include <QTimer>
#include <QDateTime>
#include "commons.h"
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
  void dataSink();
  void guiUpdate();
  void p1ReadFromStdout();
  void p1ReadFromStderr();
  void p1Error();
  void p3ReadFromStdout();
  void p3ReadFromStderr();
  void p3Error();
  void specReady();
  void stopTx();

protected:
  virtual void keyPressEvent( QKeyEvent *e );
  void  closeEvent(QCloseEvent*);
  virtual bool eventFilter(QObject *object, QEvent *event);

private slots:
  void on_actionExit_triggered();
  void on_actionAbout_triggered();
  void OnExit();
  void on_actionOnline_Users_Guide_triggered();
  void on_actionWide_Waterfall_triggered();
  void on_eraseButton_clicked();
  void on_inGain_valueChanged(int n);
  void startTx2();
  void stopTx2();
  void on_bandComboBox_currentIndexChanged(int n);
  void on_actionSettings_triggered();
  void on_txEnableButton_clicked();
  void on_stopButton_clicked();
  void on_actionAstronomical_data_triggered();

private:
    Ui::MainWindow *ui;

    double  m_s6;
    double  m_freq;

    float   m_rxavg;

    qint32  m_nDevIn;
    qint32  m_nDevOut;
    qint32  m_pttMethodIndex;
    qint32  m_pttPort;
    qint32  m_paInDevice;
    qint32  m_paOutDevice;
    qint32  m_inGain;
    qint32  m_iptt;
    qint32  m_band;
    qint32  m_catPortIndex;
    qint32  m_rig;
    qint32  m_txFreq;
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
    qint32  m_state;
    qint32  m_astroFont;

    bool    m_receiving;
    bool    m_transmitting;
    bool    m_auto;
    bool    m_RxOK;
    bool    m_TxOK;
    bool    m_grid6;
    bool    m_catEnabled;

    QRect   m_astroGeom;
    QRect   m_wideGraphGeom;

    QLabel* lab1;                            // labels in status bar
    QLabel* lab2;
    QLabel* lab3;
    QLabel* lab4;
    QLabel* lab5;
    QLabel* lab6;

    QMessageBox msgBox0;

    QFuture<void>* future1;
    QFutureWatcher<void>* watcher1;

    QProcess p1;
    QProcess p3;

    QTimer* ptt0Timer;
    QTimer* ptt1Timer;

    QString m_path;
    QString m_appDir;
    QString m_dateTime;
    QString m_mode;
    QString m_cmnd;
    QString m_txEnable_style;
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
    QString rig_command();
};

extern void getDev(int* numDevices,char hostAPI_DeviceName[][50],
                   int minChan[], int maxChan[],
                   int minSpeed[], int maxSpeed[]);
extern int ptt(int nport, int itx, int* iptt, int* nopen);
extern void echospec();

extern "C" {
//----------------------------------------------------- C and Fortran routines
void symspec_(int* k, int* nsps, int* nbfo, int* ingain, float* px,
              float s[], float* df3, int* nhsym);
}

#endif // MAINWINDOW_H
