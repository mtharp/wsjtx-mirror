#ifndef WIDEGRAPH_H
#define WIDEGRAPH_H
#include <QDialog>

namespace Ui {
  class WideGraph;
}

class WideGraph : public QDialog
{
  Q_OBJECT

public:
  explicit WideGraph(QWidget *parent = 0);
  ~WideGraph();

  void   dataSink2(float s[], float df3, int ihsym, int ndiskdata);
  void   saveSettings();
  void   setPalette(QString palette);
  void   setFsample(int n);
  void   setPeriod(int ntrperiod, int nsps);
  void   setTxFreq(int n);
  void   setDialFreq(double f);
  void   setTxed();
  double dialFreq();
  int    txFreq();

  qint32 m_qsoFreq;

signals:
  void freezeDecode2(int n);
  void f11f12(int n);

public slots:
  void wideFreezeDecode(int n);

protected:
  virtual void keyPressEvent( QKeyEvent *e );

private slots:
  void on_waterfallAvgSpinBox_valueChanged(int arg1);
  void on_zeroSpinBox_valueChanged(int arg1);
  void on_gainSpinBox_valueChanged(int arg1);

  void on_cbCumulative_toggled(bool checked);

  void on_cbRFscale_toggled(bool checked);

private:
  qint32 m_waterfallAvg;
  qint32 m_fCal;
  qint32 m_fSample;
  qint32 m_TRperiod;
  qint32 m_nsps;
  qint32 m_ntr0;

  double m_dialFreq;

  Ui::WideGraph *ui;
};

#ifdef WIN32
extern int set570(double freq_MHz);
#endif

#endif // WIDEGRAPH_H
