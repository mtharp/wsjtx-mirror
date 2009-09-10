/* Viterbi decoder for arbitrary convolutional code
 * viterbi27 and viterbi37 for the r=1/2 and r=1/3 K=7 codes are faster
 * Copyright 1999 Phil Karn, KA9Q
 * May be used under the terms of the GNU Public License
 */

/* Select code here */

#define V215

#ifdef V215
#define	K 15			/* Constraint length */
#define N 2			/* Number of symbols per data bit */
#define Polys	Poly215		/* Select polynomials here */
#endif

#ifdef V414
#define	K 14			/* Constraint length */
#define N 4			/* Number of symbols per data bit */
#define Polys	Poly414		/* Select polynomials here */
#endif

#ifdef V615
#define	K 15			/* Constraint length */
#define N 6			/* Number of symbols per data bit */
#define Polys	Poly615		/* Select polynomials here */
#endif

/* Rate 1/2 codes */
unsigned int Poly23[] = { 0x7, 0x5 };		/* K=3 */
unsigned int Poly24[] = { 0xf, 0xb };		/* k=4 */
unsigned int Poly25[] = { 0x17, 0x19 };		/* k=5 */
unsigned int Poly25a[] = { 0x13, 0x1b };	/* k=5, used in GSM?  */
unsigned int Poly26[] = { 0x2f, 0x35 };		/* k=6  */
unsigned int Poly27[] = { 0x6d, 0x4f };		/* k=7; NASA and industry  */
unsigned int Poly28[] = { 0x9f, 0xe5 };		/* k=8  */
unsigned int Poly29[] = { 0x1af, 0x11d };	/* k=9; used in IS-95 CDMA  */
unsigned int Poly213[] = {012767,016461};	/* k = 13  */
unsigned int Poly215[] = { 0x45dd, 0x69e3 };	/* k = 15  */

/* Rate 1/3 codes */
unsigned int Poly33[] = { 0x7, 0x7, 0x5 };	/* k = 3 */
unsigned int Poly34[] = { 0xf, 0xb, 0xd };	/* k = 4 */
unsigned int Poly35[] = { 0x1f, 0x1b, 0x15 };	/* k = 5 */
unsigned int Poly36[] = { 0x2f, 0x35, 0x39 };	/* k = 6 */
unsigned int Poly37[] = { 0x4f, 0x57, 0x6d };	/* k = 7; NASA and industry  */
unsigned int Poly38[] = { 0xef, 0x9b, 0xa9 };	/* k = 8  */
unsigned int Poly39[] = { 0x1ed, 0x19b, 0x127 }; /* k = 9; IS-95 CDMA  */
unsigned int Poly311[] = { 02353, 02671, 03175 }; /* k = 11 */
unsigned int Poly312[] = { 04363, 05271, 06755 }; /* k = 12 */
unsigned int Poly313[] = { 010533, 010675, 017661 }; /* k = 13 */
unsigned int Poly314[] = { 021645, 035661, 037133 }; /* k = 14 */

/* Rate 1/4 codes */
unsigned int Poly409[] = {0463,0535,0733,0745};         // k = 9
unsigned int Poly410[] = {01117,01365,01633,01653};     // k = 10
unsigned int Poly411[] = {02337,02353,02671,03175};     // k = 11  Check!!
unsigned int Poly412[] = {04767,05723,06265,07455};     // k = 12
unsigned int Poly413[] = {011145,012477,015537,016727}; // k = 13
unsigned int Poly414[] = {021113,023175,035527,035537}; // k = 14

/*Rate 1/5 codes */
unsigned int Poly508[] = {0257,0233,0323,0271,0357};         // k = 8

/* Rate 1/6 codes */
unsigned int Poly613[] = {010473,011275,012467,013277,014331,016365}; // k=13
unsigned int Poly615[] = {042631,047245,073363,056507,077267,064537}; // k=15

/* Rate 1/8 codes */
unsigned int Poly810[] = {01123,01165,01277,01327,01433,01575,01621,01731};  /* k=10 */
unsigned int Poly813[] = {010473,011275,012467,013277,014331,015221,016365,017623};  /* k=13 */

#include <memory.h>
#define NULL ((void *)0)

/* There ought to be a more general way to do this efficiently ... */
#ifdef __alpha__
#define LONGBITS 64
#define LOGLONGBITS 6
#else
#define LONGBITS 32
#define LOGLONGBITS 5
#endif

#undef max
#define max(x,y) ((x) > (y) ? (x) : (y))
#define D       (1 << max(0,K-LOGLONGBITS-1))
#define MAXNBITS 200            /* Maximum frame size (user bits) */


extern unsigned char Partab[];	/* Parity lookup table */

int Rate = N;

int Syms[1 << K];
int VDInit = 0;

int parity(int x)
{
  x ^= (x >> 16);
  x ^= (x >> 8);
  return Partab[x & 0xff];
}

// Wrapper for calling "encode" from Fortran:
//void __stdcall ENCODE(
//void encode_(
void enc215_(
unsigned char data[],           // User data, 8 bits per byte
int *nbits,                     // Number of user bits
unsigned char symbols[],        // Encoded one-bit symbols, 8 per byte
int *nsymbols,                  // Number of symbols
int *kk,                        // K
int *nn)                        // N
{
  int nbytes;
  nbytes=(*nbits+7)/8;          // Always encode multiple of 8 information bits
  encode215(symbols,data,nbytes,0,0); // Do the encoding
  *nsymbols=(*nbits+K-1)*N;        // Return number of encoded symbols
  *kk=K;
  *nn=N;
}

/* Convolutionally encode data into binary symbols */
  encode215(unsigned char symbols[], unsigned char data[],
       unsigned int nbytes, unsigned int startstate,
       unsigned int endstate)
{
  int i,j,k,n=-1;
  unsigned int encstate = startstate;

  for(k=0; k<nbytes; k++) {
    for(i=7;i>=0;i--){
      encstate = (encstate + encstate) + ((data[k] >> i) & 1);
      for(j=0;j<N;j++) {
	n=n+1;
	symbols[n] = parity(encstate & Polys[j]);
      }
    }
  }
  // Flush out with zero tail.  (No need, if tail-biting code.)
  for(i=0; i<K-1;i++){
    encstate = (encstate << 1) | ((endstate >> i) & 1);
    for(j=0;j<N;j++) {
      n=n+1;
      symbols[n] = parity(encstate & Polys[j]);
      // printf("%d   %d   %d   %d   %d\n",j,n,symbols[n],encstate,Polys[j]);
    }
  }
  return 0;
}

// Wrapper for calling "viterbi" from Fortran:
//void __stdcall VITERBI(
//void viterbi_(
void vit215_(
unsigned char symbols[],  /* Raw deinterleaved input symbols */
unsigned int *Nbits,	  /* Number of decoded information bits */
int mettab[2][256],	  /* Metric table, [sent sym][rx symbol] */
unsigned char ddec[],	  /* Decoded output data */
long *Metric              /* Final path metric (bigger is better) */
){
  long metric;
  viterbi215(&metric,ddec,symbols,*Nbits,mettab,0,0);
  *Metric=metric;
}

/* Viterbi decoder */
int viterbi215(
long *metric,           /* Final path metric (returned value) */
unsigned char *data,	/* Decoded output data */
unsigned char *symbols,	/* Raw deinterleaved input symbols */
unsigned int nbits,	/* Number of output bits */
int mettab[2][256],	/* Metric table, [sent sym][rx symbol] */
unsigned int startstate,         /* Encoder starting state */
unsigned int endstate            /* Encoder ending state */
){
  int bitcnt = -(K-1);
  long m0,m1;
  int i,j,sym;
  int mets[1 << N];
  unsigned long paths[(MAXNBITS+K-1)*D];
  unsigned long *pp,mask;
  long cmetric[1 << (K-1)],nmetric[1 << (K-1)];
  
  memset(paths,0,sizeof(paths));

  // Initialize on first time through:
  if(!VDInit){
    for(i=0;i<(1<<K);i++){
      sym = 0;
      for(j=0;j<N;j++)
	sym = (sym << 1) + parity(i & Polys[j]);
      Syms[i] = sym;
    }
    VDInit++;
  }

  // Keep only lower K-1 bits of specified startstate and endstate
  startstate &= ~((1<<(K-1)) - 1);
  endstate &= ~((1<<(K-1)) - 1);

  /* Initialize starting metrics */
  for(i=0;i< 1<<(K-1);i++)
    cmetric[i] = -999999;
  cmetric[startstate] = 0;

  pp = paths;
  for(;;){ /* For each data bit */
    /* Read input symbols and compute branch metrics */
    for(i=0;i< 1<<N;i++){
      mets[i] = 0;
      for(j=0;j<N;j++){
	mets[i] += mettab[(i >> (N-j-1)) & 1][symbols[j]];
      }
    }
    symbols += N;
    /* Run the add-compare-select operations */
    mask = 1;
    for(i=0;i< 1 << (K-1);i+=2){
      int b1,b2;
      
      b1 = mets[Syms[i]];
      nmetric[i] = m0 = cmetric[i/2] + b1; 
      b2 = mets[Syms[i+1]];
      b1 -= b2;
      m1 = cmetric[(i/2) + (1<<(K-2))] + b2;
      if(m1 > m0){
	nmetric[i] = m1;
	*pp |= mask;
      }
      m0 -= b1;
      nmetric[i+1] = m0;
      m1 += b1;
      if(m1 > m0){
	nmetric[i+1] = m1;
	*pp |= mask << 1;
      }
      mask <<= 2;
      if(mask == 0){
	mask = 1;
	pp++;
      }
    }
    if(mask != 1){
      pp++;
    }
    if(++bitcnt == nbits){
      *metric = nmetric[endstate];
      break;
    }
    memcpy(cmetric,nmetric,sizeof(cmetric));
  }

  /* Chain back from terminal state to produce decoded data */
  if(data == NULL)
    return 0;/* Discard output */
  memset(data,0,(nbits+7)/8); /* round up in case nbits % 8 != 0 */

  for(i=nbits-1;i >= 0;i--){
    pp -= D;
    if(pp[endstate >> LOGLONGBITS] & (1L << (endstate & (LONGBITS-1)))){
      endstate |= (1 << (K-1));
      data[i>>3] |= 0x80 >> (i&7);
    }
    endstate >>= 1;
  }
  return 0;
}
