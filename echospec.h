#ifndef GETFILE_H
#define GETFILE_H
#include <QString>
#include <QFile>
#include <QDebug>
#include <QMessageBox>
#include <QDateTime>
#include "commons.h"

QString echospec(bool bSave, QString fname, bool bnetwork, float dphi,
              bool diskData);
int ptt(int nport, int ntx, int* iptt, int* nopen);

extern "C" {
//----------------------------------------------------- C and Fortran routines

void avecho_( short id2[], float* dop, int* nfrit, int* nsum,
              int* nclearave, int* nqual, float* f1, float* rms,
              float* sigdb, float* snr, float* dfreq, float* width,
              float blue[], float red[]);

void avecho65_(float dd[], int* nutc, int* naz, int* nel,
               float* dop, int* iping, float* techo,
               float* fspread, float* fsample, int* i00, float* dphi,
               float* t0, float* f1a, float* dl, float* dc,
               float* pol, float* delta, float* rms1, float* rms2,
               float* snr, float* sigdb, float* dfreq, float* width,
               float red[], float blue[], char outline[], int len);
}
#endif // GETFILE_H
