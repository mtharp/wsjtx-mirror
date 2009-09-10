/**************************************************************************
*                                                                         *
*  CodeVector Technologies                                                *
*  Copyright (c) 2003                                                     *
*  All rights reserved.                                                   *
*                                                                         *
*   Xre-inf.c: includes the main() and auxiliary functions necessary      *
*              for the implementation of the soft-decision decoder for    *
*              RS codes based on the Koetter-Vardy algorithm.             *
*                                                                         *
*              Xre-inf == multiply -> re-encode -> interpolate -> factor  *
*                                                                         *
*                                                                         *
* Written by: Ralf Koetter and Alexander Vardy                            *
*             CodeVector Technologies LLC                                 *
*                                                                         *
***************************************************************************/

#include "asd.h"

/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*                                                                         *
*                               asdinit                                   *
*                                                                         *
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/

//extern void __stdcall ASDINIT (int *mm, int *qq, int *nn, int *kk, int *z1, 
//	       float *xlambda, int *MaxErr, int *AddSynd, int *qbits)
extern void asdinit_(int *mm, int *qq, int *nn, int *kk, int *z1, 
	       float *xlambda, int *MaxErr, int *AddSynd, int *qbits)
{
  int i,j;              /* auxiliary integers */
  static int first=1;
  static float lambda0;
  static int Max_N_Errors0;
  static int Additional_Syndromes0;

/*---------------------------INITIALIZE----------------------------------*/
  if(first==0) {
    if((*xlambda > lambda0) ||
       (*MaxErr > Max_N_Errors0) ||
       (*AddSynd > Additional_Syndromes0)) {
      printf("Error re-initializing KV-ASD decoder.\n");
      exit(1);
    }
  }

  RS.m = *mm;
  RS.q = *qq;
  RS.n = *nn;
  RS.k = *kk;
  RS.r = RS.n - RS.k;
  quantization_bits = *qbits;
  quantization_M = 1 << quantization_bits;
  lambda=*xlambda;
  max_m = (mType) floor((lambda*(quantization_M-0.5))/(1.0*quantization_M));
  max_m_plus1 = max_m + 1;
  max_m_minus1 = max_m - 1;
  max_cost = RS.n * (max_m * max_m_plus1)/2 + 10;
  Max_N_Errors=*MaxErr;
  Additional_Syndromes=*AddSynd;
  Max_N_Syndromes = 2*Max_N_Errors + 1;

  if(first) {
    lambda0=lambda;
    Max_N_Errors0=    Max_N_Errors;
    Additional_Syndromes0=Additional_Syndromes;
    first=0;
  }


  RS.zeros = Alloc_Byte_Vector(RS.r);
  RS.g = Alloc_Byte_Vector(RS.r+1);
  RS.Psi = Alloc_Byte_Vector(RS.n);
  RS.Psi_exp = Alloc_nType_Vector(RS.n);
  RS.Zech = Alloc_nType_Vector(RS.n);
  RS.gstar = Alloc_Byte_Vector(RS.q-RS.k);
  for (i = 0; i < RS.r; i++)  {
    RS.zeros[i]=i+(*z1);
  }

  /* Initialize finite field, RS, Delta, etc. */
  primitive_polynomial = Primitive_Polynomial(RS.m);
  Generate_GF(primitive_polynomial,RS.m);
  free(primitive_polynomial);
  Initialize_RS();
  Delta = Initialize_Delta(max_cost);
  FloorMult = Initialize_FloorMult();

/*---------------- Compute some important parameters  -------------------*/
  info_length = RS.m*RS.k;

/*------------------------- ALLOCATE MEMORY -----------------------------*/
  /* Allocate encoder, channel, and decoder frames */
  source_codeword = Alloc_Byte_Vector(RS.n);
  MR_symbols = Alloc_Byte_Vector(RS.n);
  MR2_symbols = Alloc_Byte_Vector(RS.n);
  MR_probabilities = Alloc_pType_Vector(RS.n);
  MR2_probabilities = Alloc_pType_Vector(RS.n);
  pre_codeword = Alloc_Byte_Vector(RS.n);
  shift_codeword = Alloc_Byte_Vector(RS.n);

  /* Allocate the ReEncode and Interpolate lists */
  if ((ReEncode_List = (R_POINT *) malloc(RS.n*sizeof(R_POINT))) == NULL)
    Exit("Unable to allocate the Re-Encode List!");
  if ((Interpolate_List = (I_POINT *) malloc(2*RS.r*sizeof(I_POINT))) == NULL)
    Exit("Unable to allocate the Interpolate List!");
  Interpolate_Positions = Alloc_nType_Vector(RS.r);
  Erasure_Positions = Alloc_nType_Vector(RS.r);
  ReEncode_Positions = Alloc_nType_Vector(RS.r);
  ReEncode_Values = Alloc_nType_Vector(RS.r);

  /* Allocate the Groebner basis and related auxiliaries */
  Max_Y_degree = Delta[max_cost-1]/(RS.k-1);  
  Max_X_degree = (Max_Y_degree - max_m + 1)*(RS.k-1) + 10; 
     /* 
        This bound is based on the high-SNR approximation, which assumes 
        multiplicity of (lambda-1) at all the RS.r interpolation positions
        and no tail polynomials up to degree RS.k. At lower SNR, the multi-
        plicities of interpolation positions will decrease and there will
        appear tail polynomials. However, the former effect is stronger
        than the latter, so the bound remains correct.

        Finally, the extra 10 is a temporary safety margin, to account
        for possible dependent constraints. This margin can be eliminated
        if more elaborate book-keeping is used in Interpolate().
     */

  if ((Groebner = (BI_Poly **)malloc((Max_Y_degree+1) * 
				     sizeof(BI_Poly *)))==NULL)
    Exit("Unable to allocate the Groebner basis!");
  for (i = 0; i <= Max_Y_degree; i++)
    Groebner[i] = Allocate_BI_Poly(Max_X_degree,Max_Y_degree);

  weighted_degrees = Alloc_Int_Vector(Max_Y_degree+2); 
  Sorter = Alloc_mType_Vector(Max_Y_degree+2); 
  //   The +2 above is a safety margin; what we really need is Max_Y_degree+1.

  /* Allocate the Discrepancy polynomials */

  if ((Discrepancy = 
       (D_BI_Poly *) malloc( (Max_Y_degree+1)*sizeof(D_BI_Poly *)) ) == NULL)
    Exit("Unable to allocate the discrepancy polynomials!");

  for (i = 0; i <= Max_Y_degree; i++)  {
      if ( (Discrepancy[i] = (byte **) malloc(max_m*sizeof(byte *)) ) == NULL)
	Exit("Unable to allocate a discrepancy polynomial!");

      for (j = 0; j < max_m; j++)
	if ( (Discrepancy[i][j] =
	      (byte *) malloc((Max_Y_degree+1)*sizeof(byte)) ) == NULL)
	  Exit("Unable to allocate a discrepancy polynomial!");
  }

  if ((Discrepancy2 = 
       (D_BI_Poly *) malloc( (Max_Y_degree+1)*sizeof(D_BI_Poly *)) ) == NULL)
    Exit("Unable to allocate the discrepancy polynomials!");

  for (i = 0; i <= Max_Y_degree; i++)  {
    if ( (Discrepancy2[i] = (byte **)malloc((max_m/2)*sizeof(byte *)) ) == NULL)
      Exit("Unable to allocate a discrepancy polynomial!");

    for (j = 0; j < (max_m/2); j++)
      if ( (Discrepancy2[i][j] =
	    (byte *) malloc((Max_Y_degree+1)*sizeof(byte)) ) == NULL)
	Exit("Unable to allocate a discrepancy polynomial!");
  }

  /* Allocate the factorization variables */
  error_codeword = Alloc_Byte_Vector(RS.n);
  decoded_codeword = Alloc_Byte_Vector(RS.n);
  Init_Factorization(RS.m);
}

/**************************************************************************
*                                rsasd()                                  *
**************************************************************************/
//extern void __stdcall RSASD(int *mrs, int *mrp, int *mr2s, int *mr2p, int *nerr0, 
//	   int *NErrors0, char *decoded)
extern void rsasd_(int *mrs, int *mrp, int *mr2s, int *mr2p, int *nerr0, 
	   int *NErrors0, char *decoded)
{
  int i;
  int nerr;
  int N_Errors;

  for(i=0; i<RS.n; i++) {
    MR_symbols[i]=mrs[i];
    MR_probabilities[i]=mrp[i];
    MR2_symbols[i]=mr2s[i];
    MR2_probabilities[i]=mr2p[i];
  }

  N_Errors=RSdecode();

  nerr=0;
  for(i=0; i<RS.n; i++) {
    if(decoded_codeword[i] != source_codeword[i]) {
      nerr=1;
      break;
    }
  }

  /*  Copy decoded message back into Fortran array */
  for (i=0; i<RS.k; i++)
    decoded[i]=decoded_codeword[RS.n-RS.k+i];

  *NErrors0=N_Errors;
  *nerr0=nerr;
}


/**************************************************************************
*                             RSdecode                                   *
**************************************************************************/
int RSdecode()
{
  int N_Errors;
  float x;
  /*  Do the algebraic Soft-Decision Reed-Solomon decoding.  The
      important input data are in arrays MR_symbols[],  
      MR_probabilities[], MR2_symbols[], and MR2_probabilities[]
      Output is in the array decoded_codeword[].
  */
  Precode();
  MultiplyX();
  ReEncode();
  Set_Groebner();  
  Interpolate(); 
  N_Errors=Factor();
  return(N_Errors);
}

/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*                                                                         *
*                         ENCODER FUNCTIONS                               *
*                                                                         *
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/

/**************************************************************************
*                                                                         *
*                 Function RS_Encode (bit frame[])                        *
*                                                                         *
***************************************************************************
*                                                                         *
*    This function implements Reed-Solomon encoding via division by the   *
* generator polynomial. First bit of the input bit frame is taken as MSB. *
*                                                                         *
**************************************************************************/
//extern void __stdcall RSENCODE(bit *frame0, byte *symb)
extern void rsencode_(bit *frame0, byte *symb)
{
  int j,k;
  byte symbol;
  static bit first = 1;
  static byte *_remainder;   /* remainder polynomial 
				used to compute RS codeword */
  bit frame[31];

  /* Allocate static storage */
  if (first)
    {
      _remainder = Alloc_Byte_Vector(RS.n);
      first = 0;
    }

  /* Compute the first k bytes (MSB) of codeword from bit frame.  Note
     that in KV code, the user's symbols are inserted at the end in 
     reverse order. 
  */

  /* For compatibility with M-Z Reed Solomon code, however, we reverse
     the order of user characters before encoding them. */

  for(j=0; j<RS.k; j++)
    frame[j]=frame0[RS.k-1-j];

  for (j = RS.n-1; j >= RS.r; j--)
    {
      symbol = frame[RS.n-1-j];
      source_codeword[j] = symbol;      /* the first symbol in a frame  */
      _remainder[j] = symbol;           /* is the most significant byte */
    }

  /* Now compute the remainder and update codeword */
  for (j = 0; j < RS.r; j++) _remainder[j] = 0;
  Remainder_Poly(_remainder,RS.g,RS.n-1,RS.r);

  for (j = RS.r - 1; j >= 0; j--) 
    source_codeword[j] = _remainder[j];

  /* Copy encoded data into the Fortran array */
  for (j=0; j<RS.n; j++)
     symb[j]=source_codeword[j];
}

#include "asd2.c"
#include "asd3.c"
