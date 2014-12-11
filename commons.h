#ifndef COMMONS_H
#define COMMONS_H
#define TXLENGTH 110592               //27*4096
#define RXLENGTH1 135168              //33*4096
#define RXLENGTH2 33792               //33*1024

extern "C" {
extern struct {
  short int d2[RXLENGTH2];
  int ndop;
  int nfrit;
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
  short int d2a[RXLENGTH1];
} datcom_;                          //This is "common/datcom/..." in fortran
}

#endif // COMMONS_H
