#include "getfile.h"
#include <QDir>
#include <stdlib.h>
#include <math.h>

#ifdef WIN32
#include <windows.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#include <termios.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <unistd.h>
#include <err.h>
#endif

void getfile(QString fname, int ntrperiod)
{
  struct WAVHDR {
    char ariff[4];
    int lenfile;
    char awave[4];
    char afmt[4];
    int lenfmt;
    short nfmt2;
    short nchan2;
    int nsamrate;
    int nbytesec;
    short nbytesam2;
    short nbitsam2;
    char adata[4];
    int ndata;
  } hdr;

  char name[512];
  strncpy(name,fname.toLatin1(), sizeof (name) - 1);
  name[sizeof (name) - 1] = '\0';

  FILE* fp=fopen(name,"rb");

  int i1=fname.lastIndexOf("/");
  QString baseName=fname.mid(i1+1);

  int i0=fname.indexOf(".wav",0,Qt::CaseInsensitive);
  jt9com_.nutc=0;
  if(i0>0) {
    int n=4;
    if(baseName.length()!=15) n=6;
    jt9com_.nutc=100*fname.mid(i0-n,2).toInt() + fname.mid(i0-n+2,2).toInt();
  }
  int npts=ntrperiod*12000;
  memset(jt9com_.d2,0,2*npts);

  if(fp != NULL) {
// Read (and ignore) a 44-byte WAV header; then read data
    int n=fread(&hdr,1,44,fp);
    n=fread(jt9com_.d2,2,npts,fp);
    if(hdr.nsamrate==11025) wav12_(jt9com_.d2,jt9com_.d2,&n,&hdr.nbitsam2);
    fclose(fp);
    jt9com_.newdat=1;
    jt9com_.kin=n;
  }
}

void savewav(QString fname, int ntrperiod)
{
  struct {
    char ariff[4];         //ChunkID:    "RIFF"
    int nchunk;            //ChunkSize: 36+SubChunk2Size
    char awave[4];         //Format: "WAVE"
    char afmt[4];          //Subchunk1ID: "fmt "
    int lenfmt;            //Subchunk1Size: 16
    short int nfmt2;       //AudioFormat: 1
    short int nchan2;      //NumChannels: 1
    int nsamrate;          //SampleRate: 12000
    int nbytesec;          //ByteRate: SampleRate*NumChannels*BitsPerSample/8
    short int nbytesam2;   //BlockAlign: NumChannels*BitsPerSample/8
    short int nbitsam2;    //BitsPerSample: 16
    char adata[4];         //Subchunk2ID: "data"
    int ndata;             //Subchunk2Size: numSamples*NumChannels*BitsPerSample/8
  } hdr;

  int npts=ntrperiod*12000;
//  qint16* buf=(qint16*)malloc(2*npts);
  char name[512];
  strncpy(name,fname.toLatin1(),sizeof (name) - 1);
  name[sizeof (name) - 1] = '\0';
  FILE* fp=fopen(name,"wb");

  if(fp != NULL) {
// Write a WAV header
    hdr.ariff[0]='R';
    hdr.ariff[1]='I';
    hdr.ariff[2]='F';
    hdr.ariff[3]='F';
    hdr.nchunk=36 + 2*npts;
    hdr.awave[0]='W';
    hdr.awave[1]='A';
    hdr.awave[2]='V';
    hdr.awave[3]='E';
    hdr.afmt[0]='f';
    hdr.afmt[1]='m';
    hdr.afmt[2]='t';
    hdr.afmt[3]=' ';
    hdr.lenfmt=16;
    hdr.nfmt2=1;
    hdr.nchan2=1;
    hdr.nsamrate=12000;
    hdr.nbytesec=2*12000;
    hdr.nbytesam2=2;
    hdr.nbitsam2=16;
    hdr.adata[0]='d';
    hdr.adata[1]='a';
    hdr.adata[2]='t';
    hdr.adata[3]='a';
    hdr.ndata=2*npts;

    fwrite(&hdr,sizeof(hdr),1,fp);
//    memcpy(jt9com_.d2,buf,2*npts);
//    fwrite(buf,2,npts,fp);
    fwrite(jt9com_.d2,2,npts,fp);
    fclose(fp);
  }
//  free(buf);
}

//#define	MAX_RANDOM	0x7fffffff

/* Generate gaussian random float with mean=0 and std_dev=1 */
float gran()
{
  float fac,rsq,v1,v2;
  static float gset;
  static int iset;

  if(iset){
    /* Already got one */
    iset = 0;
    return gset;
  }
  /* Generate two evenly distributed numbers between -1 and +1
   * that are inside the unit circle
   */
  do {
    v1 = 2.0 * (float)rand() / RAND_MAX - 1;
    v2 = 2.0 * (float)rand() / RAND_MAX - 1;
    rsq = v1*v1 + v2*v2;
  } while(rsq >= 1.0 || rsq == 0.0);
  fac = sqrt(-2.0*log(rsq)/rsq);
  gset = v1*fac;
  iset++;
  return v2*fac;
}

int ptt(int nport, int ntx, int* iptt, int* nopen)
{
#ifdef WIN32
  static HANDLE hFile;
  char s[10];
  int i3=1,i4=1,i5=1,i6=1,i9=1,i00=1;  //Defs to silence compiler warning

  if(nport==0) {
    *iptt=ntx;
    return 0;
  }

  if(ntx && (!(*nopen))) {
    sprintf(s,"\\\\.\\COM%d",nport);
    hFile=CreateFile(TEXT(s),GENERIC_WRITE,0,NULL,OPEN_EXISTING,
                     FILE_ATTRIBUTE_NORMAL,NULL);
    if(hFile==INVALID_HANDLE_VALUE) {
      QString t;
      t.sprintf("Cannot open COM port %d for PTT\n",nport);
      return 1;
    }
    *nopen=1;
  }

  if(ntx && *nopen) {
    i3=EscapeCommFunction(hFile,SETRTS);
    i5=EscapeCommFunction(hFile,SETDTR);
    *iptt=1;
  }

  else {
    i4=EscapeCommFunction(hFile,CLRRTS);
    i6=EscapeCommFunction(hFile,CLRDTR);
    i9=EscapeCommFunction(hFile,CLRBREAK);
    i00=CloseHandle(hFile);
    *iptt=0;
    *nopen=0;
  }
  if((i3+i4+i5+i6+i9+i00)==-999) return 1;    //Silence compiler warning
  return 0;
#else
  int control=TIOCM_RTS | TIOCM_DTR;
//  int control = TIOCM_RTS;
  static int fd;

  if(*nopen==0) {
    fd=open("/dev/ttyUSB0",O_RDWR | O_NONBLOCK);
    if(fd<0) {
      return -1;
    }
    *nopen=1;
  }

  if(ntx) {
    ioctl(fd, TIOCMBIS, &control);
    *iptt=1;
    *nopen=1;
  } else {
    ioctl(fd, TIOCMBIC, &control);
    close(fd);
    *iptt=0;
    *nopen=0;
  }
  return 0;
#endif
  if((nport+ntx+(*iptt)==-99999)) *nopen=0;   //Silence compiler warning
  return 0;
}
