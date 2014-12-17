#include "soundin.h"
#include <stdexcept>

#define FRAMES_PER_BUFFER 1024

extern "C" {
#include <portaudio.h>
}

extern double inputLatency;

void SoundInThread::run()                           //SoundInThread::run()
{
  if (m_net) {
    qDebug() << "Start input from MAP65";
    inputUDP();
    qDebug() << "Finished input from MAP65()";
    return;
  }

//---------------------------------------------------- Soundcard Setup
  qDebug() << "Start input from soundcard";

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
  qDebug() << "Finished input from soundcard";
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

void SoundInThread::setNetwork(bool b)                          //setNetwork()
{
  m_net = b;
}

//--------------------------------------------------------------- inputUDP()
void SoundInThread::inputUDP()
{
  udpSocket = new QUdpSocket();
  if(!udpSocket->bind(m_udpPort,QUdpSocket::ShareAddress) )
  {
    emit error(tr("UDP Socket bind failed."));
    return;
  }

  // Set this socket's total buffer space for received UDP packets
  int v=141600;
  ::setsockopt(udpSocket->socketDescriptor(), SOL_SOCKET, SO_RCVBUF,
               (char *)&v, sizeof(v));

//  bool qe = quitExecution;
  struct linradBuffer {
    double cfreq;
    int msec;
    float userfreq;
    int iptr;
    quint16 iblk;
    qint8 nrx;
    char iusb;
    double d8[174];
  } b;

  int k=0;

  // Main loop for input of UDP packets over the network:
  for(int ipkt=0; ipkt<3107; ipkt++) {
    if (!udpSocket->hasPendingDatagrams()) {
      msleep(2);                  // Sleep if no packet available
    } else {
      int nBytesRead = udpSocket->readDatagram((char *)&b,1416);
      if (nBytesRead != 1416) qDebug() << "UDP Read Error:" << nBytesRead;

//      qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
      int nsam=-1;
      recvpkt_(&nsam, &b.iblk, &b.nrx, &k, b.d8, b.d8, b.d8);
    }
  }

  qDebug() << "B" << b.iblk << b.nrx << k;
//            emit readyForFFT(k);         //Signal to compute new FFTs
  delete udpSocket;
}
