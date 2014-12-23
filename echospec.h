#ifndef GETFILE_H
#define GETFILE_H
#include <QString>
#include <QFile>
#include <QDebug>
#include <QMessageBox>
#include <QDateTime>
#include "commons.h"

bool echospec(bool bSave, QString fname, bool bnetwork);
int ptt(int nport, int ntx, int* iptt, int* nopen);

extern "C" {
//----------------------------------------------------- C and Fortran routines

void avecho_( short id2[], int* ndop, int* nfrit, int* nsum,
              int* nclearave, int* nqual, float* f1, float* rms,
              float* sigdb, float* snr, float* dfreq, float* width,
              float blue[], float red[]);
}
#endif // GETFILE_H
