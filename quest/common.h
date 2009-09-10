/**************************************************************************
*                                                                         *
*  Alexander Vardy							  *
*  Copyright (c) 2001                                                     *
*  All rights reserved.                                                   *
*                                                                         *
*                                                                         *
*     COMMON.H: a common header including some frequently used            *
*		defines.                                                  *
*                                                                         *
*                                                                         *
* Written by: Alexander Vardy                                             *
*                                                                         *
*                                                                         *
***************************************************************************/

#ifndef COMMON_INCLUDED
#define COMMON_INCLUDED


/* some handy constants */

#define FALSE           0
#define TRUE            1

#define OFF             0
#define ON              1

#ifndef NULL
#define NULL 		0x0L
#endif

#define BIGFLOAT        1.7E38
#define BIGINT          2147483647 

#ifndef RAND_MAX
#define RAND_MAX	2147483647 
#endif

#define PI              3.14159265358979324
#define ROOT2           1.41421356237309504880
#define ROOT2DIV2       0.70710678118654752440

#define DEGTORAD        (PI / 180.0)
#define RADTODEG        (180.0 / PI)


/* some handy macros */

#define ABS(x)          (((x) > 0.0) ? (x) : (-(x)))
#define AVG(x,y)        (((x) + (y)) / 2.0)
#define BYTES(a)        ((a + 7) / 8)
#define CEIL(x)         (((x)==(double)((int)(x)))?((int)(x)):((int)((x)+1)))
#define CONCAT(x,y)     (x/**/y)
#define FLOOR(x)        ((double)((int)(x)))
#define MIN(x,y)        (((x) < (y)) ? (x) : (y))
#define MAX(x,y)        (((x) > (y)) ? (x) : (y))
#define NEG(x)          ((x) < 0.0)
#define POS(x)          ((x) > 0.0)
#define POW2(p)         (1 << (p))
#define ROUND(x)        (((x)>0.0)?((int)((x)+0.5)):((int)((x)-0.5)))
#define SIGN(x)         (((x)>0.0) - ((x)<0.0))
#define SQUARE(x)       ((x) * (x))
#define TRUNC(x)        ((double)((int)(x)))
#define SWAP(a,b)       (a) ^= (b) ^= (a) ^= (b);
#define SWAPB(a)        ( (((a) << 8) & 0x0FF00) | (((a) >> 8) & 0x00FF) )
#define MINUS_1_TO(i)   ( ( (i) % 2 == 0 ) ? +1.0 : -1.0 )



/* Random generator macros  */

#define MxRand          ((double) RAND_MAX)

#define UNIXRand        ( ( (double) lrand48() ) / MxRand ) 
#define StandardRand    (  ( (double) ((int) rand()) ) / MxRand  ) 
#define UNIXSrand       ( srand48( (int) time( (long *) 0 ) ) )
#define StandardSrand   ( srand  ( (int) time( (long *) 0 ) ) )    

#define NormRand()      ( ( UNIX == 1 ) ? StandardRand : UNIXRand )
#define InitRand()      ( ( UNIX == 0 ) ? StandardSrand : UNIXSrand )
                                     
#define Random(min,max) ((((max)-(min)) * (NormRand ())) + (min))



/* some handy synonyms */

#define export  extern
#define global  extern
#define hidden  static
#define local   static



/* BitAccess macros */

#define BITON      |=           /* set bit on, regardless of current value */
#define BITOFF     &=~          /* set bit off, regardless of current value */
#define BITTOGGLE  ^=           /* toggle bit value */
#define BITQUERY   &            /* test bit value */
#define MakeMask(i)             (((i) == 0) ? 1 : (1 << (i)))
#define BitAccess(bf,op,mask)   ((bf) op (mask))



#endif /* COMMON_INCLUDED */

