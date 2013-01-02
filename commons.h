#ifndef COMMONS_H
#define COMMONS_H

#define NSMAX 22000

extern "C" {

extern struct {
  int nutc;                         //UTC as integer, HHMM
  int ndiskdat;                     //1 ==> data read from *.wav file
  short int d2[900*12000];
  float savg[1366];
} datcom_;

}

#endif // COMMONS_H
