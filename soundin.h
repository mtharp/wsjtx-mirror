#ifndef SOUNDIN_H
#define SOUNDIN_H

#include <QtCore>
#include <QtNetwork/QUdpSocket>
#include <QDebug>
#include "commons.h"

#ifdef Q_OS_WIN32
#include <winsock.h>
#else
#include <sys/socket.h>
#endif //Q_OS_WIN32

// Reads audio data from soundcard
class SoundInThread : public QThread
{
  Q_OBJECT
  bool quitExecution;           // if true, thread exits gracefully

protected:
  virtual void run();

public:
  SoundInThread():
    quitExecution(false)
  {
  }

  void setNetwork(bool b);
  void setInputDevice(qint32 n);
  void setReceiving(bool b);
  void setPeriod(int ntrperiod, int nsps);
  int  mstep();
  double samFacIn();
  qint64 rxStartTime();

signals:
  void dataReady(int k);
  void error(const QString& message);
  void status(const QString& message);

public slots:
  void quit();

private:
  void inputUDP();

  double m_SamFacIn;                    //(Input sample rate)/12000.0

  qint64  m_rxStartTime;

  qint32 m_step;
  qint32 m_nDevIn;
  qint32 m_TRperiod;
  qint32 m_TRperiod0;
  qint32 m_nsps;
  qint32 m_udpPort;

  bool   m_receiving;
  bool   m_net;

  QUdpSocket *udpSocket;

};

extern "C" {
  void recvpkt_(int* nsam, quint16* iblk, qint8* nrx, int* k, double s1[],
                double s2[], double s3[]);
}

#endif // SOUNDIN_H
