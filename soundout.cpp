#include "soundout.h"

#define FRAMES_PER_BUFFER 1024

extern "C" {
#include <portaudio.h>
}

extern bool btxok;
extern bool btxMute;
extern double outputLatency;

void SoundOutThread::run()
{
  PaError paerr;
  PaStreamParameters outParam;
  PaStream *outStream;
  static double twopi=2.0*3.141592653589793238462;
  static double phi=0.0;
  static double dphi;
  static int ic27[27]={1,3,7,15,2,5,11,23,18,8,17,6,13,27,26,24,20,12,
                       25,22,16,4,9,19,10,21,14};
  short int buffer[FRAMES_PER_BUFFER];

  outParam.device=m_nDevOut;                 //Output device number
  outParam.channelCount=1;                   //Number of analog channels
  outParam.sampleFormat=paInt16;             //Send short ints to PortAudio
  outParam.suggestedLatency=0.05;
  outParam.hostApiSpecificStreamInfo=NULL;

  paerr=Pa_IsFormatSupported(NULL,&outParam,48000.0);
  if(paerr<0) {
    qDebug() << "PortAudio says requested output format not supported.";
    qDebug() << paerr << m_nDevOut;
    exit(1);
  }

  paerr=Pa_OpenStream(
        &outStream,           //Output stream
        NULL,                 //No input parameters
        &outParam,            //Output parameters
        48000.0,              //Sample rate
        FRAMES_PER_BUFFER,    //Frames per buffer
        paClipOff,            //No clipping
        NULL,                 //No callbeck, use blocking API
        NULL);                //No callback userData

  if(paerr != paNoError) {
    qDebug() << "Failed to open audio output stream.";
    exit(1);
  }
  paerr=Pa_StartStream(outStream);
  if(paerr<0) {
    qDebug() << "Failed to start audio output stream.";
    exit(1);
  }

  m_txStartTime = QDateTime::currentMSecsSinceEpoch();

//  const PaStreamInfo* p=Pa_GetStreamInfo(outStream);
//  outputLatency = p->outputLatency;
//  qDebug() << "Output latency" << outputLatency;

  int nbufs=(27*4096)/FRAMES_PER_BUFFER;
  phi=0.0;
  dphi=twopi*m_txFreq/48000.0;
  double df27=m_Costas*48000.0/4096.0;
  for(int ibuf=0; ibuf<nbufs; ibuf++) {
    if(m_Costas>0) {
      int j=((m_Costas*ibuf)/4) % 27;
      dphi=twopi*(m_txFreq+df27*(ic27[j]-14))/48000.0;
    }
    for(int i=0 ; i<FRAMES_PER_BUFFER; i++ )  {
      phi += dphi;
      if(phi>twopi) phi -= twopi;
      buffer[i]=32767.0*sin(phi);
    }
    paerr=Pa_WriteStream(outStream,buffer,FRAMES_PER_BUFFER);
    if(paerr!=paNoError) {
      qDebug() << "Audio output failed.";
      exit(1);
    }
  }

  Pa_StopStream(outStream);
  Pa_CloseStream(outStream);
  emit endTx();
}

void SoundOutThread::setOutputDevice(int n)      //setOutputDevice()
{
  if (isRunning()) return;
  this->m_nDevOut=n;
}

void SoundOutThread::setTxFreq(int n)
{
  m_txFreq=n;
}

void SoundOutThread::setCostas(int n)
{
  m_Costas=n;
}

qint64 SoundOutThread::txStartTime()
{
  return m_txStartTime;
}
