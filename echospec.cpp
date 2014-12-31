#include "echospec.h"
#include <QDir>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifdef WIN32
#include <windows.h>
#endif

bool echospec(bool bSave, QString fname, bool bnetwork, float dphi,
              bool diskData)
{
  bool dataWritten=false;

  int k0=0;
  if(bnetwork) {
    if(r4com_.kstop > 6*96000) k0=6*4*96000;
    qDebug() << "AA" << r4com_.kstop << k0;
  } else {
    datcom_.nqual=0;
    if(d2com_.kstop > 6*48000) k0=6*48000;
  }

  if(bSave and !diskData) {
    char name[80];
    strcpy(name,fname.toLatin1());
    FILE* fp=fopen(name,"ab");
    if(fp != NULL) {
      fwrite(&datcom_.dop,4,10,fp);                //Header info
      if(bnetwork) {
        fwrite(&r4com_.techo,4,3,fp);              //More header info
        fwrite(&r4com_.dd[k0],4,4*520000,fp);      //Raw MAP65 data
      } else {
        fwrite(&d2com_.d2a[k0],2,260000,fp);       //Raw soundcard data
      }
      dataWritten=true;
      fclose(fp);
    }
  }


  if(bnetwork) {
    float dop=float(datcom_.dop);
    int i00=4;
    float t0=0.0;
    float f1a=0.0;
    float dl=0.0;
    float dc=0.0;
    float pol=0.0;
    float delta=0.0;
    float snr=0.0;
    float rms1=0.0;
    float rms2=0.0;
    float techo=r4com_.techo;
    float fspread=r4com_.fspread;
    if(diskData) {                          //###
      techo=2.44;
      fspread=2.0;
    }
    datcom_.nsum=datcom_.nsum % 20;

    avecho65_(&r4com_.dd[k0], &dop, &datcom_.nsum, &techo,
              &fspread, &r4com_.fsample, &i00, &dphi, &t0,
              &f1a, &r4com_.dl, &r4com_.dc, &r4com_.pol, &r4com_.delta,
              &rms1, &rms2, &snr, &datcom_.sigdb, &datcom_.dfreq,
              &datcom_.width, &datcom_.red[0], &datcom_.blue[0]);

    datcom_.nclearave=0;
    datcom_.nqual=int(snr+0.5);
    datcom_.rms=0.5*(rms1+rms2);
  } else {
    float snr=0;
    avecho_(&d2com_.d2a[k0],&datcom_.dop,&datcom_.nfrit,
        &datcom_.nsum,&datcom_.nclearave,&datcom_.nqual,
        &datcom_.f1,&datcom_.rms,&datcom_.sigdb,&snr,&datcom_.dfreq,
        &datcom_.width,&datcom_.blue[0],&datcom_.red[0]);
  }
  return dataWritten;
}

int ptt(int nport, int ntx, int* iptt, int* nopen)
{
#ifdef WIN32
  static HANDLE hFile;
  char s[10];
  int i3=1,i4=1,i5=1,i6=1,i9=1,i00=1;

  if(nport==0) {
    *iptt=ntx;
    return(0);
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
  if((i3+i4+i5+i6+i9+i00)==-99) return 1;    // Silence compiler warning
  return 0;
#endif
}
