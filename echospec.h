#ifndef GETFILE_H
#define GETFILE_H
#include <QString>
#include <QFile>
#include <QDebug>
#include <QMessageBox>
#include "commons.h"

void echospec();
int ptt(int nport, int ntx, int* iptt, int* nopen);

extern "C" {
//----------------------------------------------------- C and Fortran routines

void avecho_( short id2[], int* ndop, int* nfrit, int* nsum,
              int* nclearave, int* nqual, float* f1, float* rms,
              float* snrdb, float* dfreq, float* width,
              float blue[], float red[]);
}
#endif // GETFILE_H
