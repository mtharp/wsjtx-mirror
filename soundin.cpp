#include "soundin.h"
#include <stdexcept>

#define FRAMES_PER_BUFFER 1024

extern "C" {
#include <portaudio.h>
}

typedef struct
{
  int kin;          //Parameters sent to/from the portaudio callback function
  int ncall;
  bool bzero;
  bool receiving;
} paUserData;

//--------------------------------------------------------------- a2dCallback
extern "C" int a2dCallback( const void *inputBuffer, void *outputBuffer,
                         unsigned long framesToProcess,
                         const PaStreamCallbackTimeInfo* timeInfo,
                         PaStreamCallbackFlags statusFlags,
                         void *userData )

// This routine called by the PortAudio engine when samples are available.
// It may be called at interrupt level, so don't do anything
// that could mess up the system like calling malloc() or free().

{
  paUserData *udata=(paUserData*)userData;
  (void) outputBuffer;          //Prevent unused variable warnings.
  (void) timeInfo;
  (void) userData;
  int nbytes,k;

  udata->ncall++;
  if( (statusFlags & paInputOverflow) != 0) {
    qDebug() << "Input Overflow";
  }
  if(udata->bzero) {
    udata->kin=0;              //Reset buffer pointer
    udata->bzero=false;
  }

  nbytes=2*framesToProcess;        //Bytes per frame
  if(udata->kin+framesToProcess >= 12*48000) udata->kin=0;
  k=udata->kin;
  memcpy(&d2com_.d2a[k],inputBuffer,nbytes);      //Copy all samples to d2a

  double sq=0.0;
  for(uint i=0; i<framesToProcess; i++) {
    double x=double(d2com_.d2a[k+i]);
    sq += x*x;
  }
//  if(sq>0.0) qDebug() << "b" << k << sq;
  datcom_.rms = sqrt(sq/framesToProcess);
  udata->kin += framesToProcess;
  d2com_.k=udata->kin;
  return paContinue;
}

extern double inputLatency;

void SoundInThread::run()                           //SoundInThread::run()
{
  if (m_net) {
    qDebug() << "Start input from MAP65";
    inputUDP();
//    qDebug() << "Finished input from MAP65()";
    return;
  }

  quitExecution = false;

//---------------------------------------------------- Soundcard Setup
  qDebug() << "Start input from soundcard";

  PaError paerr;
  PaStreamParameters inParam;
  PaStream *inStream;
  paUserData udata;

  udata.kin=0;                              //Buffer pointer

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
        paClipOff,               //No clipping
        a2dCallback,             //Input callback routine
        &udata);                 //userData

  paerr=Pa_StartStream(inStream);
  if(paerr<0) {
    emit error("Failed to start audio input stream.");
    return;
  }
  m_rxStartTime = QDateTime::currentMSecsSinceEpoch();

//  const PaStreamInfo* p=Pa_GetStreamInfo(inStream);
//  inputLatency = p->inputLatency;
//  qDebug() << "Input latency" << inputLatency;

  bool qe = quitExecution;
  int nsec,nsec0=-1;
  int ns12,ns12z=12;
//  qint64 ms0 = QDateTime::currentMSecsSinceEpoch();

//---------------------------------------------- Soundcard input loop
  while (!qe) {
    qe = quitExecution;
    if (qe) break;
    udata.receiving=m_receiving;
    qint64 ms = QDateTime::currentMSecsSinceEpoch();
    ms=ms % 86400000;
    nsec = ms/1000;             // Time according to this computer
    ns12=nsec % 12;

// Reset buffer pointer at start of a new 12-second interval
    if(ns12 < ns12z) udata.bzero=true;
    ns12z=ns12;

    if(nsec != nsec0) {
      qDebug() << "Soundcard" << ns12 << udata.kin;
      nsec0=nsec;
    }

    msleep(10);
  }
  Pa_StopStream(inStream);
  Pa_CloseStream(inStream);
}

void SoundInThread::setInputDevice(int n)                  //setInputDevice()
{
  if (isRunning()) return;
  this->m_nDevIn=n;
}

void SoundInThread::quit()                                       //quit()
{
  quitExecution = true;
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
  m_udpPort=50004;
  if(!udpSocket->bind(m_udpPort,QUdpSocket::ShareAddress) )
  {
    qDebug() << "UDP Socket bind failed.";
    emit error(tr("UDP Socket bind failed."));
    return;
  }

  // Set this socket's total buffer space for received UDP packets
  int v=141600;
  ::setsockopt(udpSocket->socketDescriptor(), SOL_SOCKET, SO_RCVBUF,
               (char *)&v, sizeof(v));

  bool qe = quitExecution;
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

  quint16 iblk0=0;
  int k=0;
  int nsec,nsec0=-1;
  int ns12,ns12z=12;

  // Main loop for input of UDP packets over the network:
  while (!qe) {
    qe = quitExecution;
    if (qe) break;
    if (!udpSocket->hasPendingDatagrams()) {
      msleep(2);                  // Sleep if no packet available
    } else {
      int nBytesRead = udpSocket->readDatagram((char *)&b,1416);
      if (nBytesRead != 1416) qDebug() << "UDP Read Error:" << nBytesRead;
      if(k != 0 and b.iblk-iblk0 != 1) qDebug() << "Linrad block error" << iblk0 << b.iblk;
      iblk0=b.iblk;

      qint64 ms = QDateTime::currentMSecsSinceEpoch();
      ms=ms % 86400000;
      nsec = ms/1000;             // Time according to this computer
      ns12=nsec % 12;

  // Reset buffer pointer at start of a new 12-second interval
      if(ns12 < ns12z) k=0;
      ns12z=ns12;

      if(nsec != nsec0) {
        qDebug() << "MAP65" << ns12 << k;
        nsec0=nsec;
      }

      int nsam=-1;
      recvpkt_(&nsam, &b.iblk, &b.nrx, &k, b.d8, b.d8, b.d8);
    }
  }

  qDebug() << "Completed input from MAP65" << k;
//            emit readyForFFT(k);         //Signal to compute new FFTs
  delete udpSocket;
}
