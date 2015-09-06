/*
sfrsd.c 

A rudimentary soft-decision decoder for the JT65 (63,12) code.

This slow and dirty decoding scheme is built around Phil Karn's 
Berlekamp-Massey errors and erasures decoder.
The approach is inspired by the stochastic Chase decoder described
in "Stochastic Chase Decoding of Reed-Solomon Codes", by Leroux et al.,
IEEE Communications Letters, Vol. 14, No. 9, September 2010.
The implementation here is much simpler and probably not nearly as 
effective as the algorithm described therein. Nevertheless, this 
algorithm decodes a significant number of cases that are not 
decoded by errors-only HDD using BM.

Steve Franke K9AN, Urbana IL, September 2015
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "rs.h"

static void *rs;

int main(){
  int hi_there[]={25,57,1,8,29,22,61,14,46,15,56,28};
  int revdat[12];
  int parity[51];
  int rxdat[63], rxprob[63], rxdat2[63], rxprob2[63];
  int correct[63], workdat[63];
  int era_pos[51];
  int i, numera, nerr, nn=63, kk=12;

  FILE *datfile;
  //nsec,xlambda,maxe,nads,mrsym,mrprob,mr2sym,mr2prob
  int nsec, maxe, nads;
  float xlambda;
  int mrsym[63],mrprob[63],mr2sym[63],mr2prob[63];
  int nsec2,ncount,dat4[12];

  datfile=fopen("kvasd.dat","rb");
  if( !datfile ) {
    printf("Unable to open kvasd.dat\n");
    return 1;
  } else {
    fread(&nsec,sizeof(int),1,datfile);
    fread(&xlambda,sizeof(float),1,datfile);
    fread(&maxe,sizeof(int),1,datfile);
    fread(&nads,sizeof(int),1,datfile);
    fread(&mrsym,sizeof(int),63,datfile);
    fread(&mrprob,sizeof(int),63,datfile);
    fread(&mr2sym,sizeof(int),63,datfile);
    fread(&mr2prob,sizeof(int),63,datfile);
    fread(&nsec2,sizeof(int),1,datfile);
    fread(&ncount,sizeof(int),1,datfile);
    fread(&dat4,sizeof(int),12,datfile);
    fclose(datfile);
//    printf("mrsym: ");
//    for (i=0; i<nn; i++) printf("%d ",mrsym[i]);
//    printf("\n");
     
    printf("kv decode: ");
    for (i=0; i<12; i++) printf("%d ",dat4[i]);
    printf("\n");
  }

// initialize the ka9q reed solomon encoder/decoder
  unsigned int symsize=6, gfpoly=0x43, fcr=3, prim=1, nroots=51;
  rs=init_rs_int(symsize, gfpoly, fcr, prim, nroots, 0);
  for (i=0; i<12; i++) revdat[i]=dat4[11-i];;
  encode_rs_int(rs,revdat,parity);
  for (i=0; i<12; i++ ) correct[i]=revdat[i];
  for (i=0; i<51; i++ ) correct[i+12]=parity[i];

// reverse the received symbol vector for bm decoder
  for (i=0; i<63; i++) {
    rxdat[i]=mrsym[62-i];
    rxprob[i]=mrprob[62-i];
    rxdat2[i]=mr2sym[62-i];
    rxprob2[i]=mr2prob[62-i];
  }
  int error,nerror=0;
  for (i=0; i<63; i++) {
    error=0;
    if( correct[i] != rxdat[i] ) error=1;
    nerror+=error;
//    printf("%3d %3d %3d %3d %3d %3d\n",i,correct[i],rxdat[i],rxprob[i],rxprob2[i],error);
  }
  printf("%3d errors\n",nerror);

// sort the mrsym probabilities to find the least reliable symbols
  int k, pass, tmp, nsym=63;
  int probs[63], indexes[63];
  for (i=0; i<63; i++) {
    indexes[i]=i;
    probs[i]=rxprob[i];
  }
  for (pass = 1; pass <= nsym-1; pass++) {
    for (k = 0; k < nsym - pass; k++) {
      if( probs[k] < probs[k+1] ) {
        tmp = probs[k];
        probs[k] = probs[k+1];
        probs[k+1] = tmp;
        tmp = indexes[k];
        indexes[k] = indexes[k+1];
        indexes[k+1] = tmp;
      }
    }
  }

// generate random erasure-locator vectors and see if any of them
// decode. This will generate a list of potential codewords. Some
// suitable metric can be used to decide which member of the list
// is "best". So far, all decodes seem to yield the same vector - 
// so in practice, the list may contain only one unique vector in
// most cases.
//
  int ntrials=10000;
  srandom(time(NULL));
  for( k=0; k<ntrials; k++) {
    memset(era_pos,0,51*sizeof(int));
    // mark a subset of the n-k least reliable symbols as erasures
    numera=0;
    for (i=0; i<(nn-kk); i++) {
      if( random() & 1 ) {
        era_pos[numera]=indexes[i];
        numera=numera+1;
      }
    }
    //  printf("%d %d\n",k,numera);
    memcpy(workdat,rxdat,sizeof(rxdat));
    nerr=decode_rs_int(rs,workdat,era_pos,numera);
    if( nerr >= 0 ) {
      printf("nerr %d\n",nerr);
      printf("sf decode %d: ",k);
      for(i=0; i<12; i++) printf("%d ",workdat[11-i]);
        printf("\n");
    }
  }
  exit(0);
}


