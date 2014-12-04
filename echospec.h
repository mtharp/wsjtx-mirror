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
void subtest_(int* a, int* b, int* c);
}
#endif // GETFILE_H
