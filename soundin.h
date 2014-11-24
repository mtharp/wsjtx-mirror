#ifndef SOUNDIN_H
#define SOUNDIN_H

#include <QtCore>
#include <QDebug>


// Reads audio data from soundcard
class SoundInThread : public QThread
{
  Q_OBJECT

protected:
  virtual void run();

public:
  SoundInThread()
  {
  }

  void setInputDevice(qint32 n);
  void setReceiving(bool b);
  void setPeriod(int ntrperiod, int nsps);
  int  mstep();
  double samFacIn();

signals:
  void dataReady(int k);
  void error(const QString& message);
  void status(const QString& message);

public slots:

private:
  double m_SamFacIn;                    //(Input sample rate)/12000.0
  qint32 m_step;
  qint32 m_nDevIn;
  qint32 m_TRperiod;
  qint32 m_TRperiod0;
  qint32 m_nsps;
  bool   m_receiving;
};
#endif // SOUNDIN_H
