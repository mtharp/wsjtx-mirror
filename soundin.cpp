#include "soundin.h"
#include <stdexcept>

#define FRAMES_PER_BUFFER 1024

extern "C" {
#include <portaudio.h>
}

extern double inputLatency;

void SoundInThread::run()                           //SoundInThread::run()
{

//---------------------------------------------------- Soundcard Setup
  PaError paerr;
  PaStreamParameters inParam;
  PaStream *inStream;

  inParam.device=m_nDevIn;                  //### Input Device Number ###
  inParam.channelCount=1;                   //Number of analog channels
  inParam.sampleFormat=paInt16;             //Get i*2 from Portaudio
  inParam.suggestedLatency=0.05;
  inParam.hostApiSpecificStreamInfo=NULL;

  paerr=Pa_IsFormatSupported(&inParam,NULL,12000.0);
  if(paerr<0) {
    emit error("PortAudio says requested soundcard format not supported.");
//    return;
  }
  paerr=Pa_OpenStream(
        &inStream,               //Input stream
        &inParam,                //Input parameters
        NULL,                    //No output parameters
        48000.0,                 //Sample rate
        FRAMES_PER_BUFFER,       //Frames per buffer
//        paClipOff+paDitherOff,        //No clipping or dithering
        paClipOff,               //No clipping
        NULL,                    //No callback, use blobking API
        NULL);                   //No userData

  paerr=Pa_StartStream(inStream);
  if(paerr<0) {
    emit error("Failed to start audio input stream.");
    return;
  }
  m_rxStartTime = QDateTime::currentMSecsSinceEpoch();

//  const PaStreamInfo* p=Pa_GetStreamInfo(inStream);
//  inputLatency = p->inputLatency;
//  qDebug() << "Input latency" << inputLatency;

  paerr=Pa_ReadStream(inStream,datcom_.d2a,RXLENGTH1);
  if(paerr!=paNoError) {
    qDebug() << "Audio input failed";
  }
  Pa_StopStream(inStream);
  Pa_CloseStream(inStream);
  emit dataReady(RXLENGTH1);
}

void SoundInThread::setInputDevice(int n)                  //setInputDevice()
{
  if (isRunning()) return;
  this->m_nDevIn=n;
}

void SoundInThread::setReceiving(bool b)                    //setReceiving()
{
  m_receiving = b;
}

void SoundInThread::setPeriod(int ntrperiod, int nsps)
{
  m_TRperiod=ntrperiod;
  m_nsps=nsps;
}

int SoundInThread::mstep()
{
  return m_step;
}

double SoundInThread::samFacIn()
{
  return m_SamFacIn;
}

qint64 SoundInThread::rxStartTime()
{
  return m_rxStartTime;
}
