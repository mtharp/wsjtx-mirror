#include <stdio.h>
#include "rs.h"

static void *rs5,*rs8,*rs13;
static int nn,kk,nroots;
static int first=1;

#ifdef CVF
void __stdcall KRSENCODE(int *dgen, int *kk0, int *sent)
#else
  void krsencode_(int *dgen, int *kk0, int *sent)
#endif
     // Encode JT65 data dgen[12], producing sent[63].
{
  int dat1[13];
  int b[63];
  int i;

  if(first) {
    // Initialize parameters for three RS codecs
    rs5=init_rs_int(6,0x43,3,1,58,0);       // nbit=30
    rs8=init_rs_int(6,0x43,3,1,55,0);       // nbit=48
    rs13=init_rs_int(6,0x43,3,1,50,0);      // nbit=78
    nn=63;
    first=0;
  }

  kk=*kk0;
  nroots=nn-kk;

  // Reverse data order for the Karn codec.
  for(i=0; i<kk; i++) {
    dat1[i]=dgen[kk-1-i];
  }
  // Compute the parity symbols
  if(kk==5) encode_rs_int(rs5,dat1,b);
  if(kk==8) encode_rs_int(rs8,dat1,b);
  if(kk==13) encode_rs_int(rs13,dat1,b);

  // Move parity symbols and data into sent[] array, in reverse order.
  for (i = 0; i < nroots; i++) sent[nroots-1-i] = b[i];
  for (i = 0; i < kk; i++) sent[i+nroots] = dat1[kk-1-i];
}

#ifdef CVF
void __stdcall KRSDECODE(int *recd0, int *kk0, int *era0, int *numera0, int *decoded, int *nerr)
#else
  void krsdecode_(int *recd0, int *kk0, int *era0, int *numera0, int *decoded, int *nerr)
#endif
     // Decode JT65 received data recd0[63], producing decoded[12].
     // Erasures are indicated in era0[numera].  The number of corrected
     // errors is *nerr.  If the data are uncorrectable, *nerr=-1 is
     // returned.
{
  int numera;
  int i;
  int era_pos[50];
  int recd[63];

  if(first) {
    // Initialize parameters for three RS codecs
    rs5=init_rs_int(6,0x43,3,1,58,0);       // nbit=30
    rs8=init_rs_int(6,0x43,3,1,55,0);       // nbit=48
    rs13=init_rs_int(6,0x43,3,1,50,0);      // nbit=78
    nn=63;
    first=0;
  }

  kk=*kk0;
  nroots=nn-kk;
  numera=*numera0;
  for(i=0; i<kk; i++) recd[i]=recd0[nn-1-i];
  for(i=0; i<nroots; i++) recd[kk+i]=recd0[nroots-1-i];
  if(numera) 
    for(i=0; i<numera; i++) era_pos[i]=era0[i];

  if(kk==5) *nerr=decode_rs_int(rs5,recd,era_pos,numera);
  if(kk==8) *nerr=decode_rs_int(rs8,recd,era_pos,numera);
  if(kk==13) *nerr=decode_rs_int(rs13,recd,era_pos,numera);

  for(i=0; i<kk; i++) decoded[i]=recd[kk-1-i];
}
