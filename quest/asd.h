/******************************************************************************
*                                                                             *
*  CodeVector Technologies						      *
*  Copyright (c) 2003                                                         *
*  All rights reserved.                                                       *
*                                                                             *
*   Xre-inf.h:  includes the #defines, typedefs, and forward function         *
*               declarations necessary for the implementation of the          *
*               the soft-decision decoder for RS codes.                       *
*                                                                             *
*                                                                             *
* Written by: Ralf Koetter and Alexander Vardy                                *
*                                                                             *
******************************************************************************/

/******************************************************************************
*                                                                             *
*                                INCLUDES                                     *
*                                                                             *
******************************************************************************/

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <float.h> 
#include <string.h>
#include <sys/types.h>

#ifndef COMMON_INCLUDED
#include "common.h"
#endif

/******************************************************************************
*                                                                             *
*                            SYNONYM DEFINES                                  *
*                                                                             *
******************************************************************************/

#define  LINUX	   1             /* certain time access structures are     */
#define  SOLARIS   0             /* different on Linux and Solaris         */
#define initialize 0             /* modes for the Update_Stat function     */
#define done       1             /*         and the Update_Time function   */

#define  RSK       12            /* Max RS.k */
#define  RSN       63            /* Max RS.n */
#define  MAXMP1    20            /* max_m_plus1 */
#define  MAXYDP2  100            /* Max_Y_degree+2 */

enum {Uncoded,                   /* Synonyms defined to access the error   */
      BW,                        /* array gathering relevant statistics    */  
      SG, 
      GMD,
      Soft_infinity,
      Prediction,
      Lists,
      Factorization,
      Error_size,
      Stat_size};

enum {Start_time,         /* Synonyms defined for various decoding times   */
      Precode_time,
      MultiplyX_time,
      Predict_time,
      ReEncode_time,
      Set_Groebner_time,
      Interpolate_time,
      Factorization_time,
      Total_time,
      Times_size};         

/******************************************************************************
*                                                                             *
*                         FINITE FIELD MACROS                                 *
*                                                                             *
******************************************************************************/

#define  field_size     64    /* size of the finite field = RS.q            */
#define  group_size     63    /* size of the multiplicative group = RS.q-1  */
#define  GF_log0        126   /* to multiply by 0 using same table look-up  */

#define GFexpQ(i)    (GF_antilog[(i)])    /* returns alpha^i in binary form */
#define GFexpN(i)    (GF_antiNeg[(i)])    /* allows negative i < group_size */
#define GFexp(i)     (GF_antilog[ (i % group_size) ]) 
#define GFlog(a)     (GF_log[(a)])         /* returns i so that alpha^i = a */

#define GFadd(a,b)   ((a) ^ (b))                   /* finite field addition */

#define GFmultQ(a,b)      (GF_antilog[ GF_log[(a)] + GF_log[(b)] ])
#define GFmultExp(a,b)    (GF_antilog[ GF_log[(a)] + (b) ])
#define GFmultExp1(a,b)   (GF_antilog[ GF_log[(b)] + (a) ])
#define GFmultExp2(a,b)   (GF_antilog[ (a) + (b) ])

#define GFdivQ(a,b)       (GF_antiNeg[ GF_log[(a)] - GF_log[(b)] ]) 
#define GFsquare(a)       (GF_antilog[ GF_log[(a)] << 1 ])

#define GFsqrtE(b) ((b&1) ? GF_antilog[((b+field_size-1)>>1)]:GF_antilog[b>>1])




/******************************************************************************
*                                                                             *
*                           TYPE  DEFINITIONS                                 *
*                                                                             *
******************************************************************************/

typedef char                 bit;    /* just a bit */
typedef unsigned short int   byte;   /* an element of a Galois field */

typedef int  mType;  /* typical of multiplicity values          */
typedef int  nType;  /* typical of the length of RS code        */
typedef int  pType;  /* typical of quantized probability values */
typedef int  eType;  /* typical of an exponent in Galois field  */
            /*
               NOTE: mType, nType, eType could take negative values,
                     e.g. in the loop for (x = n, x >= 0, x--), etc.
            */

typedef	struct
{
  int     m;        /* 2^m is the alphabet size */
  int     q;        /* alphabet size */
  nType   n;        /* length */
  nType   k;	    /* dimension */
  nType   r;	    /* n - k */

  byte   *zeros;    /* zeros of the RS code */
  byte   *g;        /* generator polynomial */

  byte   *Psi;      /* conversion vector (to the evaluation construction) */
  nType  *Psi_exp;  /* exponents of the conversion vector */

  nType  *Zech;     /* exponents used in re-encoding */

  byte   *gstar;    /* generator polynomial for the full code in eval() */

} RS_CODE;  /* Reed-Solomon code */


typedef struct
{
  byte    Px;          /* the X value */
  byte    Py;          /* the Y value */
  mType    m;          /* multiplicity of the point */
  nType    j;          /* code position corresponding to the point */

} R_POINT;  /* a re-encoding point */


typedef struct
{
  byte    Px;          /* the X value */
  byte    Py;          /* the (first) Y value */
  mType    m;          /* multiplicity of the (first) point */
  nType    j;          /* code position corresponding to the (2) point(s) */

  bit     second;      /* = 1 if there's a second point in same position */
  byte    Py2;         /* the second Y value */
  mType   m2;          /* multiplicity of the second point */

} I_POINT;  /* an interpolation point */


typedef struct
{
  byte  **polynomial;      /* the polynomial itself */
  int   *X_degrees;        /* the X-degrees, parametrized by y */
  int   max_X_degree;      /* max X-degree */
  int   Y_degree;          /* max Y-degree */
  int   weighted_degree;   /* the weighted degree */

} BI_Poly;  /* a generic bivariate polynomial */


typedef byte **D_BI_Poly;  /* discrepancy bivariate polynomial */


typedef struct
{
  byte  **polynomial;   /*!< the polynomial itself */
  int   x_max;          /*!< maximal \f$X\f$ degree we have to consider    */
  int   y_degree;       /*!< maximal \f$Y\f$ degree we have to consider    */
  int   x_start;        /*!< position at which we start investigating      */
  int   y_slope;        /*!< how often we substituted \f$Y\leftarrow XY\f$ */
  int   mult;           /*!< current degree of q(Y) used for finding roots */
  byte  *S;             /*!< syndrome sequence --- result of factorization */
  int   d;              /*!< degree up to which the problem is solved      */

} BI_factor_Poly_struct;   /* a bivariate polynomial used in factorization */





/******************************************************************************
*                                                                             *
*                           GLOBAL VARIABLES                                  *
*                                                                             *
******************************************************************************/

FILE	*data;	           /* file containing the simulation data */
FILE    *matlab;           /* simulation stats in matlab format */



   /* Field global variables */

byte   *primitive_polynomial;  /* defines the finite field of char 2 */

nType  *GF_log;           /* Log table of the field */
byte   *GF_antilog;       /* Antilog table of the field */
byte   *GF_antiNeg;       /* Antilog pointer, with negative subscripts */
nType  *Zech_Table;       /* Zech-log table of the field */
nType  *Zech;             /* Zech-log pointer, with negative subscripts */



   /* Code parameters */

RS_CODE RS;       /* parameters of the RS code */



  /* Simulation parameters and constants */

int 	info_length = 72;  	/* number of information bits in a frame */
int     no_SNRpoints;           /* total number of SNR points */
float  *SNRpoints;              /* array of SNR points */
long    seed;                   /* random seed taken from timing */
long 	simulation_time;        /* maximum number of frames processed
               				                 for each SNR point */
int     max_errors;             /* max number of erorrs processed
               				                 for each SNR point */
int 	peek = 100;	        /* number of frames processed between each
                                                         successive display */
int 	file_peek = 1000000;	/* number of frames processed between each
                                    successive print of results into a file */

  /* Global simulation variables */
long int  no_frames;            /* counter in the main simulation loop */

  /* Decoder parameters */
int  quantization_bits = 8;    /* number of bits in quantizing reliabilities */
int  quantization_M = 256;     /* auxiliary, equal to 2^(quantization_bits)  */
float  lambda;                 /* multiplier factor; CAN BE AT MOST 17       */
mType  max_m;                  /* maximum possible multiplicity (= lambda-1) */
mType  max_m_plus1;            /* auxiliary, max possible multiplicity + 1   */
mType  max_m_minus1;           /* auxiliary, max possible multiplicity - 1   */
float  prediction_threshold;   /* threshold used in the Predict() function   */
int    Max_N_Errors;           /* max number of erorrs in ReEncode positions */
int    Max_N_Syndromes;        /* auxiliary = 2*Max_N_Errors + 1             */
int    Additional_Syndromes;   /* # of syndromes in false root elimination   */
 
  /* Decoder variables */
int  *Delta;                  /* table of the Delta[cost] function */
mType *FloorMult;             /* table of the FloorMultiplication function */
int    max_cost;              /* maximum cost for Delta[cost] inversion */
byte  *MR_symbols;            /* most reliable symbols in a frame */
byte  *MR2_symbols;           /* second most reliable symbols in a frame */
pType *MR_probabilities;      /* probabilities of most reliable symbols */
pType *MR2_probabilities;     /* probabilities of 2-nd most reliable symbols */
byte  *source_codeword;       /* transmitted codeword of the cyclic RS code  */
byte  *pre_codeword;          /* pre-coded codeword                       */
byte  *shift_codeword;        /* codeword in C_ev code, by which we shift */
R_POINT *ReEncode_List;       /* list of points to re-encode through   */
I_POINT *Interpolate_List;    /* list of points to interpolate through */
nType *Interpolate_Positions; /* list of positions on Interpolate_List */
nType *Erasure_Positions;     /* list of erased positions */
nType *ReEncode_Positions;    /* list of positions on actual re-encode list */
nType *ReEncode_Values;       /* list of actual (adjusted) re-encode values */
nType N_ReEncodes;            /* number of actual re-encoding positions  */
nType N_Erasures;             /* number of erasures                      */
nType N_Interpolates;         /* number of positions on Interpolate_List */
int   I_cost;                 /* total cost of points on Interpolate_List */
mType m_threshold;            /* multiplicty threshold for ReEncode_List  */
BI_Poly **Groebner;           /* Groebner basis for interpolation           */ 
mType   Max_Y_degree;         /* max possible Y-degree in Groebner basis    */
int     Max_X_degree;         /* max possible X-degree in Groebner basis    */
mType   max_Y_degree;         /* max Y-degree in the current Groebner basis */
int     max_X_degree;         /* max X-degree in the current Groebner basis */
int     max_weighted_degree;  /* max weighted-degree in current Groebner    */
mType  *Sorter;               /* used to sort Groebners by weighted-degree  */
int    *weighted_degrees;     /* updated weighted-degrees of Groebners      */
D_BI_Poly *Discrepancy;       /* Discrepancy poly's in fast interpolation   */ 
D_BI_Poly *Discrepancy2;      /* Discrepancy poly's for (Px,Py2) point      */ 
byte *Error_Positions;        /* holds the error positions as field elements */
byte *Error_Values;           /* holds the corresponding error values        */
byte *error_codeword;         /* codeword that agrees with Error_Values      */
byte *decoded_codeword;       /* the final result of the soft-decoding!      */

  /* Statitstics gathering */

bit    Error[Error_size];        /* holds the error flags per frame */
unsigned int Stat[Stat_size];    /* holds the overall error statistics */
double Avg_Times[Times_size+1];  /* average decoding time per sector */
double Max_Times[Times_size+1];  /* maximum decoding time per sector */

  /* Execution time variables */

time_t starting_time[1];
struct tm start_time[1];
// struct timespec program_clock[Times_size];
// struct timespec decode_clock[2];

  /* Ralf's factorization variables */

int *lm_a;                       /* used in Find_Roots()*/
int *lm_b;                       /* used in Find_Roots()*/
unsigned int *solve_quad_poly_a; /* used in Find_Roots()*/
unsigned int *solve_quad_poly_b; /* used in Find_Roots()*/
BI_factor_Poly_struct **BI_factor_Polynomials;
byte *Factor_polynomial;
byte *error_locator;
byte *error_evaluator;
byte *Derivative_of_locator;
byte *roots_of_factor_polynomial;
byte *mults_of_factor_polynomial;


/******************************************************************************
*                                                                             *
*                       Forward Function Declarations                         *
*                                                                             *
******************************************************************************/

	/* Initialization functions */

void	Start_up(void);
void	Get_Parameters(void);
void	Initialize(void);
void    Initialize_Stats(void);
int     *Initialize_Delta(int);
mType   *Initialize_FloorMult(void);

	/* Finite field and RS functions */
void  Initialize_RS(void);
void  Remainder_Poly(byte *, byte *, int, int);
byte  Evaluate_Poly(byte *, int, byte);     

	/* Encoder and channel functions */
void  Source(bit *, int);
void  RS_Encode(bit *);
void  Modulate(double *);
void  AWGN_Channel(double *, double *, double, int);  
void  Demodulate_2(double *, double);     

	/*---- Actual decoder functions ----*/
void  Precode(void);
void  MultiplyX(void);
float  Predict(void);
void  ReEncode(void);
void  Set_Groebner(void);
void  Multiply_Poly(byte *, byte *, int, int);
void  Interpolate(void);
       void  FST_Update_Groebner(BI_Poly **, I_POINT *);
       void  ReSort_Groebner(BI_Poly **);
int   Factor(void);

   /* Ralf's functions relating to factorization */
void Init_Factorization(int);
void Shift_BI_factor_Poly(byte, BI_factor_Poly_struct *);
void Copy_Factorization_Problem(BI_factor_Poly_struct *,
                                           BI_factor_Poly_struct *, int);
void Create_Factorization_Problem_from_BI_Poly(BI_Poly *, 
                             BI_factor_Poly_struct *, int, int, int, byte);
int Find_Roots(byte *, int, byte *, byte *);
int Find_Roots_for_error_locator (byte *, int, byte *, byte *);
int Factor_BI_Poly(BI_Poly *, byte *, byte *);
int BMA (byte *, byte *, byte *, int);

	/* Statistics gathering functions */
void  SoftRS_SFR(void);
void  GMD_BW_SFR(void);
int   Position_Compare(nType *, nType *);
void  Update_Stats(int);
void  Update_Time(long);

	/* Finite field auxiliary functions */
byte *Primitive_Polynomial(int);                         
void Generate_GF(byte *, int); 
byte GFmult(byte a, byte b);
byte GFdiv(byte a, byte b);

	/* Allocation functions */
double  *Alloc_Double_Vector(long);
float   *Alloc_Float_Vector(long);
int     *Alloc_Int_Vector(long);
bit     *Alloc_Bit_Vector(long);
byte    *Alloc_Byte_Vector(long);
eType   *Alloc_eType_Vector(long);
mType   *Alloc_mType_Vector(long);
nType   *Alloc_nType_Vector(long);
pType   *Alloc_pType_Vector(long);
bit     **Alloc_Bit_Matrix(long, long);
byte    **Alloc_Byte_Matrix(long, long);
nType   **Alloc_nType_Matrix (long, long);
BI_Poly *Allocate_BI_Poly(int, int);

 /* Ralf's memory management functions */
BI_factor_Poly_struct **Allocate_BI_factor_Poly_array (int, int);
void Free_BI_factor_Poly_array (BI_factor_Poly_struct **P, int Y_degree);

	/* Random functions */
double  Uniform_RV(long *);
double  Gauss_RV(long *, double);

	/* Utility functions */
void	Write_Header(FILE *);
void    Write_Matlab_Header(FILE *);
void    Pretty_Print(FILE *, double, int);
void    Matlab_Print(FILE *, int);
void    Write_Matlab_Tailer(FILE *);
void    Print_Time(FILE *, time_t);
void    Read_line(char *, FILE *);
void    Exit(char *);
