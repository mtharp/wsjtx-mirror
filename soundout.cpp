#include "soundout.h"

#define FRAMES_PER_BUFFER 4096

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
  static double freq;
  static double fac;
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
  const PaStreamInfo* p=Pa_GetStreamInfo(outStream);
  outputLatency = p->outputLatency;

  int nbufs=2.2*48000.0/FRAMES_PER_BUFFER + 0.5;
  phi=0.0;
  freq=1500.0;
  dphi=twopi*freq/48000.0;
  for(int ibuf=0; ibuf<nbufs; ibuf++) {
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
