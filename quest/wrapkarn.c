#include <stdio.h>
#include "rs.h"

void *rs;
static int first=1;
static int nn,kk,nroots,npad;

void rs_init__(int *mm, int *nq, int *nn0, int *kk0, int *nfz)
{
  nn=*nn0;
  kk=*kk0;
  nroots=nn-kk;
  npad=*nq-1-nn;
  rs=init_rs_int(*mm,0x43,*nfz,1,nroots,npad);
  first=0;
}

void rs_encode__(int *dgen, int *sent)
     // Encode JT65 data dgen[12], producing sent[63].
{
  int dat1[23];
  int b[63];
  int i;

  // Reverse data order for the Karn codec.
  for(i=0; i<kk; i++) {
    dat1[i]=dgen[kk-1-i];
  }
  // Compute the parity symbols
  encode_rs_int(rs,dat1,b);

  // Move parity symbols and data into sent[] array, in reverse order.
  for (i = 0; i < nroots; i++) sent[nroots-1-i] = b[i];
  for (i = 0; i < kk; i++) sent[i+nroots] = dat1[kk-1-i];
}

void rs_decode__(int *recd0, int *era0, int *numera0, int *decoded, int *nerr)
     // Decode JT65 received data recd0[63], producing decoded[12].
     // Erasures are indicated in era0[numera].  The number of corrected
     // errors is *nerr.  If the data are uncorrectable, *nerr=-1 is
     // returned.
{
  int numera;
  int i;
  int era_pos[50];
  int recd[63];

  numera=*numera0;
  for(i=0; i<kk; i++) recd[i]=recd0[nn-1-i];
  for(i=0; i<nroots; i++) recd[kk+i]=recd0[nroots-1-i];
  if(numera) 
    for(i=0; i<numera; i++) era_pos[i]=era0[i];
  *nerr=decode_rs_int(rs,recd,era_pos,numera);
  for(i=0; i<kk; i++) decoded[i]=recd[kk-1-i];
}
