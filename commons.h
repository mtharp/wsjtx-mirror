#ifndef COMMONS_H
#define COMMONS_H
#define TXLENGTH 110592               //27*4096
#define RXLENGTH1 135168              //33*4096
#define RXLENGTH2 33792               //33*1024

extern "C" {
extern struct {
  float dop;
  int nfrit;
  int nsum;
  int nclearave;
  int nqual;
  float f1;
  float rms;
  float sigdb;
  float dfreq;
  float width;
  float blue[2000];
  float red[2000];
  short int d2[RXLENGTH2];
} datcom_;                          //This is "common/datcom/..." in fortran

extern struct {
  short int d2a[576000];            //12*48000
  int k;
  int kstop;
} d2com_;

extern struct {
  float dd[4608000];                //12*4*96000
  int k;
  int kstop;
  int nutc;
  int naz;
  int nel;
  float techo;
  float fspread;
  float fsample;
  float dl;
  float dc;
  float pol;
  float delta;
} r4com_;
}

#endif // COMMONS_H
