#include "echospec.h"
#include <QDir>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifdef WIN32
#include <windows.h>
#endif

void echospec()
{
  double sq=0.0;
  for(int i=0; i<LENGTH; i++) {
    double x=double(datcom_.d2[i]);
    sq += x*x;
  }
  datcom_.rms = sqrt(sq/LENGTH);

//Save raw data to disk.
  QString fname="echo.dat";
  char name[80];
  strcpy(name,fname.toLatin1());
  FILE* fp=fopen(name,"ab");
  if(fp != NULL) {
    fwrite(&datcom_.d2,1,sizeof(datcom_),fp);
    fclose(fp);
/*
    qDebug() << "A" << datcom_.nsum << datcom_.ndop << datcom_.nfrit \
             << datcom_.f1 << datcom_.nclearave << datcom_.rms;
*/
  }

  avecho_(&datcom_.d2[0],&datcom_.ndop,&datcom_.nfrit,&datcom_.f1,     \
      &datcom_.nsum,&datcom_.nclearave,&datcom_.rms,&datcom_.blue[0],  \
      &datcom_.red[0]);
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
