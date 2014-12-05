#ifndef COMMONS_H
#define COMMONS_H
#define LENGTH 110592               //27*4096

extern "C" {
extern struct {
  short int d2[LENGTH];
  int ndop;
  int nfrit;
  int nsmo;
  int nsum;
  int nclearave;
  int nqual;
  float f1;
  float rms;
  float snrdb;
  float dfreq;
  float width;
  float blue[2000];
  float red[2000];
} datcom_;                          //This is "common/datcom/..." in fortran
}

#endif // COMMONS_H
