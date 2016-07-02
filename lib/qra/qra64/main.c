/*
main.c 
QRA64 mode encode/decode test

(c) 2016 - Nico Palermo, IV3NWV

Thanks to Andrea Montefusco IW0HDV for his help on adapting the sources
to OSs other than MS Windows

------------------------------------------------------------------------------
This file is part of the qracodes project, a Forward Error Control
encoding/decoding package based on Q-ary RA (Repeat and Accumulate) LDPC codes.

Files in this package:
   main.c		 - this file
   qra64.c/.h     - qra64 mode encode/decoding functions

   ../qracodes/normrnd.{c,h}   - random gaussian number generator
   ../qracodes/npfwht.{c,h}    - Fast Walsh-Hadamard Transforms
   ../qracodes/pdmath.{c,h}    - Elementary math on probability distributions
   ../qracodes/qra12_63_64_irr_b.{c,h} - Tables for a QRA(12,63) irregular RA 
                                         code over GF(64)
   ../qracodes/qra13_64_64_irr_e.{c,h} - Tables for a QRA(13,64) irregular RA 
                                         code over GF(64)
   ../qracodes/qracodes.{c,h}  - QRA codes encoding/decoding functions

-------------------------------------------------------------------------------

   qracodes is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   qracodes is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with qracodes source distribution.  
   If not, see <http://www.gnu.org/licenses/>.

-----------------------------------------------------------------------------

The code used by the QRA64 mode is the code: QRA13_64_64_IRR_E: K=13
N=64 Q=64 irregular QRA code (defined in qra13_64_64_irr_e.{h,c}).

This code has been designed to include a CRC as the 13th information
symbol and improve the code UER (Undetected Error Rate).  The CRC
symbol is not sent along the channel (the codes are punctured) and the
resulting code is still a (12,63) code with an effective code rate of
R = 12/63.
*/

// OS dependent defines and includes ------------------------------------------

#if _WIN32 // note the underscore: without it, it's not msdn official!
// Windows (x64 and x86)
#include <windows.h>   // required only for GetTickCount(...)
#include <process.h>   // _beginthread
#endif

#if __linux__
#include <unistd.h>
#include <time.h>

unsigned GetTickCount(void) {
    struct timespec ts;
    unsigned theTick = 0U;
    clock_gettime( CLOCK_REALTIME, &ts );
    theTick  = ts.tv_nsec / 1000000;
    theTick += ts.tv_sec * 1000;
    return theTick;
}
#endif

#if __APPLE__
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "qra64.h"
#include "../qracodes/normrnd.h"		   // gaussian numbers generator

// ----------------------------------------------------------------------------

// channel types
#define CHANNEL_AWGN     0
#define CHANNEL_RAYLEIGH 1

void printwordd(char *msg, int *x, int size)
{
  int k;
  printf("\n%s ",msg);
  for (k=0;k<size;k++)
    printf("%2d ",x[k]);
  printf("\n");
}
void printwordh(char *msg, int *x, int size)
{
  int k;
  printf("\n%s ",msg);
  for (k=0;k<size;k++)
    printf("%02hx ",x[k]);
  printf("\n");
}

#define NSAMPLES (QRA64_N*QRA64_M)

static float rp[NSAMPLES];
static float rq[NSAMPLES];
static float chp[NSAMPLES];
static float chq[NSAMPLES];
static float r[NSAMPLES];

float *mfskchannel(int *x, int channel_type, float EbNodB)
{
/*
Simulate an MFSK channel, either AWGN or Rayleigh.

x is a pointer to the transmitted codeword, an array of QRA64_N
integers in the range 0..63.

Returns the received symbol energies (squared amplitudes) as an array of 
(QRA64_M*QRA64_N) floats.  The first QRA64_M entries of this array are 
the energies of the first symbol in the codeword.  The second QRA64_M 
entries are those of the second symbol, and so on up to the last codeword 
symbol.
*/
  const float No = 1.0f;		        // noise spectral density
  const float sigma   = (float)sqrt(No/2.0f);	// std dev of noise I/Q components
  const float sigmach = (float)sqrt(1/2.0f);	// std dev of channel I/Q gains
  const float R = 1.0f*QRA64_K/QRA64_N;	

  float EbNo = (float)pow(10,EbNodB/10);
  float EsNo = 1.0f*QRA64_m*R*EbNo;
  float Es = EsNo*No;
  float A = (float)sqrt(Es);
  int k;

  normrnd_s(rp,NSAMPLES,0,sigma);
  normrnd_s(rq,NSAMPLES,0,sigma);

  if (channel_type == CHANNEL_AWGN) 
    for (k=0;k<QRA64_N;k++) 
      rp[k*QRA64_M+x[k]]+=A;
  else 
    if (channel_type == CHANNEL_RAYLEIGH) {
      normrnd_s(chp,QRA64_N,0,sigmach);
      normrnd_s(chq,QRA64_N,0,sigmach);
      for (k=0;k<QRA64_N;k++) {
	rp[k*QRA64_M+x[k]]+=A*chp[k];
	rq[k*QRA64_M+x[k]]+=A*chq[k];
      }
    }
    else {
      return 0;	// unknown channel type
    }

  // compute the squares of the amplitudes of the received samples
  for (k=0;k<NSAMPLES;k++) 
    r[k] = rp[k]*rp[k] + rq[k]*rq[k];

  return r;
}

// These defines are some packed fields as computed by JT65 
#define CALL_IV3NWV		0x7F85AE7	
#define CALL_K1JT		0xF70DDD7
#define GRID_JN66		0x3AE4		// JN66
#define GRID_73 		0x7ED0		// 73

char decode_type[6][32] = {
  "[?    ?    ?] AP0",
  "[CQ   ?    ?] AP27",
  "[CQ   ?     ] AP42",
  "[CALL ?    ?] AP29",
  "[CALL ?     ] AP44",
  "[CALL CALL ?] AP57"
};

int test_proc_1(int channel_type, float EbNodB, int mode)
{
/*
Here we simulate the following (dummy) QSO:

1) CQ IV3NWV
2)                 IV3NWV K1JT
3) K1JT IV3NWV 73
4)                 IV3NWV K1JT 73

No message repetition is attempted

The QSO is counted as successfull if IV3NWV received the last message
When mode=QRA_AUTOAP each decoder attempts to decode the message sent
by the other station using the a-priori information derived by what
has been already decoded in a previous phase of the QSO if decoding
with no a-priori information has not been successful.

Step 1) K1JT's decoder first attempts to decode msgs of type [? ? ?]
and if this attempt fails, it attempts to decode [CQ/QRZ ? ?]  or
[CQ/QRZ ?] msgs

Step 2) if IV3NWV's decoder is unable to decode K1JT's without AP it
attempts to decode messages of the type [IV3NWV ? ?] and [IV3NWV ?].

Step 3) K1JT's decoder attempts to decode [? ? ?] and [K1JT IV3NWV ?]
(this last decode type has been enabled by K1JT's encoder at step 2)

Step 4) IV3NWV's decoder attempts to decode [? ? ?] and [IV3NWV K1JT
?] (this last decode type has been enabled by IV3NWV's encoder at step
3)

At each step the simulation reports if a decode was successful.  In
this case it also reports the type of decode (see table decode_type
above)

When mode=QRA_NOAP, only [? ? ?] decodes are attempted and no a-priori
information is used by the decoder

The function returns 0 if all of the four messages have been decoded
by their recipients (with no retries) and -1 if any of them could not
be decoded
*/

  int x[QRA64_K], xdec[QRA64_K];
  int y[QRA64_N];
  float *rx;
  int rc;

// Each simulated station must use its own codec, since it might work with
// different a-priori information.
  qra64codec *codec_iv3nwv = qra64_init(mode,CALL_IV3NWV);  // codec for IV3NWV
  qra64codec *codec_k1jt   = qra64_init(mode,CALL_K1JT);    // codec for K1JT

// Step 1a: IV3NWV makes a CQ call (with no grid)
  printf("IV3NWV tx: CQ IV3NWV\n");
  encodemsg_jt65(x,CALL_CQ,CALL_IV3NWV,GRID_BLANK);
  qra64_encode(codec_iv3nwv, y, x);
  rx = mfskchannel(y,channel_type,EbNodB);

// Step 1b: K1JT attempts to decode [? ? ?], [CQ/QRZ ? ?] or [CQ/QRZ ?]
  rc = qra64_decode(codec_k1jt, xdec,rx);
  if (rc>=0) { // decoded
    printf("K1JT   rx: received with apcode=%d %s\n",rc, decode_type[rc]);

// Step 2a: K1JT replies to IV3NWV (with no grid)
    printf("K1JT   tx: IV3NWV K1JT\n");
    encodemsg_jt65(x,CALL_IV3NWV,CALL_K1JT, GRID_BLANK);
    qra64_encode(codec_k1jt, y, x);
    rx = mfskchannel(y,channel_type,EbNodB);

// Step 2b: IV3NWV attempts to decode [? ? ?], [IV3NWV ? ?] or [IV3NWV ?]
    rc = qra64_decode(codec_iv3nwv, xdec,rx);
    if (rc>=0) { // decoded
      printf("IV3NWV rx: received with apcode=%d %s\n",rc, decode_type[rc]);

// Step 3a: IV3NWV replies to K1JT with a 73
      printf("IV3NWV tx: K1JT   IV3NWV 73\n");
      encodemsg_jt65(x,CALL_K1JT,CALL_IV3NWV, GRID_73);
      qra64_encode(codec_iv3nwv, y, x);
      rx = mfskchannel(y,channel_type,EbNodB);

// Step 3b: K1JT attempts to decode [? ? ?] or [K1JT IV3NWV ?]
      rc = qra64_decode(codec_k1jt, xdec,rx);
      if (rc>=0) { // decoded
	printf("K1JT   rx: received with apcode=%d %s\n",rc, decode_type[rc]);

// Step 4a: K1JT replies to IV3NWV with a 73
	printf("K1JT   tx: IV3NWV K1JT   73\n");
	encodemsg_jt65(x,CALL_IV3NWV,CALL_K1JT, GRID_73);
	qra64_encode(codec_k1jt, y, x);
	rx = mfskchannel(y,channel_type,EbNodB);

// Step 4b: IV3NWV attempts to decode [? ? ?], [IV3NWV ? ?], or [IV3NWV ?]
	rc = qra64_decode(codec_iv3nwv, xdec,rx);
	if (rc>=0) { // decoded
	  printf("IV3NWV rx: received with apcode=%d %s\n",rc, decode_type[rc]);
	  return 0;
	}
      }
    }
  }
  printf("the other party did not decode\n");
  return -1;
}

int test_proc_2(int channel_type, float EbNodB, int mode)
{
/*
Here we simulate the decoder of K1JT after K1JT has sent a msg [IV3NWV K1JT]
and IV3NWV sends him the msg [K1JT IV3NWV JN66].

If mode=QRA_NOAP, K1JT decoder attempts to decode only msgs of type [? ? ?].

If mode=QRA_AUTOP, K1JT decoder will attempt to decode also the msgs 
[K1JT IV3NWV] and [K1JT IV3NWV ?].

In the case a decode is successful the return code of the qra64_decode function
indicates the amount of a-priori information required to decode the received 
message according to this table:

 rc=0    [?    ?    ?] AP0
 rc=1    [CQ   ?    ?] AP27
 rc=2    [CQ   ?     ] AP42
 rc=3    [CALL ?    ?] AP29
 rc=4    [CALL ?     ] AP44
 rc=5    [CALL CALL ?] AP57

The return code is <0 when decoding is unsuccessful

This test simulates the situation ntx times and reports how many times
a particular type decode among the above 6 cases succeded.
*/

  int x[QRA64_K], xdec[QRA64_K];
  int y[QRA64_N];
  float *rx;
  int rc,k;

  int ndecok[6] = { 0, 0, 0, 0, 0, 0};
  int ntx = 100,ndec=0;

  qra64codec *codec_iv3nwv = qra64_init(mode,CALL_IV3NWV);   // codec for IV3NWV
  qra64codec *codec_k1jt   = qra64_init(mode,CALL_K1JT);     // codec for K1JT

// This will enable K1JT's decoder to look for IV3NWV calls
  encodemsg_jt65(x,CALL_IV3NWV,CALL_K1JT,GRID_BLANK);
  qra64_encode(codec_k1jt, y, x);
  printf("K1JT   tx: IV3NWV K1JT\n");

  // IV3NWV reply to K1JT
  printf("IV3NWV tx: K1JT IV3NWV JN66\n");
  encodemsg_jt65(x,CALL_K1JT,CALL_IV3NWV,GRID_JN66);
  qra64_encode(codec_iv3nwv, y, x);

  printf("Simulating decodes by K1JT up to AP56 ...");

  for (k=0;k<ntx;k++) {
    printf(".");
    rx = mfskchannel(y,channel_type,EbNodB);
    rc = qra64_decode(codec_k1jt, xdec,rx);
    if (rc>=0) 
      ndecok[rc]++;
  }
  printf("\n");

  printf("Transimtted:%d - Decoded:\n",ntx);
  for (k=0;k<6;k++) {
    printf("%3d with %s\n",ndecok[k],decode_type[k]);
    ndec += ndecok[k];
  }
  printf("Total: %d/%d\n",ndec,ntx);
  printf("\n");

  return 0;
}

void syntax(void)
{
  printf("\nQRA64 Mode Tests\n");
  printf("2016, Nico Palermo - IV3NWV\n\n");
  printf("---------------------------\n\n");
  printf("Syntax: qra64 [-s<snrdb>] [-c<channel>] [-a<ap-type>] [-t<testtype>] [-h]\n");
  printf("Options: \n");
  printf("       -s<snrdb>   : set simulation SNR in 2500 Hz BW (default:-27.5 dB)\n");
  printf("       -c<channel> : set channel type 0=AWGN (default) 1=Rayleigh\n");
  printf("       -a<ap-type> : set decode type 0=NO_AP 1=AUTO_AP (default)\n");
  printf("       -t<testtype>: 0=simulate seq of msgs between IV3NWV and K1JT (default)\n");
  printf("                     1=simulate K1JT receiving K1JT IV3NWV JN66\n");
  printf("       -h: this help\n");
}

int main(int argc, char* argv[])
{
  int k, rc, nok=0;
  float SNRdB = -27.5f;
  unsigned int channel = CHANNEL_AWGN;
  unsigned int mode    = QRA_AUTOAP;
  unsigned int testtype=0;
  int   nqso = 100;
  float EbNodB;

// Parse the command line
  while(--argc) {
    argv++;
    if (strncmp(*argv,"-h",2)==0) {
      syntax();
      return 0;
    } else {
      if (strncmp(*argv,"-a",2)==0) {
	mode = ( int)atoi((*argv)+2);
	if (mode>1) {
	  printf("Invalid decoding mode\n");
	  syntax();
	  return -1;
	}
      } else {
	if (strncmp(*argv,"-s",2)==0) {
	  SNRdB = (float)atof((*argv)+2);
	  if (SNRdB>0 || SNRdB<-40) {
	    printf("SNR should be in the range [-40..0]\n");
	    syntax();
	    return -1;
	  }
	} else {
	  if (strncmp(*argv,"-t",2)==0) {
	    testtype = ( int)atoi((*argv)+2);
	    if (testtype>1) {
	      printf("Invalid test type\n");
	      syntax();
	      return -1;
	    }
	  } else {
	    if (strncmp(*argv,"-c",2)==0) {
	      channel = ( int)atoi((*argv)+2);
	      if (channel>CHANNEL_RAYLEIGH) {
		printf("Invalid channel type\n");
		syntax();
		return -1;
	      }
	    } else {
	      printf("Invalid option\n");
	      syntax();
	      return -1;
	    }
	  }
	}
      }
    }
  }
  
  EbNodB = SNRdB+29.1f;
  
#if defined(__linux__) || defined(__unix__)
  srand48(GetTickCount());
#endif

  if (testtype==0) {
    for (k=0;k<nqso;k++) {
      printf("\n\n------------------------\n");
      rc = test_proc_1(channel, EbNodB, mode);
      if (rc==0)
	nok++;
    }
    printf("\n\n%d/%d QSOs to end without repetitions\n",nok,nqso);
  } else {
    test_proc_2(channel, EbNodB, mode);
  }
  
  printf("SNR = %.1fdB channel=%s ap-mode=%s\n\n",
	 SNRdB,
	 channel==CHANNEL_AWGN?"AWGN":"RAYLEIGH",
	 mode==QRA_NOAP?"NO_AP":"AUTO_AP"
	 );
  return 0;
}
