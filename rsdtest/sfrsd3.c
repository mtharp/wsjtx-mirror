/*
 sfrsd2.c
 
 A soft-decision decoder for the JT65 (63,12) Reed-Solomon code.
 
 This decoding scheme is built around Phil Karn's Berlekamp-Massey
 errors and erasures decoder. The approach is inspired by a number of
 publications, including the stochastic Chase decoder described
 in "Stochastic Chase Decoding of Reed-Solomon Codes", by Leroux et al.,
 IEEE Communications Letters, Vol. 14, No. 9, September 2010 and
 "Soft-Decision Decoding of Reed-Solomon Codes Using Successive Error-
 and-Erasure Decoding," by Soo-Woong Lee and B. V. K. Vijaya Kumar.
 
 Steve Franke K9AN and Joe Taylor K1JT
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include "rs2.h"

static void *rs;

void sfrsd2_(int mrsym[], int mrprob[], int mr2sym[], int mr2prob[], 
	     int* ntrials0, int* verbose0, int correct[], int param[],
	     int indexes[])
{        
    int rxdat[63], rxprob[63], rxdat2[63], rxprob2[63];
    int workdat[63],workdat2[63];
    int era_pos[51];
    int c, i, j, numera, nerr, nn=63, kk=12;
    FILE *datfile, *logfile;
    int ncount,dat4[12],bestdat[12];
    int ntrials = *ntrials0;
    int verbose = *verbose0;
    int nhard=0,nhard_min=32768,nsoft=0,nsoft_min=32768, ncandidates;
    int ngmd,nera_best;
    int perr[8][8] = {
     12,     31,     44,     52,     60,     57,     50,     50,
     28,     38,     49,     58,     65,     69,     64,     80,
     40,     41,     53,     62,     66,     73,     76,     81,
     50,     53,     53,     64,     70,     76,     77,     81,
     50,     50,     52,     60,     71,     72,     77,     84,
     50,     50,     56,     62,     67,     73,     81,     85,
     50,     50,     71,     62,     70,     77,     80,     85,
     50,     50,     62,     64,     71,     75,     82,     87};

    int pmr2[8][8] = {
     29,     23,     19,     13,     10,      0,      0,      0,
     33,     41,     30,     18,     14,     10,      9,      0,
      0,     55,     39,     24,     18,     14,      8,      3,
      0,     56,     53,     32,     23,     18,     14,      9,
      0,     50,     48,     42,     26,     20,     14,     10,
      0,      0,     54,     45,     31,     25,     16,     12,
      0,      0,     68,     47,     40,     30,     23,     14,
      0,      0,    100,     57,     45,     27,     24,     14};

/*    for( i=0; i<8; i++ ) {
      for( j=0; j<8; j++) {
        printf("%d %d %d\n",i,j,perr[i][j]);
      }
    }
*/
    logfile=fopen("sfrsd.log","a");
    if( !logfile ) {
        printf("Unable to open sfrsd.log\n");
        exit(1);
    }    
    
    // initialize the ka9q reed solomon encoder/decoder
    unsigned int symsize=6, gfpoly=0x43, fcr=3, prim=1, nroots=51;
    rs=init_rs_int(symsize, gfpoly, fcr, prim, nroots, 0);

    // reverse the received symbol vector for bm decoder
    for (i=0; i<63; i++) {
        rxdat[i]=mrsym[62-i];
        rxprob[i]=mrprob[62-i];
        rxdat2[i]=mr2sym[62-i];
        rxprob2[i]=mr2prob[62-i];
    }
    
    // sort the mrsym probabilities to find the least reliable symbols
    int k, pass, tmp, nsym=63;
    int probs[63];
    for (i=0; i<63; i++) {
        indexes[i]=i;
        probs[i]=rxprob[i]; // must un-comment sfrsd metrics in demod64a
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
    
    // see if we can decode using BM HDD (and calculate the syndrome vector)
    memset(era_pos,0,51*sizeof(int));
    numera=0;
    memcpy(workdat,rxdat,sizeof(rxdat));
    nerr=decode_rs_int(rs,workdat,era_pos,numera,1);
    if( nerr >= 0 ) {
        fprintf(logfile,"   BM decode nerrors= %3d : ",nerr);
	memcpy(correct,workdat,63*sizeof(int));
	ngmd=-1;
	param[0]=0;
	param[1]=0;
	param[2]=0;
	param[3]=0;
	param[4]=0;
        return;
    }
    
    // generate random erasure-locator vectors and see if any of them
    // decode. This will generate a list of potential codewords. The
    // "soft" distance between each codeword and the received word is
    // used to decide which codeword is "best".
    //
    //  srandom(time(NULL));
#ifdef WIN32
    srand(0xdeadbeef);
#else
    srandom(0xdeadbeef);
#endif
    float ratio, ratio0[63];
    int thresh, nsum;
    int thresh0[63];
    ncandidates=0;

    nsum=0;
    int ii,jj;
    for (i=0; i<nn; i++) {
      nsum=nsum+rxprob[i];
      j = indexes[62-i];
      ratio = (float)rxprob2[j]/(float)rxprob[j];
      ratio0[i]=ratio;
      ii = 7.999*ratio;
      jj = (62-i)/8;
//      printf("i %d ratio %f ii %d jj %d p_erase %d\n",i,ratio,ii,jj,perr[ii][jj]);
      thresh0[i] = 1.1*perr[ii][jj];
    }
    if(nsum==0) return;
    
    for( k=0; k<ntrials; k++) {
        memset(era_pos,0,51*sizeof(int));
        memcpy(workdat,rxdat,sizeof(rxdat));

/* 
Mark a subset of the symbols as erasures.
Run through the ranked symbols, starting with the worst, i=0.
NB: j is the symbol-vector index of the symbol with rank i.
*/
        numera=0;
        for (i=0; i<nn; i++) {
            j = indexes[62-i];
	    thresh=thresh0[i];
            long int ir;
#ifdef WIN32
            ir=rand();
#else
            ir=random();
#endif
            if( ((ir % 100) < thresh ) && numera < 51 ) {
                era_pos[numera]=j;
                numera=numera+1;
            }
        }

        nerr=decode_rs_int(rs,workdat,era_pos,numera,0);
        
        if( nerr >= 0 ) {
            ncandidates=ncandidates+1;
            for(i=0; i<12; i++) dat4[i]=workdat[11-i];
            //            fprintf(logfile,"loop1 decode nerr= %3d : ",nerr);
            //            for(i=0; i<12; i++) fprintf(logfile, "%2d ",dat4[i]);
            //            fprintf(logfile,"\n");

            nhard=0;
            nsoft=0;
            for (i=0; i<63; i++) {
                if(workdat[i] != rxdat[i]) {
                    nhard=nhard+1;
		    if(workdat[i] != rxdat2[i]) {
		      nsoft=nsoft+rxprob[i];
		    } else {
		      nsoft=nsoft+rxprob[i]/2;     //??? empirical ???
		    }
                }
            }
	    nsoft=63*nsoft/nsum;
	    if( (nsoft < nsoft_min) ) {
	      nsoft_min=nsoft;
	      nhard_min=nhard;
	      memcpy(bestdat,dat4,12*sizeof(int));
	      memcpy(correct,workdat,63*sizeof(int));
	      ngmd=0;
	      nera_best=numera;
	    }
	    if(nsoft_min < 27) break;
            if((nsoft_min < 32) && (nhard_min < 43) && 
		(nhard_min+nsoft_min) < 74) break;
        }
    }
    
    fprintf(logfile,"%d trials and %d candidates after stochastic loop\n",k,ncandidates);

    if( (ncandidates >= 0) && (nsoft_min < 36) && (nhard_min < 44) ) {
        for (i=0; i<63; i++) {
            fprintf(logfile,"%3d %3d %3d %3d %3d %3d\n",i,correct[i],rxdat[i],rxprob[i],rxdat2[i],rxprob2[i]);
            //            fprintf(logfile,"%3d %3d %3d %3d %3d\n",i,workdat[i],rxdat[i],rxprob[i],rxdat2[i],rxprob2[i]);
        }
        
        fprintf(logfile,"**** ncandidates %d nhard %d nsoft %d nsum %d\n",ncandidates,nhard_min,nsoft_min,nsum);
    } else {
        nhard_min=-1;
        memset(bestdat,0,12*sizeof(int));
    }
    
    fprintf(logfile,"exiting sfrsd\n");
    fflush(logfile);
    fclose(logfile);
    param[0]=ncandidates;
    param[1]=nhard_min;
    param[2]=nsoft_min;
    param[3]=nera_best;
    param[4]=ngmd;
    if(param[0]==0) param[2]=-1;
    return;
}


