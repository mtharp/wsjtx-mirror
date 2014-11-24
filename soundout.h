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

// Private members
private:
  qint32  m_nDevOut;            //Output device number
  qint32  m_txFreq;
};

#endif
