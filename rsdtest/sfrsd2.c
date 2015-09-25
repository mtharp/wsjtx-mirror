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
 
 Steve Franke K9AN, Urbana IL, September 2015
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
    int workdat[63];
    int era_pos[51];
    int c, i, numera, nerr, nn=63, kk=12;
    FILE *datfile, *logfile;
    int nsec, maxe, nads;
    float xlambda;
    int nsec2,ncount,dat4[12],bestdat[12];
    int ntrials = *ntrials0;
    int verbose = *verbose0;
    int nhard=0,nhard_min=32768,nsoft=0,nsoft_min=32768, ncandidates;
    int ngmd,nera_best;
    
    logfile=fopen("/tmp/sfrsd.log","a");
    if( !logfile ) {
        printf("Unable to open sfrsd.log\n");
        exit(1);
    }    
    
    // initialize the ka9q reed solomon encoder/decoder
    unsigned int symsize=6, gfpoly=0x43, fcr=3, prim=1, nroots=51;
    rs=init_rs_int(symsize, gfpoly, fcr, prim, nroots, 0);
    
    /*    // debug
     int revdat[12], parity[51], correct[63];
     for (i=0; i<12; i++) {
     revdat[i]=dat4[11-i];
     printf("%d ",revdat[i]);
     }
     printf("\n");
     encode_rs_int(rs,revdat,parity);
     for (i=0; i<63; i++) {
     if( i<12 ) {
     correct[i]=revdat[i];
     printf("%d ",parity[i]);
     } else {
     correct[i]=parity[i-12];
     }
     }
     printf("\n");
     */
    
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
	//        for(i=0; i<12; i++) printf("%2d ",workdat[11-i]);
	//        fprintf(logfile,"\n");
        //fclose(logfile);
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
    float p_erase;
    int thresh, nsum;
    ncandidates=0;
    
    
    for( k=0; k<ntrials; k++) {
        memset(era_pos,0,51*sizeof(int));
        memcpy(workdat,rxdat,sizeof(rxdat));
        
        // mark a subset of the symbols as erasures
        numera=0;
        for (i=0; i<nn; i++) {
            p_erase=0.0;
            if( probs[62-i] >= 255 ) {
                p_erase = 0.5;
            } else if ( probs[62-i] >= 196 ) {
                p_erase = 0.6;
            } else if ( probs[62-i] >= 128 ) {
                p_erase = 0.6;
            } else if ( probs[62-i] >= 32 ) {
                p_erase = 0.6;
            } else {
                p_erase = 0.8;
            }
            thresh = p_erase*100;
            long int ir;
#ifdef WIN32
            ir=rand();
#else
            ir=random();
#endif
            if( ((ir % 100) < thresh ) && numera < 51 ) {
                era_pos[numera]=indexes[62-i];
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
            nsum=0;
            for (i=0; i<63; i++) {
                nsum=nsum+rxprob[i];
                if( workdat[i] != rxdat[i] ) {
                    nhard=nhard+1;
                    nsoft=nsoft+rxprob[i];
                }
            }
            if( nsum != 0 ) {
                nsoft=63*nsoft/nsum;
                if( (nsoft < nsoft_min) ) {
                    nsoft_min=nsoft;
                    nhard_min=nhard;
                    memcpy(bestdat,dat4,12*sizeof(int));
                    memcpy(correct,workdat,63*sizeof(int));
		    ngmd=0;
		    nera_best=numera;
                }
                
            } else {
                fprintf(logfile,"error - nsum %d nsoft %d nhard %d\n",nsum,nsoft,nhard);
            }
	    //            if( ncandidates >= 5000 ) {
            if( ncandidates >= ntrials/2 ) {
                break;
            }
        }
    }
    
    fprintf(logfile,"%d candidates after stochastic loop\n",ncandidates);
    
    // do Forney Generalized Minimum Distance pattern
    for (k=0; k<25; k++) {
        memset(era_pos,0,51*sizeof(int));
        numera=2*k;
        for (i=0; i<numera; i++) {
            era_pos[i]=indexes[62-i];
        }
        
        memcpy(workdat,rxdat,sizeof(rxdat));
        nerr=decode_rs_int(rs,workdat,era_pos,numera,0);
        
        if( nerr >= 0 ) {
            ncandidates=ncandidates+1;
            for(i=0; i<12; i++) dat4[i]=workdat[11-i];
            //            fprintf(logfile,"GMD decode nerr= %3d : ",nerr);
            //            for(i=0; i<12; i++) fprintf(logfile, "%2d ",dat4[i]);
            //            fprintf(logfile,"\n");
            nhard=0;
            nsoft=0;
            nsum=0;
            for (i=0; i<63; i++) {
                nsum=nsum+rxprob[i];
                if( workdat[i] != rxdat[i] ) {
                    nhard=nhard+1;
                    nsoft=nsoft+rxprob[i];
                }
            }
            if( nsum != 0 ) {
                nsoft=63*nsoft/nsum;
                if( (nsoft < nsoft_min) ) {
                    nsoft_min=nsoft;
                    nhard_min=nhard;
                    memcpy(bestdat,dat4,12*sizeof(int));
                    memcpy(correct,workdat,63*sizeof(int));
		    ngmd=1;
		    nera_best=numera;
                }
                
            } else {
                fprintf(logfile,"error - nsum %d nsoft %d nhard %d\n",nsum,nsoft,nhard);
            }
	    //            if( ncandidates >=5000 ) {
            if( ncandidates >= ntrials/2 ) {
                break;
            }
        }
    }
    
    fprintf(logfile,"%d candidates after GMD\n",ncandidates);
    
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

/*  ###
    datfile=fopen(infile,"wb");
    if( !datfile ) {
        printf("Unable to open kvasd.dat\n");
        return 1;
    } else {
        fwrite(&nsec,sizeof(int),1,datfile);
        fwrite(&xlambda,sizeof(float),1,datfile);
        fwrite(&maxe,sizeof(int),1,datfile);
        fwrite(&nads,sizeof(int),1,datfile);
        fwrite(&mrsym,sizeof(int),63,datfile);
        fwrite(&mrprob,sizeof(int),63,datfile);
        fwrite(&mr2sym,sizeof(int),63,datfile);
        fwrite(&mr2prob,sizeof(int),63,datfile);
        fwrite(&nsec2,sizeof(int),1,datfile);
        fwrite(&nhard_min,sizeof(int),1,datfile);
        fwrite(&bestdat,sizeof(int),12,datfile);
        fclose(datfile);
    }
### */
    
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


