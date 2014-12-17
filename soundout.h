#ifndef SOUNDOUT_H
#define SOUNDOUT_H
#include <QtCore>
#include <QDebug>

// An instance of this thread sends audio data to a specified soundcard.
// Output can be muted while underway, preserving waveform timing when
// transmission is resumed.

class SoundOutThread : public QThread
{
  Q_OBJECT

protected:
  virtual void run();

public:
// Constructs (but does not start) a SoundOutThread
  SoundOutThread()
  {
  }

public:
  void setOutputDevice(qint32 n);
  void setTxFreq(int n);
  void setCostas(int n);
  qint64 txStartTime();

signals:
  void endTx();

// Private members
private:
  qint64  m_txStartTime;
  qint32  m_nDevOut;            //Output device number
  qint32  m_txFreq;
  qint32  m_Costas;
};

#endif
