#ifndef COMMONS_H
#define COMMONS_H

extern "C" {

extern struct {
  int nutc;                         //UTC as integer, HHMM
  int ndiskdat;                     //1 ==> data read from *.wav file
  short int d2[900*12000];
  float savg[1366];
  float c0[2*900*1500];
} datcom_;

}

#endif // COMMONS_H
