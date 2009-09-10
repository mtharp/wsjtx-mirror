/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*                                                                         *
*         INITIALIZATION, RS, AND UNIVARIATE POLYNOMIAL FUNCTIONS         *
*                                                                         *
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/


/**************************************************************************
*                                                                         *
*                 Function Initialize RS (RS_CODE RS)                     *
*                                                                         *
***************************************************************************
*                                                                         *
*    This function computes the generator polynomial of a Reed-Solomon    *
*  code from its set of zeros.                                            *
*                                                                         *
**************************************************************************/

void Initialize_RS( void )
{
  int i, j;        /* auxiliary integers */
  int degree;
  int  s;          /* zero-shift X^s in the phi conversion polynomial */
  byte *phi;       /* the phi conversion polynomial */

 /* ------------Compute the generator polynomial----------- */
   /* Initialize to g(x) = 1 */

  degree = 0;
  RS.g[0] = 1;
  for (i = 1; i <= RS.r; i++) RS.g[i] = 0;
  /* the last line is not really needed, but just in case ... */

  /* Iteratively multiply by linear terms
     corresponding to the code zeros */

  for (i = 0; i < RS.r; i++)
    {
      degree++;
      RS.g[degree] = RS.g[degree-1];

      for (j = degree-1; j > 0; j--)
	RS.g[j] = GFadd( GFmult( RS.g[j], GFexp(RS.zeros[i]) ), RS.g[j-1] );

      RS.g[0] = GFmult( RS.g[0], GFexp(RS.zeros[i]) );
    } 

 /* ----------Compute the phi auxiliary polynomial--------- */
  /*
        The phi auxiliary polynomail is given by:
        $$
          \phi(X) = X^s \prod_{i = RS.n}^{RS.q-2} (X - \alpha^i)
        $$
        where $\alpha$ is the primitive element of the field 
        and $s = 1 - b$ modulo $RS.q$, with $\alpha^b$ being 
        the first in the string of the consecutive zeros that
        define the RS code. This polynomial is used to convert 
        from systematic ( X^{n-k}u(X) - r(X) ) encoding of the 
        shortened RS code to encoding via polynomial evaluation
        assumed in the soft-decision decoding algorithm.
     */

   /* Compute s */

  if (RS.zeros[0] <= 1) s = 1 - RS.zeros[0];
  else s = RS.q - RS.zeros[0];
  /* assuming b = RS.zeros[0] is in the range 0,1,...,RS.q-2 */

  /* Set phi(X) = X^s */

  phi = Alloc_Byte_Vector(s + RS.q - RS.n);
  for (i = 0; i < s; i++) phi[i] = 0;
  phi[s] = 1;
  degree = s;

  /* Iteratively multiply by linear terms
     corresponding to zeros of phi(X) */

  for (i = RS.n; i <= RS.q - 2; i++)
    {
      degree++;
      phi[degree] = phi[degree-1];
      
      for (j = degree-1; j > 0; j--)
	phi[j] = GFadd( GFmult(phi[j],GFexp(i)), phi[j-1] );
      
      phi[0] = GFmult( phi[0], GFexp(i) );
    } 

  /* ----------Compute the Psi conversion vector------------ */

  /*
    The conversion vector is used to decide on the points
    enforced during the interpolation. It is essentially
    an evaluation of $\phi(X)$.
  */
   
  for (i = 0; i < RS.n; i++)
    {
      RS.Psi[i] = Evaluate_Poly(phi,degree,GFexp(i));
      RS.Psi[i] = GFdiv(1,RS.Psi[i]);
      RS.Psi_exp[i] = GF_log[RS.Psi[i]];
    }

 /* ----------Compute the overall Zech exponents----------- */
     /*
        The following loop computes RS.Zech[i] which is equal
        to the exponent of the following product:
        $$
           \prod{j = 0 \atop j \ne i}^{RS.n-1} (1 + \alpha^{j-i})
        $$
        for $i = 0,1,\ldots,RS.n$. These exponents are then 
        normalized modulo (field_size - 1). They are useful 
        in the re-encoding computation.
     */
     
  for (i = 0; i < RS.n; i++)
    {
      RS.Zech[i] = 0;
      for (j = 0; j < i; j++)
	{
	  RS.Zech[i] += Zech[j-i];
	  if (RS.Zech[i] >= group_size) 
	    RS.Zech[i] -= group_size;
	}

      j++;  /* this skips over j = i */

      for ( ; j < RS.n; j++)
	{
	  RS.Zech[i] += Zech[j-i];
	  if (RS.Zech[i] >= group_size) 
	    RS.Zech[i] -= group_size;
	}
    }

  /* ----------Compute the gstar generator polynomial------- */

     /*
        The polynomial gstar is given by:
        $$
          g^*(X) = \prod_{i = 1}^{RS.q-1-RS.k} (X - \alpha^i)
        $$
        where $\alpha$ is the primitive element of the field.
        It can be shown that this is the generator polynomial 
        for the full evaluation code:
        $$
          \C^* = \{ (f(\al^0),\ldots,f(\al^{q-2})) : 
                                          \deg f(X) < RS.k \}
        $$
        It is used in determining the polynomial f(X) from the 
        given codeword in the soft-decision decoding algorithm.
     */

  /* Initialize gstar(X) = 1 */
  degree = 0;
  RS.gstar[0] = 1;
  for (i = 1; i <= RS.q-RS.k-1; i++) RS.gstar[i] = 0;
   /* the last line is not really needed, but just in case */

   /* Iteratively multiply by linear terms
      corresponding to zeros of g*(X) */

  for (i = 1; i <= RS.q - RS.k - 1; i++)
    {
      degree++;
      RS.gstar[degree] = RS.gstar[degree-1];

      for (j = degree-1; j > 0; j--)
	RS.gstar[j] = GFadd( GFmult(RS.gstar[j],GFexp(i)), RS.gstar[j-1] );

      RS.gstar[0] = GFmult( RS.gstar[0], GFexp(i) );
    } 

} /* end Initialize_RS */


/**************************************************************************
*                                                                         *
*              Function Initialize Delta(int max_cost)                    *
*                                                                         *
***************************************************************************
*                                                                         *
*   This function computes the (inverse) weighted-degree table as         *
* a function of cost. A brute-force approach is used. The table is        *
* allocated and returned.                                                 *
*                                                                         *
**************************************************************************/

int *Initialize_Delta(int max_cost)
{

  int *N;          /* holds the table that counts the number of monomials */
  int *table;      /* holds the Delta[cost] table */
  int max_delta;   /* an estimate for the maximum value of delta */
  int delta;
  int cost;
  int k;           /* holds RS.k - 1 */
  int first_sum;   /* auxiliary variables */
  int aux;         /* auxiliary variables */

  /* Construct the N = # of monomials table */
  max_delta = (int) sqrt(2.0*RS.n*max_cost);
  N = Alloc_Int_Vector(max_delta);

  k = RS.k - 1;
  for (delta = 0; delta < max_delta; delta++)
    {
      first_sum = delta/k;
      aux = k*first_sum;
      first_sum++;
      N[delta] = (delta+1)*first_sum - (aux*first_sum)/2;
    }

  /* Construct the Delta table */
  table = Alloc_Int_Vector(max_cost);
  for (cost = 0; cost < max_cost; cost++)
    {
      for (delta = 0; N[delta] <= cost; delta++)
	if (delta == max_delta-1) Exit("Problems generating the Delta table!");

      table[cost] = delta;
    }

  free(N);
  return table;
} /* end Initialize_Delta */


/**************************************************************************
*                                                                         *
*                 Function Initialize_FloorMult ()                        *
*                                                                         *
***************************************************************************
*                                                                         *
*   This function computes the floor of lambda*quantized realiability for *
* the values of lambda given in A_threshold, and stores this in a table.  *
* The table is allocated and returned.                                    *
*                                                                         *
**************************************************************************/

mType *Initialize_FloorMult(void)
{
  mType *table;    /* holds the FloorMultiplication table */
  int pi;          /* runs over the possible quantized values */

  table = Alloc_mType_Vector(quantization_M);
  table[0] = 0;
  for (pi = 1; pi < quantization_M; pi++) 
    table[pi] = (mType) floor( (lambda*(pi+0.5)) / (1.0*quantization_M) );

  return table;
} /* end Initialize_FloorMult */


/**************************************************************************
*                                                                         *
*        Function Remainder_Poly(bit *f, bit *g, int n, int k)            *
*                                                                         *
***************************************************************************
*                                                                         *
*    This function performs polynomial division over a finite field. It   *
*  takes as input a polynomial f(X) of degree n and a polynomial g(X) of  *
*  degree k \leq n. The function computes the remainder polynomial r(X)   *
*  such that f(X) = q(X)g(X) + r(X), where the degree of r(X) is less     *
*  than the degree of g(X).  All polynomials are assumed to be already    *
*  allocated, and the remainder is returned in place of f(X).             *
*                                                                         *
**************************************************************************/

void Remainder_Poly(byte *f, byte *g, int n, int k)
{
  int i, j;
  byte q;       /* the running quotient coeeficient */
  int  r;       /* stands for n-k */
  int  offset;  /* stands for r-i */

   /* Check the degrees and initialize */
  if (k > n) Exit("Asked to compute polynomial remainder with wrong degrees!");
  r = n-k;

  /* Long division loop */
  for (i = 0; i <= r; i++) 
    {
      q = GFdiv(f[n-i],g[k]);  /* compute the quotient coefficient */
      f[n-i] = 0;
       /* Update the dividend polynomial */
      offset = r - i;
      for (j = 0; j < k; j++) 
	f[j+offset] ^= GFmult(q,g[j]);
    }
} /* end Remainder_Poly */


/**************************************************************************
*                                                                         *
*        Function Evaluate_Poly(byte *f, int n, byte beta)                *
*                                                                         *
***************************************************************************
*                                                                         *
*  This function evaluates a univariate polynomial at a field element.    * 
* Horner's rule has been used throughout. The degree of the polynomial    *
* is assumed to be at least 1.                                            *
*                                                                         *
**************************************************************************/

byte Evaluate_Poly(byte *f, int n, byte beta)
{
  register int x;
  register byte result;
  int exp_beta;

  /* Check a simple condition */
  if (beta == 0) return f[0];  
  /* otherwise, there is a problem inlining GFmult */

  /* Initialize */
  exp_beta = GF_log[beta];

  /* Compute the result using Horner's rule */
  result = f[n];
  for (x = n-1; x >= 0; x--) 
    {
      if (result != 0) 
	result = GF_antilog[ (GF_log[result] + exp_beta) % group_size ];
      result ^= f[x];
    }  
  return result;

} /* end Evaluate_Poly */


/******************************************************************************
*                                                                             *
*           Function Multiply_Poly(byte *f, byte *g, int n, int k)            *
*                                                                             *
*******************************************************************************
*                                                                             *
*    This function performs univariate polynomial multiplication using        *
* a simple convolution method. It takes as input a polynomial f(X) of degree  *
* f_degree and a polynomial g(X) of degree g_degree. The function then        *
* computes the product f(X)*g(X). All polynomials are assumed to be already   *
* already allocated, and the product is returned in place of f(X).            *
*                                                                             *
******************************************************************************/
void Multiply_Poly(byte *f, byte *g, int f_degree, int g_degree)
{
  eType  *b;         /* holds exponents of the original values of g(X) */
  eType  *h;         /* holds exponents of the original values of f(X) */
  eType  *h_aux;     /* auxiliary pointer to h(X) */
  byte   *aux;       /* auxiliary pointer to f(X) */
  int x;             /* runs over the coefficients of f(X) */
  int j;             /* runs over the convolution sum */
  int upper_limit;   /* upper limit in the convolution sum */

    /*--- Copy exponents of f(X) into h(X) ---*/
  h = Alloc_eType_Vector(f_degree+1);
  x = f_degree+1;
  do{
    x--;
    h[x] = GF_log[f[x]];
  } while (x);

  /*--- Copy exponents of g(X) into b(X) ---*/
  b = Alloc_eType_Vector(g_degree+1);
  x = g_degree+1;
  do{
    x--;
    b[x] = GF_log[g[x]];
  } while (x);

  /*--------- Multiply g(X) by h(X) --------*/
  x = f_degree + g_degree;
  f[x] = GF_antilog[b[g_degree] + h[f_degree]]; 
  if(x)
    for (x--; x; x--) 
      {
	aux = &f[x];
	h_aux = &h[x];
	*aux = 0;
	upper_limit = MIN(x,g_degree);
	for (j = MAX(0,x-f_degree); j <= upper_limit; j++) 
	  *aux ^= GF_antilog[b[j] + h_aux[-j]];
      }
  f[0] = GF_antilog[b[0] + h[0]]; 

  /*---------- Free h(X) and b(X) ----------*/
  free(h);
  free(b);

} /* end Multiply_Poly */


/******************************************************************************
*                                                                             *
*                      Function FST_Interpolate()                             *
*                                                                             *
*******************************************************************************
*                                                                             *
*    This function performs the interpolation by continulally updating the    *
* the Groebner basis using the FST_Update_Groebner() function.                *
*                                                                             *
******************************************************************************/
void Interpolate(void)
{
  I_POINT *Interpolate_Point;    /* points to the Interpolate_List        */
  nType loop_counter;            /* runs over the interpolation positions */

  Interpolate_Point = &Interpolate_List[0];
  loop_counter = N_Interpolates;
  do{
    FST_Update_Groebner(Groebner,Interpolate_Point++);
    loop_counter--;
  } while (loop_counter);
} /* end Interpolate */


/******************************************************************************
*                                                                             *
*      Function FST_Update_Groebner(BI_POLY **Groebner, I_POINT *Point)       *
*                                                                             *
*******************************************************************************
*                                                                             *
*  This function updates the Groebner basis with a new interpolation point    *
* of given multiplicity. Discrepancy values are computed using the FST, while *
* Groebner polynomials are updated iteratively.                               *
*                                                                             *
******************************************************************************/
void FST_Update_Groebner(BI_Poly **Groebner, I_POINT *Interpolate_Point)
{
  mType m;                  /* multiplicity of (first) interpolation point   */
  mType m2;                 /* multiplicity of (second) interpolation point  */
  bit second;               /* designates if there's a second point for Px   */
  BI_Poly *Q;               /* generic pointer to a Groebner polynomial      */
  mType  Y_degree;          /* Y-degree of a Groebner/Discrepancy poynomial  */
  int    *X_degrees;        /* X-degrees of a generic Groebner polynomial    */
  byte   *q;                /* points to a q(X) component of Q(X,Y)          */
  int    n;                 /* degree of q(X)                                */
  int    nprime;            /* auxiliary used in FST Discrepancy computation */
  int    nplus1;            /* auxiliary used in FST Discrepancy computation */
  int    gap_aux;           /* auxiliary used in FST Discrepancy computation */
  D_BI_Poly D;              /* generic pointer to a Discrepancy polynomial   */
  D_BI_Poly D2;             /* generic pointer to a Discrepancy2 polynomial  */
  byte   *d;                /* points to a d(y) component of D(Y,X)          */
  byte  *d2;                /* points to a d(y) component of D2(Y,X)         */
  bit   D2_flag;            /* indicates if D2(X,Y) needs to be computed     */
  eType  exp_Px;            /* exponent of the Px point  */
  eType  exp_Py;            /* exponent of the Py point  */
  eType  exp_Py2;           /* exponent of the Py2 point */
  eType  beta_exp;          /* exponent used in the FST and Discr updates    */
  eType  beta_exp2;         /* exponent used in the FST and Discr updates    */
  byte   aux;               /* auxiliary byte used in Fast Shift Transform   */
  int    gap;               /* current value of gap in Fast Shift Transform  */
  int    gap_mask;          /* gap - 1, always of the form 00...011...1      */
  int    first_index;       /* index of the first position in FST butterfly  */
  int    second_index;      /* index of the second position in FST butterfly */
  mType  dX, dY;            /* degrees of Hasse derivatives while updating   */
  D_BI_Poly pivot;          /* the pivot Discrepancy polynomial              */
  D_BI_Poly pivot2;         /* pivot Discrepancy2 polynomial, if (second)    */
  BI_Poly *G_pivot;         /* the pivot Groebner polynomial                 */
  byte **pivot_poly;        /* pivot Groebner's polynomial coefficients      */
  int X_degree;             /* the X-degree of pivot_poly[y]                 */
  int new_X_degree;         /* the new (updated) X-degree of pivot_poly[y]   */
  int max_X_degree;         /* pivot Groebner's maximum X_degree             */
  byte   *p;                /* points to a d(y) component of pivot D(Y,X)    */
  byte    alpha;            /* discrepancy of the D polynomial being updated */
  eType   multiplier;       /* exponent of multiplier in Discrepancy update  */
  register byte gamma;      /* auxiliary used to speed-up the update loop    */
  mType m_minus1;           /* = m-1, auxiliary used to speed-up update loop */
  int   pivot_degree;       /* updated weighted-degree of pivot polynomial   */
  mType pivot_number;       /* used to store Sorter[i] in update + sorting   */
  mType update_number;      /* used to store Sorter[k] in during update      */
  eType *e;                 /* pointer to pivot_exp[y] for Groebner update   */
  mType update_count;       /* counts the number of Groebners to be updated  */
  bit  pivot_exp_flag;      /* signifies whether pivot_exp is to be used     */
  int i;                    /* index used in sorting, finding the pivot, etc */
  int k;                    /* index used in updating other Discrepancies[]  */
  register int x;           /* runs over powers of X */
  register mType y;         /* runs over powers of Y */
  bit ReSort_flag = 0;      /* signifies whether Groebners need be re-sorted */
  static byte *h;           /* auxiliary polynomial in discrpncy computation */
  static eType **pivot_exp; /* exponents of the pivot Groebner, auxiliary    */
  static bit  first = 1;
  
  /* ---------------- Initialize upon first invocation ----------------- */
  if (first)
    {
      h = Alloc_Byte_Vector(Max_X_degree+1);
      if ((pivot_exp = (eType **)malloc((Max_Y_degree+1) * 
					sizeof(eType *)))== NULL)
	Exit("Unable to allocate the auxiliary pivot polynomial!");

      for (i = 0; i <= Max_Y_degree; i++)
	if ((pivot_exp[i]=(eType *) malloc((Max_X_degree+1) *
					   sizeof(eType)))==NULL)
	  Exit("Unable to allocate the auxiliary pivot polynomial!");

      first = 0;
    } /* end if (first) */

   /* -------------- Initialize some important variables ---------------- */
  exp_Px = GF_log[Interpolate_Point->Px];
  exp_Py = GF_log[Interpolate_Point->Py];
  m = Interpolate_Point->m;
  if ((second = Interpolate_Point->second))
    {
      exp_Py2 = GF_log[Interpolate_Point->Py2];
      m2 = Interpolate_Point->m2;
    }
  else m2 = 0;
  m_minus1 = m - 1;

   /* -------------- Compute the Discrepancy polynomials ---------------- */
  for (i = 0; i <= max_Y_degree; i++) 
    {
      Q = Groebner[i];
      Y_degree = Q->Y_degree;
      X_degrees = Q->X_degrees; 
      D = Discrepancy[i];
      if (second) D2 = Discrepancy2[i];

      /* Loop over all the q(X) polynomials of Q_i(X,Y) = \sum q_j(X) Y^j */
      for (y = 0; y <= Y_degree; y++) 
	{
	  /*----Copy q(X) into h(X)----*/
	  if ( (x = n = X_degrees[y]) >= 0)
	    {
	      q = Q->polynomial[y];
	      for ( ; x; ) h[x--] = q[x];  
	      h[0] = q[0];
	    }
	  else 
	    {
	      for (x = 0; x < m; x++) D[x][y] = 0;
	      if (second) for (x = 0; x < m2; x++) D2[x][y] = 0;
	      continue;  /* to the next y <= Y_degree */
	    }

         /*----Fast shift transform on h(X)----*/
	  if (n) 
	    {
	      beta_exp = exp_Px;
	      nplus1 = n+1;

              /*----First stage of the FST----*/
	      if ( (n & 1) ) second_index = n+1; else second_index = n; 
	      for ( ; second_index; )
		{
		  aux = GFmultExp(h[--second_index],beta_exp);  
		  h[--second_index] ^= aux;
		}
	      if ( (beta_exp <<= 1) >= group_size ) beta_exp -= group_size;

              /*----Early stages of the FST---*/
	      nprime = MIN(m,n/2);
	      for (gap = 2; gap <= nprime; gap <<= 1)
		{
		  gap_mask = gap-1;
		  second_index = n/gap;
		  if ( (second_index & 1) ) second_index = nplus1;
		  else second_index *= gap;
		  first_index = second_index - gap;
		  for (; second_index; first_index -= gap, second_index -= gap)
		    do 
		      h[--first_index] ^= 
			GFmultExp(h[--second_index],beta_exp);  
		    while (first_index & gap_mask);

		  if ( (beta_exp <<= 1) >= group_size ) beta_exp -= group_size;
		} /* end for (gap = 2; gap <= nprime; gap <<= 1) */

              /*----Late stages of the FST----*/
	      for (nprime = n/2; gap <= nprime; gap <<= 1)
		{
		  gap_mask = gap-1;
		  gap_aux = (gap<<1) + m;
		  first_index = m;
		  second_index = m + gap;
		  for ( ; second_index <= nplus1; first_index += gap_aux, 
			  second_index += gap_aux)
		    do h[--first_index] ^= 
			 GFmultExp(h[--second_index],beta_exp);  
		    while (first_index & gap_mask);

		  if (second_index - nplus1 < m)
		    {
		      second_index = nplus1;
		      first_index = second_index - gap;
		      do h[--first_index] ^= 
			   GFmultExp(h[--second_index],beta_exp);  
		      while (first_index & gap_mask);
		    }
		  if ( (beta_exp <<= 1) >= group_size ) beta_exp -= group_size;
		} /* end for (gap = 2; gap <= nprime; gap <<= 1) */

              /*----Last stage of the FST-----*/
	      if (( nprime = MIN(m,n-gap+1) ))
		{
		  first_index = nprime;
		  second_index = nprime + gap;
		  do h[--first_index] ^= 
		       GFmultExp(h[--second_index],beta_exp);  
		  while (first_index);
		}
	    } /* end if ( (Px) && (n) ) */

	  /*----Copy h(X) into Discrepancy[i] ----*/
	  if (n < m_minus1) for (x = n+1; x < m; x++) h[x] = 0;
	  for (x = 0; x < m; x++) D[x][y] = h[x];
	  if (second) for (x = 0; x < m2; x++) D2[x][y] = h[x];
	} /* end for (y = 0; y <= Y_degree; y++) */

      /* If Y_degree < m-1, then zero-out remaining terms in D_i(Y,X) */
      for ( ; y < m2; y++)
	{
	  for (x = 0; x < m2; x++) { D[x][y] = 0; D2[x][y] = 0; }
	  for ( ; x < m; x++) D[x][y] = 0;
	}
      for ( ; y < m; y++)
	for (x = 0; x < m; x++) D[x][y] = 0;

      /* Loop over all the d(Y) polynomials of D_i(Y,X) = \sum d_j(Y) X^j */
      if (Interpolate_Point->Py)
	{
	  D2_flag = (second) && (Interpolate_Point->Py2);
	  for (x = 0; x < m; x++) 
	    {
	      d = D[x];
	      if (x >= m2) D2_flag = 0;
	      if (D2_flag) d2 = D2[x];

	      /*----Fast shift transform on d(Y)----*/
	      beta_exp = exp_Py;
	      beta_exp2 = exp_Py2;
	      for (gap = 1; gap <= Y_degree; gap <<= 1)
		{
		  gap_mask = gap-1;
		  first_index = 0;
		  second_index = gap;
		  for ( ; second_index <= Y_degree; 
			first_index += gap, second_index += gap)
		    do{
		      d[first_index] ^= GFmultExp(d[second_index],beta_exp);  
		      if (D2_flag)
			d2[first_index++] ^= 
			  GFmultExp(d2[second_index++],beta_exp2); 
		      else { first_index++; second_index++; }
		      if (second_index > Y_degree) goto square_beta_Py; 
		    } while (first_index & gap_mask);
		square_beta_Py: if ( (beta_exp <<= 1) >= group_size ) 
		  beta_exp -= group_size;
		  if (D2_flag) if ( (beta_exp2 <<= 1) >= group_size )
		    beta_exp2 -= group_size;
		} /* end for (gap = 1; gap <= n; gap <<= 1) */
	    } /* end  for (x = 0; x < m; x++) */
	} /* end if (Py) */

      /* Same thing for the second Disrepancy2 polynomial, if exists */
      else if (second) for (x = 0; x < m2; x++) 
	{
	  d = D2[x];

         /*----Fast shift transform on d(Y)----*/
	  beta_exp = exp_Py2;
	  for (gap = 1; gap <= Y_degree; gap <<= 1)
	    {
	      gap_mask = gap-1;
	      first_index = 0;
	      second_index = gap;
	      for ( ; second_index <= Y_degree; 
		    first_index += gap, second_index += gap)
		do{
		  d[first_index++] ^= GFmultExp(d[second_index++],beta_exp);  
		  if (second_index > Y_degree) goto square_beta_Py2; 
		} while (first_index & gap_mask);
	    square_beta_Py2: if ( (beta_exp <<= 1) >= group_size ) 
	      beta_exp -= group_size;
	    } /* end for (gap = 1; gap <= n; gap <<= 1) */
	} /* end if (second) for (x = 0; x < m2; x++) */
    } /* end for (i = 0; i <= max_Y_degree; i++) */

   /* ------- Update the Discrepancy and Groebner polynomials ----------- */
  for (dX = dY = 0; dY < m; dX = dY) 
    for (dY = 0; dX >= 0; dX--, dY++)
      {
        /* Find the pivot */
	for (i = 0; 
	     (i <= max_Y_degree) 
	       && (Discrepancy[Sorter[i]][dX][dY] == 0); 
	     i++);

        /* assumes that indices in Sorter[i] are sorted by weighted-degree */
	if (i > max_Y_degree)  /* all discrepancies are zero! */
	  continue;  /* proceed to the next Hasse derivative */
	pivot_number = Sorter[i];
	pivot = Discrepancy[pivot_number];
	if (second) pivot2 = Discrepancy2[pivot_number];
	beta_exp = GF_log[pivot[dX][dY]];
	G_pivot = Groebner[pivot_number];
	pivot_poly = G_pivot->polynomial;
	max_X_degree = G_pivot->max_X_degree;
	Y_degree = G_pivot->Y_degree;
	X_degrees = G_pivot->X_degrees;

        /* Count the number of Groebners to be updated; set-up pivot_exp */
	update_count = 0;
	pivot_exp_flag = 0;
	for (k = i+1; k <= max_Y_degree; k++) 
	  if (Discrepancy[Sorter[k]][dX][dY]) update_count++;
	if (update_count > 1)
	  {
	    pivot_exp_flag = 1;
	    for (y = 0; y <= Y_degree; y++) 
	      if ( (X_degree = X_degrees[y]) >= 0)
		{
		  e = pivot_exp[y];
		  p = pivot_poly[y];
		  for (x = X_degree; x; ) e[x--] = GF_log[p[x]];
		  e[0] = GF_log[p[0]];
		} /* end for (y = 0; y <= Y_degree; y++) */
	  }

        /* Update the polynomials with nonzero discrepancies */
	for (k = i+1; k <= max_Y_degree; k++) 
	  {
	    if ( (alpha = Discrepancy[Sorter[k]][dX][dY]) == 0 ) 
	      continue;

          /*--- Set-up auxiliary speed-up variables ---*/
	    update_number = Sorter[k];
	    D = Discrepancy[update_number];
	    if (second) D2 = Discrepancy2[update_number];
	    Q = Groebner[update_number];
	    if ( (multiplier = GF_log[alpha] - beta_exp) < 0 )
	      multiplier += group_size;
	    /* notice that alpha could not be 0 here */

          /*--- Update the Discrepancy polynomials ---*/
	    for (x = m_minus1; x >= 0; x--) 
	      {
		d = D[x];
		p = pivot[x];
		for (y = m_minus1-x; y; y--) 
		  if ((gamma = p[y])) d[y] ^= GFmultExp(gamma,multiplier);
		if ((gamma = p[0])) d[0] ^= GFmultExp(gamma,multiplier);
	      }
	    if (second)
	      for (x = m2 - 1; x >= 0; x--) 
		{
		  d = D2[x];
		  p = pivot2[x];
		  for (y = m2-1-x; y; y--) 
		    if ((gamma = p[y])) d[y] ^= GFmultExp(gamma,multiplier);
		  if ((gamma = p[0])) d[0] ^= GFmultExp(gamma,multiplier);
		}

	    /*--- Update the Groebner polynomials ---*/
	    for (y = 0; y <= Y_degree; y++) 
	      if ( (X_degree = X_degrees[y]) >= 0)
		{
		  q = Q->polynomial[y];
		  if (pivot_exp_flag)
		    {
		      e = pivot_exp[y];
		      for (x = X_degree; x; ) 
			q[x--] ^= GF_antilog[e[x] + multiplier];
		      q[0] ^= GF_antilog[e[0] + multiplier];
		    }
		  else 
		    { 
		      p = pivot_poly[y];
		      for (x = X_degree; x; ) 
			q[x--] ^= GFmultExp(p[x],multiplier);
		      q[0] ^= GFmultExp(p[0],multiplier);
		    }

		  /* Check if X_degrees[y] of Groebner_k changes */
		  new_X_degree = Q->X_degrees[y];
		  if (X_degree > new_X_degree) Q->X_degrees[y] = X_degree;
		  else
		    {
		      for (x = new_X_degree; (x >= 0) && (q[x] == 0); x--);
		      Q->X_degrees[y] = x;
		    }
		} /* end for (y = 0; y <= Y_degree; y++) */

            /* Update the Y degree and maximum X degree */
	    if (Y_degree > Q->Y_degree) Q->Y_degree = Y_degree;
	    else
	      {
		for (y = Q->Y_degree; Q->X_degrees[y] == -1; y--);
		Q->Y_degree = y;
	      }
	    if (max_X_degree > Q->max_X_degree) Q->max_X_degree = max_X_degree;
	  } /* end for (k = i+1; k <= max_Y_degree; k++) */

        /* Update the Discrepancy pivot polynomials */
	for (x = m_minus1; x > 0; x--) 
	  {
	    d = pivot[x]; 
	    p = pivot[x-1];
	    for (y = m_minus1-x; y; ) d[y--] = p[y];
	    d[0] = p[0];
	  }
	*(p = pivot[0]) = 0;
	for (y = m_minus1; y; ) p[y--] = 0;
            /* this zeroes out pivot_poly[x] for x = 0 */

	if (second)
	  {
	    for (x = m2 - 1; x > 0; x--) 
	      {
		d = pivot2[x]; 
		p = pivot2[x-1]; 
		for (y = m2-1-x; y; ) d[y--] = p[y];
		d[0] = p[0];
	      }
	    *(p = pivot2[0]) = 0;
	    for (y = m2 - 1; y; ) p[y--] = 0;
	  }

        /* Update the Groebner pivot polynomial */
	for (y = 0; y <= Y_degree; y++)
	  if ( (x = X_degrees[y]) >= 0)
	    {
	      p = pivot_poly[y];
	      p[x+1] = p[x];
	      if (pivot_exp_flag)
		{
		  e = pivot_exp[y];
		  for ( ; x; ) 
		    p[x--] = p[x-1] ^ GF_antilog[e[x] + exp_Px];
		  p[0] = GF_antilog[e[0] + exp_Px];
		}
	      else 
		{ 
		  for ( ; x; ) 
		    p[x--] = p[x-1] ^ GFmultExp(p[x],exp_Px);
		  p[0] = GFmultExp(p[0],exp_Px);
		}
	      X_degrees[y]++;
	    }
	/* this sequence multiplies the pivot by (X-Px) */
	G_pivot->max_X_degree++;
	G_pivot->weighted_degree++;

        /* Re-sort the Discrepancy polynomials */
	pivot_degree = ++weighted_degrees[pivot_number];
	while ((i!= max_Y_degree) && 
	       (pivot_degree>weighted_degrees[Sorter[i+1]]))
	  {
	    Sorter[i++] = Sorter[i+1];
	  }
	Sorter[i] = pivot_number;
	if (pivot_degree > max_weighted_degree) ReSort_flag = 1;
      } 

  /* --------- Update Discrepancy2 polynomials for second point -------- */

  if (second)
    for (dX = dY = 0; dY < m2; dX = dY) 
      for (dY = 0; dX >= 0; dX--, dY++)
	{
        /* Find the pivot */
	  for (i = 0; 
	       (i <= max_Y_degree) 
                 && 
                 (Discrepancy2[Sorter[i]][dX][dY] == 0); 
	       i++);
	  /* assumes that indices in Sorter[i] are sorted by weighted-degree */
	  if (i > max_Y_degree)  /* all discrepancies are zero! */
	    continue;  /* proceed to the next Hasse derivative */
	  pivot_number = Sorter[i];
	  pivot = Discrepancy2[pivot_number];
	  beta_exp = GF_log[pivot[dX][dY]];
	  G_pivot = Groebner[pivot_number];
	  pivot_poly = G_pivot->polynomial;
	  max_X_degree = G_pivot->max_X_degree;
	  Y_degree = G_pivot->Y_degree;
	  X_degrees = G_pivot->X_degrees;

	  /* Count the number of Groebners to be updated; set-up pivot_exp */
	  update_count = 0;
	  pivot_exp_flag = 0;
	  for (k = i+1; k <= max_Y_degree; k++) 
	    if (Discrepancy2[Sorter[k]][dX][dY]) update_count++;
	  if (update_count > 1)
	    {
	      pivot_exp_flag = 1;
	      for (y = 0; y <= Y_degree; y++) 
		if ( (X_degree = X_degrees[y]) >= 0)
		  {
		    e = pivot_exp[y];
		    p = pivot_poly[y];
		    for (x = X_degree; x; ) e[x--] = GF_log[p[x]];
		    e[0] = GF_log[p[0]];
		  } /* end for (y = 0; y <= Y_degree; y++) */
	    }

	  /* Update the polynomials with nonzero discrepancies */
	  for (k = i+1; k <= max_Y_degree; k++) 
	    {
	      if ( (alpha = Discrepancy2[Sorter[k]][dX][dY]) == 0 ) 
		continue;
	      /*--- Set-up auxiliary speed-up variables ---*/
	      update_number = Sorter[k];
	      D = Discrepancy2[update_number];
	      Q = Groebner[update_number];
	      if ( (multiplier = GF_log[alpha] - beta_exp) < 0 )
		multiplier += group_size;
	      /* notice that alpha could not be 0 here */

	      /*--- Update the polynomial coefficients ---*/
	      for (x = m2 - 1; x >= 0; x--) 
		{
		  d = D[x];
		  p = pivot[x];
		  for (y = m2-1-x; y; y--) 
		    if ((gamma = p[y])) d[y] ^= GFmultExp(gamma,multiplier);
		  if ((gamma = p[0])) d[0] ^= GFmultExp(gamma,multiplier);
		}

	      /*--- Update the Groebner polynomials ---*/
	      for (y = 0; y <= Y_degree; y++) 
		if ( (X_degree = X_degrees[y]) >= 0)
		  {
		    q = Q->polynomial[y];
		    if (pivot_exp_flag)
		      {
			e = pivot_exp[y];
			for (x = X_degree; x; ) 
			  q[x--] ^= GF_antilog[e[x] + multiplier];
			q[0] ^= GF_antilog[e[0] + multiplier];
		      }
		    else 
		      { 
			p = pivot_poly[y];
			for (x = X_degree; x; ) 
			  q[x--] ^= GFmultExp(p[x],multiplier);
			q[0] ^= GFmultExp(p[0],multiplier);
		      }

		    /* Check if X_degrees[y] Groebner_k changes */
		    new_X_degree = Q->X_degrees[y];
		    if (X_degree > new_X_degree) Q->X_degrees[y] = X_degree;
		    else
		      {
			for (x = new_X_degree; (x >= 0) && (q[x] == 0); x--);
			Q->X_degrees[y] = x;
		      }
		  } /* end for (y = 0; y <= Y_degree; y++) */

	      /* Update the Y degree and maximum X degree */
	      if (Y_degree > Q->Y_degree) Q->Y_degree = Y_degree;
	      else
		{
		  for (y = Q->Y_degree; Q->X_degrees[y] == -1; y--);
		  Q->Y_degree = y;
		}
	      if (max_X_degree > Q->max_X_degree) 
		Q->max_X_degree = max_X_degree;
	    } /* end for (k = i+1; k <= max_Y_degree; k++) */

        /* Update the pivot polynomial */
	  for (x = m2-1; x > 0; x--) 
	    {
	      d = pivot[x]; 
	      p = pivot[x-1]; 
	      for (y = m2-1-x; y; ) d[y--] = p[y];
	      d[0] = p[0];
	    }
	  *(p = pivot[0]) = 0;
	  for (y = m2-1; y; ) p[y--] = 0;
            /* this zeroes out pivot_poly[x] for x = 0 */

	  /* Update the Groebner pivot polynomial */
	  for (y = 0; y <= Y_degree; y++)
	    if ( (x = X_degrees[y]) >= 0)
	      {
		p = pivot_poly[y];
		p[x+1] = p[x];
		if (pivot_exp_flag)
		  {
		    e = pivot_exp[y];
		    for ( ; x; ) 
		      p[x--] = p[x-1] ^ GF_antilog[e[x] + exp_Px];
		    p[0] = GF_antilog[e[0] + exp_Px];
		  }
		else 
		  { 
		    for ( ; x; ) 
		      p[x--] = p[x-1] ^ GFmultExp(p[x],exp_Px);
		    p[0] = GFmultExp(p[0],exp_Px);
		  }
		X_degrees[y]++;
	      }

	  /* this sequence multiplies the pivot by (X-Px) */
	  G_pivot->max_X_degree++;
	  G_pivot->weighted_degree++;

	  /* Re-sort the Discrepancy polynomials */
	  pivot_degree = ++weighted_degrees[pivot_number];
	  while ((i!= max_Y_degree) && 
		 (pivot_degree>weighted_degrees[Sorter[i+1]]))
	    {
	      Sorter[i++] = Sorter[i+1];
	    }
	  Sorter[i] = pivot_number;
	  if (pivot_degree > max_weighted_degree) ReSort_flag = 1;
	}
  
  if (ReSort_flag) ReSort_Groebner(Groebner);

} /* end FST_Update_Groebner */


/******************************************************************************
*                                                                             *
*           Function void ReSort_Groebner(BI_Poly **Groebner)                 *
*                                                                             *
*******************************************************************************
*                                                                             *
*  This function re-sorts the Groebner basis in the order of weighted degrees *
* and also decreases the total number of Groebner polynomials, if needed.     *
*                                                                             *
******************************************************************************/
void ReSort_Groebner(BI_Poly **Groebner)
{
  mType i;             
  static BI_Poly **Tmp_Groebner;
  static int *tmp_degrees;
  static bit  first = 1;

   /* ---------------- Initialize upon first invocation ----------------- */
  if (first)
    {
      if ( (Tmp_Groebner = 
            (BI_Poly **)malloc((Max_Y_degree+1)*sizeof(BI_Poly *))) == NULL)
	Exit("Unable to allocate the Tmp_Groebner in ReSort_Groebner!");
      tmp_degrees = Alloc_Int_Vector(Max_Y_degree+1);
      first = 0;
    } /* end if (first) */

  /* ----------- Copy Groebner[] and weighted_degrees[] to Tmp --------- */
  for (i = 0; i <= max_Y_degree; i++) 
    {
      Tmp_Groebner[i] = Groebner[i];
      tmp_degrees[i] = weighted_degrees[i];
    }

  /* --------------------- Re-sort the Groebners[] --------------------- */
  for (i = 0; i <= max_Y_degree; i++) 
    {
      Groebner[i] = Tmp_Groebner[Sorter[i]]; 
      weighted_degrees[i] = tmp_degrees[Sorter[i]];
    }
  while (weighted_degrees[max_Y_degree] > max_weighted_degree) 
    max_Y_degree--;

  for (i = 0; i <= max_Y_degree; i++)
    Sorter[i] = i; 

} /* end ReSort_Groebner */


/******************************************************************************
*                                                                             *
*                         Function Factor()                                   *
*                                                                             *
*******************************************************************************
*                                                                             *
*  This function produces the postions and values of the errors in the RS.k   *
* ReEncoded positions by factoring the least Groebner polynomial. If a factor *
* is found, it will reconstruct the transmitted codeword from MR_symbols.     *
*                                                                             *
******************************************************************************/
int Factor(void)
{
  I_POINT *Interpolate_Point;    /* points to Interpolate_List            */
  R_POINT *ReEncode_Point;       /* points to ReEncode_List               */
  nType  N_Errors;         /* number of errors in RS.k ReEncode positions */
  nType  e;                /* index used to run over the errors found     */ 
  eType delta[RSK];       /* adjusted exponents for re-encoding positions */
  eType *delta_ptr;       /* pointer to delta[RS.k]                       */
  nType reEncode_counter; /* runs over the nonzero re-encoding positions  */
  nType loop_counter;     /* runs over interpolation/re-encoding positions*/
  nType i;                /* the current interpolation position           */
  nType j;                /* runs over various positions                  */
  byte  c_i;              /* the computed codeword symbol/Theta(\alpha^i) */
  int denominator;        /* denominator exponent in \delta_i, Theta(alpha^i)*/
  eType exponent;         /* overall exponent in \delta_i and Theta(\alpha^i)*/

   /* -------------- Factor the first Groebner polynomial --------------- */
  N_Errors = Factor_BI_Poly(Groebner[Sorter[0]],Error_Positions,Error_Values);
  if (N_Errors < 0) 
    {
      for (j = 0; j < RS.n; j++)
	decoded_codeword[j] = MR_symbols[j];
      return(N_Errors);
    }

   /*----- Compute the \delta_i values and ReEncode_Values[] ------------*/
  if ((e = N_Errors))
    {
      delta_ptr = &delta[0]; 
      do{
	i = GF_log[Error_Positions[--e]]; 
	/* this is the current error position */
	/* Compute the exponent of the denominator */
	denominator = 0;
	if (N_Erasures)
	  {
	    j = N_Erasures;
	    do denominator += Zech[Erasure_Positions[--j]-i]; 
	    while (j);
	  }
	j = N_Interpolates;
	do denominator += Zech[Interpolate_Positions[--j]-i];
	while (j);

           /* Compute the ReEncode value */
	if ( (exponent = 
	      (i*(RS.k-1) + RS.Zech[i] - denominator) % group_size) < 0 )
	  exponent += group_size;	
	ReEncode_Values[e] = GF_log[Error_Values[e]] + exponent;

           /* Compute the overall exponent and store it */
	if ( (exponent = ( denominator + ReEncode_Values[e] 
			   - i*RS.k - RS.Zech[i] ) % group_size) < 0 )
	  exponent += group_size;                               
	*delta_ptr++ = exponent;
      } while (e);
    } /* end if ((e = N_Errors)) */

   /*------ Compute \Theta(\alpha^i) for the interpolation positions ----*/
  Interpolate_Point = &Interpolate_List[0];
  loop_counter = N_Interpolates;
  do{
    i = Interpolate_Point->j; /* that's the current interpolation position */

    /* Compute the exponent of the denominator */
    denominator = 0;  
    if ((j = N_Erasures))
      do denominator += Zech[Erasure_Positions[--j]-i]; 
      while (j);

    j = N_Interpolates;
    do denominator += Zech[Interpolate_Positions[--j]-i];
    while (j);
    /*
      Although this loop adds to the denominator an
      extraneous Zech[0] = 2*group_size, this will
      cancel out under the modulus operation later
    */

    /* Compute the overall exponent of \Theta(\alpha^i) */
    if ( (exponent = (RS.k*i + RS.Zech[i] - denominator) % group_size) < 0 )
      exponent += group_size;
    /* Finally, compute the error codeword */
    c_i = 0;
    if ((reEncode_counter = N_Errors))
      {
	delta_ptr = &delta[0];
	/* This loop computes the codeword, up to factor of \Theta(\al^i) */
	do{ c_i ^= GFexpN(*delta_ptr++ - 
                          Zech[i-GF_log[Error_Positions[--reEncode_counter]]]);
	} while (reEncode_counter);
      } /* end if ((reEncode_counter = N_Errors)) */
    error_codeword[i] = GFmultExp(c_i,exponent); 
    Interpolate_Point++;
    loop_counter--;
  } while (loop_counter);

  /*------ Compute \Theta(\alpha^i), etc. for the ERASURE positions ----*/
  if (N_Erasures)
    {
      loop_counter = N_Erasures;
      do{
	i = Erasure_Positions[--loop_counter];
	/* this is the current erasure position */

	/* Compute the exponent of the denominator */
       denominator = 0;
       j = N_Erasures;
       do denominator += Zech[Erasure_Positions[--j]-i]; 
       while (j);

       j = N_Interpolates;
       do denominator += Zech[Interpolate_Positions[--j]-i];
       while (j);

       /* Compute the overall exponent of \Theta(\alpha^i) */
       if ( (exponent = (RS.k*i + RS.Zech[i] - denominator) % group_size) < 0 )
	 exponent += group_size;

       /* Compute the codeword */
       c_i = 0;
       if ((reEncode_counter = N_Errors))
	 {
           delta_ptr = &delta[0];
           do{ c_i ^= GFexpN(*delta_ptr++ - 
		  Zech[i-GF_log[Error_Positions[--reEncode_counter]]]);
           } while (reEncode_counter);
	 } /* end if ((reEncode_counter = N_Errors)) */
       error_codeword[i] = GFmultExp(c_i,exponent); 
      } while (loop_counter);

    } /* end if (N_Erasures) */

   /*-------- Complete the error_codeword for ReEncode positions --------*/
  loop_counter = RS.k;
  ReEncode_Point = &ReEncode_List[0];
  do{
    j = ReEncode_Point->j;  
    error_codeword[j] = 0;
    ReEncode_Point++;
    loop_counter--;
  } while (loop_counter);

  if ((e = N_Errors))
    do{
      j = GF_log[Error_Positions[--e]];  /* current error position */
      error_codeword[j] = GFexp(ReEncode_Values[e]);
    } while (e);

   /*------------ Finally produce the decoded codeword ------------------*/
  for (j = 0; j < RS.n; j++)
    decoded_codeword[j] = GFdiv(error_codeword[j] ^ 
				shift_codeword[j],RS.Psi[j]);
  return(N_Errors);
} /* end Factor */



/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*                                                                         *
*                  FIELD ARITHMETIC FUNCTIONS                             *
*                                                                         *
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/


/**************************************************************************
*                                                                         *
*            Function Primitive_Polynomial(int m)                         *
*                                                                         *
***************************************************************************
*                                                                         *
*  This function generates a primitive polynomial for the field using     *
*  pre-computed coefficients. The coefficients are taken from the book    *
*  by Lin and Costello, p. 29. The integer m must be between 1 and 24.    *
*                                                                         *
**************************************************************************/
byte *Primitive_Polynomial(int m)                         
{
  int i;
  byte *p;   /* primitive polynomial to be returned */

  /* Initialize */
  p = Alloc_Byte_Vector(m+1);
  for (i = 0; i < m; i++) p[i] = 0;

  /* Fill-in nonzero coefficients of the primitive polynomial */
  p[0] = p[m] = 1; 
  switch(m)
    {
    case 1: break;
    case 2: p[1] = 1; break;
    case 3: p[1] = 1; break;
    case 4: p[1] = 1; break;
    case 5: p[2] = 1; break;
    case 6: p[1] = 1; break;
    case 7: p[3] = 1; break;
    case 8: p[2] = p[3] = p[4] = 1; break;
    case 9: p[4] = 1; break;
    case 10: p[3] = 1; break;
    case 11: p[2] = 1; break;
    case 12: p[1] = p[4] = p[6] = 1; break;
    case 13: p[1] = p[3] = p[4] = 1; break; 
    case 14: p[1] = p[6] = p[10] = 1; break;
    case 15: p[1] = 1; break;               
    case 16: p[1] = p[3] = p[12] = 1; break;
    case 17: p[3] = 1; break;               
    case 18: p[7] = 1; break;               
    case 19: p[1] = p[2] = p[5] = 1; break; 
    case 20: p[3] = 1; break;               
    case 21: p[2] = 1; break;
    case 22: p[1] = 1; break;
    case 23: p[5] = 1; break;
    case 24: p[1] = p[2] = p[7] = 1; break;
    default: fprintf(stderr,"\n\n Coefficients of primitive polynomial ");
      fprintf(stderr,"unknown for requested field size! Exiting..\n\n");
      exit(1);
    }
  return p;
}  /* end Primitive_Polynomial */


/**************************************************************************
*                                                                         *
*            Function Generate_GF(byte p[], int m)                        *
*                                                                         *
***************************************************************************
*                                                                         *
*  This function generates the log and antilog tables of the field from   *
* the primitive polynomial p[] and log-order m.                           *
*                                                                         *
**************************************************************************/
void Generate_GF(byte *p, int m)
{
  register int i;
  register byte mask;
  register int Mprime;

    /* Initialize */
  GF_log = Alloc_nType_Vector(field_size);
  GF_antilog = Alloc_Byte_Vector(4*field_size);
  Zech_Table = Alloc_nType_Vector(2*field_size);

  /* Compute the GF_antilog table */
  /* --initialize-- */
  mask = 1; 
  GF_antilog[m] = 0; 

  /* --compute the first m entries, 
     and the polynomial in GF_antilog[m]-- */
  for (i = 0; i < m; i++)
    { 
      if (p[i]!=0) GF_antilog[m] ^= mask; 
      GF_antilog[i] = mask; 
      mask <<= 1; 
    }

  /* --compute the remaining entries-- */
  Mprime = POW2(m-1);
  for (i = m+1; i < field_size; i++)
    { 
      if (GF_antilog[i-1] >= Mprime)  /* tests if the MSB is nonzero */
	GF_antilog[i] = GF_antilog[m] ^ ( (GF_antilog[i-1]^Mprime) << 1 ); 
      else GF_antilog[i] = GF_antilog[i-1] << 1; 
    }

  /* --verify computation, if not OK exit-- */
  if (GF_antilog[field_size-1] != 1)
    {
      fprintf(stderr,"\n Problems constructing log table of a finite field!");
      fprintf(stderr,"  Exiting...\n");
      exit(1);
    }

    /* Compute the GF_log table */
  GF_log[0] = GF_log0; 
  for (i = 0; i < field_size-1; i++)    
    GF_log[GF_antilog[i]] = i;   /* GF_antilog[i] ranges over 1 to M-1 */

  /* Extend the GF_antilog table */
  for (i = 0; i < field_size-1; i++)    
    GF_antilog[field_size-1+i] = GF_antilog[i];
  for (i = 0; i <= 2*field_size; i++)    
    GF_antilog[2*(field_size-1)+i] = 0;
  GF_antiNeg = &GF_antilog[field_size-1];
  /* this allows for negative arguments to GF_antiNeg[] */

  /* Compute the Zech log table */
  for (i = 0; i < field_size-1; i++)    
    Zech_Table[(field_size-1)+i] = GF_log[1 ^ GFexp(i)]; 
  /* Zech[i] = the exponent of (1+alpha^i) */
  for (i = 1; i < field_size-1; i++)
    Zech_Table[i] = GF_log[1 ^ GFexp(i)]; 

  Zech = &Zech_Table[field_size-1];
  /* this allows for negative arguments to Zech[] */
  
} /* end Generate_GF */


/**************************************************************************
*                                                                         *
*               Function GFmult(byte a, byte b)                           *
*                                                                         *
***************************************************************************
*                                                                         *
*  This function returns a*b, assuming both a and b are in polynomial     *
* form, using the log and antilog tables of the field.                    *
*                                                                         *
**************************************************************************/
byte GFmult(byte a, byte b)
{
  if (a == 0) return 0;
  if (b == 0) return 0;
  return GF_antilog[ GF_log[a] + GF_log[b] ];
} /* end GFmult */


/**************************************************************************
*                                                                         *
*                Function GFdiv(byte a, byte b)                           *
*                                                                         *
***************************************************************************
*                                                                         *
*  This function returns a/b, assuming both a and b are in polynomial     *
* form, using the log and antilog tables of the field. The function exits *
* with an error message if b is zero.                                     *
*                                                                         *
**************************************************************************/
byte GFdiv(byte a, byte b)
{
  if (b == 0) 
    {
      fprintf(stderr,"\n\nDivision by zero in GFdiv!  Exiting...\n\n");
      exit(1);
    }
  if (a == 0) return 0;
  return GF_antilog[ (group_size + GF_log[a]-GF_log[b]) % group_size ];
} /* end GFdiv */


/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*                                                                         *
*                        ALLOCATION FUNCTIONS                             *
*                                                                         *
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/



/**************************************************************************
*                                                                         *
*               Function  *Alloc_Double_Vector(long N)                    *
*                                                                         *
**************************************************************************/
double *Alloc_Double_Vector (long N)
{
  double *p;

  if ((p = (double *) malloc(N * sizeof(double))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of doubles..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_Double_Vector */


/**************************************************************************
*                                                                         *
*               Function  *Alloc_Float_Vector(long N)                     *
*                                                                         *
**************************************************************************/
float *Alloc_Float_Vector (long N)
{
  float *p;

  if ((p = (float *) malloc(N * sizeof(float))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of floats..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_Float_Vector */


/**************************************************************************
*                                                                         *
*                 Function  *Alloc_Int_Vector(long N)                     *
*                                                                         *
**************************************************************************/
int *Alloc_Int_Vector (long N)
{
  int *p;

  if ((p = (int *) malloc(N * sizeof(int))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of integers..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_Int_Vector */


/**************************************************************************
*                                                                         *
*               Function  *Alloc_Bit_Vector(long N)                       *
*                                                                         *
**************************************************************************/
bit *Alloc_Bit_Vector (long N)
{
  bit *p;

  if ((p = (bit *) malloc(N * sizeof(bit))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of bits..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_Bit_Vector */


/**************************************************************************
*                                                                         *
*               Function  *Alloc_Byte_Vector(long N)                      *
*                                                                         *
**************************************************************************/
byte *Alloc_Byte_Vector (long N)
{
  byte *p;

  if ((p = (byte *) malloc(N * sizeof(byte))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of bytes..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_Byte_Vector */


/**************************************************************************
*                                                                         *
*               Function  *Alloc_eType_Vector(long N)                     *
*                                                                         *
**************************************************************************/
eType *Alloc_eType_Vector (long N)
{
  eType *p;
  
  if ((p = (eType *) malloc(N * sizeof(eType))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of eTypes..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_eType_Vector */

/**************************************************************************
*                                                                         *
*               Function  *Alloc_mType_Vector(long N)                     *
*                                                                         *
**************************************************************************/
mType *Alloc_mType_Vector (long N)
{
  mType *p;

  if ((p = (mType *) malloc(N * sizeof(mType))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of mTypes..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_mType_Vector */


/**************************************************************************
*                                                                         *
*               Function  *Alloc_nType_Vector(long N)                     *
*                                                                         *
**************************************************************************/
nType *Alloc_nType_Vector (long N)
{
  nType *p;

  if ((p = (nType *) malloc(N * sizeof(nType))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of nTypes..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_nType_Vector */


/**************************************************************************
*                                                                         *
*               Function  *Alloc_pType_Vector(long N)                     *
*                                                                         *
**************************************************************************/
pType *Alloc_pType_Vector (long N)
{
  pType *p;

  if ((p = (pType *) malloc(N * sizeof(pType))) == NULL)
    {
      fprintf(stderr,"\n ** Unable to allocate a [%ld] vector of pTypes..\n",N);
      exit(1);
    }
  return p;
} /* end Alloc_pType_Vector */


/**************************************************************************
*                                                                         *
*            Function  **Alloc_Bit_Matrix(long N, long M)                 *
*                                                                         *
**************************************************************************/
bit **Alloc_Bit_Matrix (long N, long M)
{
  bit *workp, **p;
  long i, j;

  if ((p = (bit **) malloc(N * sizeof(bit *))) == NULL)
    {
      fprintf(stderr,
	      "\n ** Unable to allocate a [%ldx%ld] matrix of bits..\n",N,M);
      exit(1);
    }
  if ((workp = (bit *) malloc(N * M * sizeof(bit))) == NULL)
    {
      fprintf(stderr,
	      "\n ** Unable to allocate a [%ldx%ld] matrix of bits..\n",N,M);
      exit(1);
    }

  for (i = j = 0; i < N; i++, j += M)
    p[i] = &workp[j];
  return p;
} /* end Alloc_Bit_Matrix */


/**************************************************************************
*                                                                         *
*            Function  **Alloc_Byte_Matrix(long N, long M)                *
*                                                                         *
**************************************************************************/
byte **Alloc_Byte_Matrix (long N, long M)
{
  byte *workp, **p;
  long i, j;

  if ((p = (byte **) malloc(N * sizeof(byte *))) == NULL)
    {
      fprintf(stderr,
	      "\n ** Unable to allocate a [%ldx%ld] matrix of bytes..\n",N,M);
      exit(1);
    }
  if ((workp = (byte *) malloc(N * M * sizeof(byte))) == NULL)
    {
      fprintf(stderr,
	      "\n ** Unable to allocate a [%ldx%ld] matrix of bytes..\n",N,M);
      exit(1);
    }
  for (i = j = 0; i < N; i++, j += M)
    p[i] = &workp[j];
  return p;
} /* end Alloc_Byte_Matrix */


/**************************************************************************
*                                                                         *
*            Function  **Alloc_nType_Matrix(long N, long M)               *
*                                                                         *
**************************************************************************/
nType **Alloc_nType_Matrix(long N, long M)
{
  nType *workp, **p;
  long i, j;

  if ((p = (nType **) malloc(N * sizeof(nType *))) == NULL)
    {
      fprintf(stderr,
	      "\n ** Unable to allocate a [%ldx%ld] matrix of nTypes..\n",N,M);
      exit(1);
    }
  if ((workp = (nType *) malloc(N * M * sizeof(nType))) == NULL)
    {
      fprintf(stderr,
	      "\n ** Unable to allocate a [%ldx%ld] matrix of nTypes..\n",N,M);
      exit(1);
    }
  for (i = j = 0; i < N; i++, j += M)
    p[i] = &workp[j];
  
  return p;
} /* end Alloc_nType_Matrix */


/**************************************************************************
*                                                                         *
*      Function Allocate_BI_Poly(int max_X_degree, int Y_degree)          *
*                                                                         *
***************************************************************************
*                                                                         *
*      This function allocates a bivariate polynomial.                    *
*                                                                         *
**************************************************************************/
BI_Poly *Allocate_BI_Poly(int max_X_degree, int Y_degree)
{
  BI_Poly *Q;
  int i;

  if ( (Q = (BI_Poly *) malloc(sizeof(BI_Poly))) == NULL)
    Exit("Unable to allocate a bivariate polynomial!");
  Q->max_X_degree = max_X_degree;
  Q->Y_degree = Y_degree; 
  if ((Q->X_degrees = (int *) malloc( (Y_degree+1)*sizeof(int))) == NULL)
    Exit("Unable to allocate a bivariate polynomial!");
  if ((Q->polynomial = (byte **) malloc( (Y_degree+1)*sizeof(byte *)))== NULL)
    Exit("Unable to allocate a bivariate polynomial!");
  for (i = 0; i <= Y_degree; i++)
    if ((Q->polynomial[i]=(byte *) malloc((max_X_degree+1)*sizeof(byte)))==NULL)
      Exit("Unable to allocate a bivariate polynomial!");
  
  return Q;
} /* end Allocate_BI_Poly */


/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*                                                                         *
*                          UTILITY FUNCTIONS                              *
*                                                                         *
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/

/**************************************************************************
*                                                                         *
*                   Function Exit(char *message)                          *
*                                                                         *
*-------------------------------------------------------------------------*
*                                                                         *
*   This function simply exits with the given message.                    *
*                                                                         *
**************************************************************************/
void Exit(char *message)
{
  fprintf(stderr,"** %s  Exiting...\n\n\n\n", message);
  exit(-1);
} /* end Exit */


/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*                                                                         *
*                      FACTORIZATION FUNCTIONS                            *
*                                                                         *
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*!
* \brief Initialization procedure for various constants relating to the root finding function. 
* 
*    This function sets up a number of constants relating to the finite    
*    field. In particular some global variables are allocated and         
*    intitialized.                                                        
* \author Ralf Koetter
* \param m  is the logarithm of the field size, 
*                        i.e. we are working in \f$GF(2^m)\f$
*/
void Init_Factorization (int m)
{
  int result, a, i, j;

  solve_quad_poly_a = (int *) malloc (m * sizeof (int));
  solve_quad_poly_b = (int *) malloc (m * sizeof (int));
  lm_a = (int *) malloc ((m + 1) * sizeof (int));
  lm_b = (int *) malloc ((m + 1) * sizeof (int));
  Error_Positions = malloc(Max_N_Errors*sizeof(byte));
  Error_Values = malloc(Max_N_Errors*sizeof(byte));

  /*theta_prime_ralf=(eType *) malloc (RS.n*sizeof(eType));*/
  result = 0;
  a = 0;
  for (i = 0; i < m; i++)
    {
      j = (1 << (m - i)); /* j has a single one in position m-i */
      a = 0;
      do
	{
	  a++;
	  result = GFsquare (a) ^ a; /*result is a^2 +a */
	}

/* this sets up the linear system of equations for quadratic polynomials */
      while (((j <= result) || ((j >> 1) > result)) 
	     && (a < (field_size - 1)));
      solve_quad_poly_a[i] = a;
      solve_quad_poly_b[i] = result;
      if ((j <= result) || ((j >> 1) > result))
	solve_quad_poly_a[i] = solve_quad_poly_b[i] = 0;
    };
	
  /* polynomial used for factorization */
  Factor_polynomial=(byte *) malloc((Max_Y_degree+1)*sizeof(byte));
  /* the derivative of the error locator */
  Derivative_of_locator=(byte *) malloc((Max_N_Errors)*sizeof(byte));
  roots_of_factor_polynomial=(byte *) malloc((Max_Y_degree)*sizeof(byte));
  mults_of_factor_polynomial=(byte *) malloc((Max_Y_degree)*sizeof(byte));
  error_locator=
    (byte *) malloc(( Max_N_Syndromes+Additional_Syndromes+1)*sizeof(byte));
  /* error evaluator out of BMA */
  error_evaluator=
    (byte *) malloc((Max_N_Syndromes+Additional_Syndromes+1)*sizeof(byte));
  BI_factor_Polynomials=Allocate_BI_factor_Poly_array 
    (Max_N_Syndromes+Additional_Syndromes, Max_Y_degree );
}
	
/*! 
 * \brief A function to shift a BI_factor_Poly_struct by alpha - this is one of the heart pieces of the code! 
 * 
 * All variable references are with respect to  BI_factor_Poly_struct 
 * This function takes a two-dimensional array \a polynomial[][] of dimensions \f$ x_{max} \times y_{degree}+1\f$
 * as input. The array is originally a bi-variate polynomial in \f$X\f$ and \f$Y\f$. If the array
 * \a polynomial[][] represents a polynomial \f$Q(X,Y)\f$ then the shift is done with respect to the polynomial
 * \f$ \frac{Q(X,Y(X^{y_{slope}})}{X^{x_{start}}}\f$. So actually realized is the shift
 * \f[
 * Q(X,Y)\leftarrow \frac{Q(X,(Y+alpha)(X^{y_{slope}})}{X^{x_{start}}}
 * \f]
 * This is achieved by addressing the elements in the array in 
 * along lines of slope \f$-y_{slope}\f$ starting at \f$X\f$ degree \f$x_{start}\f$.
 * The function also implements the equivalent of the the transformation \f$Q(X,Y)\leftarrow \frac{Q(X,YX)}{X^r}\f$ such that \f$ X\not|Q(X,Y)\f$.
 * THe output of this function is prepared for finding a new root of the factorization problem.
 *
 * The actual shift is realized as a fast transform that changes the basis 
 * of a polynomial from x to (x+alpha).  The transformation is its own inverse 
 * \author Ralf Koetter
 * \return void
 * \param alpha the field value by which we shift
 * \param *p is a pointer to a BI_factor_Poly_struct that we shift
 * \date October, 2002
 * \bug no bugs known
 */
void Shift_BI_factor_Poly(byte alpha, BI_factor_Poly_struct *p)
{		
  int ii,n;		
  byte beta;
  register int t,i,j,k,b;
	
  if (alpha!=0) /* alpha is the value by which we shift */
    {
      for (ii=p->x_start;ii<p->x_max;ii++)
	{beta=alpha;
	if (p->y_slope==0) n=p->y_degree;
	else  n=(ii/p->y_slope<p->y_degree)?ii/p->y_slope:p->y_degree; 
	/* n is the effective y-degree of the polynomials */
        for (j=0;(n>>j)!=0;j++)
	  {for (i=0;i<=n;i+=(2<<j))
	    for (k=0;k<(1<<j);k++) 
	      {t=i+k;
	      b=t+(1<<j);
	      if (b>n) break;
	      p->polynomial[t][ii-t*p->y_slope] ^= 
		GFmultQ(beta,p->polynomial[b][ii-b*p->y_slope]);
	      }
	  beta=GFsquare(beta);   
	  }		 
	}
    }

  p->y_slope++;
  beta=0; /* We clean up leading (skewed) zero rows by setting x_start */
  while(beta==0 && (p->x_start)<p->x_max )
    {p->x_start++; 
    n=(p->x_start/p->y_slope<p->y_degree)?p->x_start/p->y_slope:p->y_degree; 
    for (i=0;i<=n;i++) beta|=p->polynomial[i][p->x_start-i*p->y_slope];
    }
/* indicates that there is nothing more to be done */
  if (beta==0) p->x_start++; 
  
  /* end of the transformation code piece  */
}


/*! 
* \brief This function copies a factorization problem from another factorization problem.
*
* A simple function copying a  BI_factor_Poly_struct structure to a BI_factor_Poly_struct .
* The polynomial itself is stored up to x degree x_max.
* 
* \author Ralf Koetter
* \return void
* \param *Q Source structure
* \param *P Target structure
* \param x_max Maximal x degree necessary for out problem
* \date October, 2002
* \warning The degree of the polynomial must be smaller than the fieldsize
* \bug no bugs known
*/
void Copy_Factorization_Problem(BI_factor_Poly_struct *Q, BI_factor_Poly_struct *P,int x_max)
{
  register int i,j;

  P->x_max = x_max;
  P->x_start = Q->x_start;
  P->y_degree = Q->y_degree;
  P->y_slope = Q->y_slope;
  P->mult = Q->mult;
  for (i=0;i<=P->y_degree;i++)
    for (j=0;j<=x_max;j++) P->polynomial[i][j] =Q->polynomial[i][j];
  for (j=0;j<=Q->d;j++) P->S[j]=Q->S[j];
  P->d=Q->d;
}


/*! 
* \brief This function creates a factorization problem from a BI_Poly structure.
*
* A simple function copying a BI_Poly structure to a BI_factor_Poly_struct .
* The polynomial itself is stored up to x degree x_max from the point x_start on.
* x_start takes care of potential leading rows of zeros.
* mult is the multiplicity of the first found root that will be processed in this problem.
* \author Ralf Koetter
* \return void
* \param *Q Source structure
* \param *P Target structure
* \param x_max Maximal x degree necessary for out problem
* \param x_start Indicates the starting point of the essential paort of the Q polynomial
* \param mult The multiplicity of the root that is taken care of in this problem.
* \param S_0  The value of the root of \f$ Q(0,Y) \f$ that gives rise to this factorization problem.
* \date October, 2002
* \bug no bugs known
*/
void Create_Factorization_Problem_from_BI_Poly(BI_Poly *Q, BI_factor_Poly_struct *P, int x_max, int x_start,int mult, byte S_0)
{
  register int i,j;
  
  P->x_max = x_max;
  P->x_start = 0;
  P->y_degree = Q->Y_degree;
  P->y_slope = 0;
  P->mult = mult;
  for (i=0;i<=P->y_degree;i++)
    {   
      if (Q->X_degrees[i]>=(x_max+x_start)) 
	for (j=0;j<=x_max;j++) 
	  P->polynomial[i][j] =Q->polynomial[i][j+x_start];
      else 
	{
	  for (j=0;j<=Q->X_degrees[i]-x_start;j++) 
	    P->polynomial[i][j] =Q->polynomial[i][j+x_start];
	  for (j=Q->X_degrees[i]-x_start+1;j<=(x_max+x_start);j++) 
	    P->polynomial[i][j] = 0;
	}
    }
  P->d=0;
  P->S[0]=S_0;
}


/*!
* \brief A function for finding roots and their multiplicity of a polynomial. 
*
*  This function takes a univariate polynomial \f$f(X)\f$ and computes all its  
* roots in \f$GF(q)\f$. The roots are returned in the byte array \e roots[] that   
* is assumed to be already allocated allocated by the user. The           
* multiplicity of the roots is returned in \a mult[].  The multiplicity        
* is only computed up to multiplicity 12. The function actually implements a collection
* of sub-functions for different degrees. In particular, degrees \f$0,1,2,3,4,>4\f$ are treated 
* separately. Degrees 3 and 4 are handled using linearized polynomials which does not require any search.
* \author Ralf Koetter
* \return The actual number of found different roots - not counting multiplicity
* \param f  is the input polynomial
* \param roots  the roots are returned here
* \param mult the multiplicity of the roots is returned here
* \param n  the degree of \f$f\f$.
* \date October, 2002
* \bug no bugs known
*/
int Find_Roots (byte * f, int n, byte * roots, byte * mult)
{
  int no_roots;		/* counts the number of roots found */
  register int i, j;	/*looping variables */
  int b, a, flag, returnval;
  register byte alpha;
  byte beta, gamma, delta;	/* dummy variable */

  if (n == 0)
    return f[0] ? 0 : (-1);
  /*-1 signifies the all zero polynomial */
  else if (f[n] == 0)
    return Find_Roots (f, n - 1, roots, mult);	/*the degree is not really n */
  else if (f[0] == 0)
    {
      roots[0] = 0;
      mult[0] = 1;
      i = 0;
      while (f[++i] == 0)	mult[0]++;	/* find the multiplicity of the zero root */
      no_roots = Find_Roots (&f[i], n - i, &roots[1], &mult[1]);
      return ++no_roots;	/* the additional root is the zero root */
    }
  else			/* here we know that f[0]<>0 and f[n] <> 0; */
    {
      switch (n)
	{
	case 1:
	  roots[0] = GF_antiNeg[GF_log[f[0]] - GF_log[f[1]]];
	  mult[0] = 1;
	  return 1;
	  break;
	case 2:
	  {
	    if (f[1] == 0)	/* we have a single root of multiplicity 2 */
	      {
		b = GF_log[f[0]] - GF_log[f[2]];
		b = (b < 0) ? (b + field_size - 1) : b;	/* b is the exponent here */
		roots[0] = ((b & 1) ? GF_antilog[((b + field_size - 1) >> 1)] : GF_antilog[b >> 1]);	/*this emplements the square root   */
		mult[0] = 2;
		return 1;
		break;
	      }
	    else
	      {
		gamma = 0;
		beta = GFdivQ (GFmultQ (f[0], f[2]),
			       GFsquare (f[1]));
		alpha = GFdivQ (f[1], f[2]);
		for (i = 0; i < RS.m; i++)
		  if ((beta >> (RS.m - 1 - i)) & 1)
		    {
		      beta ^= solve_quad_poly_b[i];
		      gamma ^= solve_quad_poly_a[i];
		    }
	      }
	    if (beta == 0)
	      {
		mult[0] = mult[1] = 1;
		roots[0] = GFmultQ (gamma, alpha);
		roots[1] = GFmultQ (gamma ^ 1, alpha);
		return 2;
	      }
	    else
	      return 0;
	    break;
	  }
	case 3:
	  {
	    if (f[2] == 0)
	      beta = 0;
	    else
	      {
	/* both f[2] and f[3] are guaranteed non zero */
		beta = GFdivQ (f[2], f[3]);
		f[0] = f[0] ^ GFmultQ (f[1],beta) ^ 
		  GFmultQ (f[2],GFsquare(beta)) ^ 
		  GFmultQ (f[3],GFmultQ (GFsquare (beta),beta));
       /* Previous line evaluates polynomial at beta - hardcoded for speed */
		f[1] ^= GFmultQ (f[2], beta);
       /*f[1] after translating by beta */
       /* ... at this point the new polynomial has zero term f[2] */
		if (f[0] == 0)	/*we found a root by luck */
		  {
		    roots[0] = beta;
		    mult[0] = 1;
		    if (f[1] == 0)
		      {
			roots[0] = beta;
			mult[0] = 3;
			return 1;
			break;
		      }
		    /*b is in exponential form */
		    b = GF_log[GFdivQ (f[1], f[3])];
		    /*roots[1]=(beta+sqrt(f[1]/f[3])) */
		    roots[1] = beta ^ (((b & 1) ? GF_antilog[((b + field_size - 1) >> 1)] : GF_antilog[b >> 1]));
		    mult[1] = 2;
		    return 2;
		    break;
		  }
	      }
	    
	    /* Here we are in the situation that by shifting the 
	       polynomial by beta the term f[2] equals zero. Next 
	       the polynomial is thought to be multiplied with x 
	       to make it into a linearized polynomial 
	    */

	    for (i = 0; i < RS.m; i++)
	      {
		lm_b[i] = 0;
		lm_a[i] = GFmultQ (f[3],GFsquare(GFsquare(1<<i))) ^ GFmultQ (f[1],GFsquare(1<<i)) ^GFmultQ(f[0], (1<<i));

		/*lm_a[i] = GFmultExp (f[3],(i << 2)) ^ 
		  (f[1] ? GFmultExp (f[1],(i << 1)): 0) ^ GFmultExp (f[0], i);
		*/
	      }

	    for (j = 0; j < RS.m; j++)
	      for (i = 0; i < RS.m; i++)
		lm_b[i] ^= (((lm_a[j] >> (i)) & 1) << j);
	    /* The first row sets up the linear system of equations 
	       the second row transposes it 
	    */
	    /* First we use no_roots to record the non-pivots */
	    no_roots = 0;
	    a = 0;
	    for (i = 0; i < RS.m; i++)	/*Gaussian elimination starts */
	      {
		b = i - a;
		if (((lm_b[b] >> i) & 1) == 0)	/*pivot is not right */
		  {
		    j = lm_b[b++];
		    /* find the pivot */
		    while ((((lm_b[b] >> i) & 1) == 0) && (b < RS.m)) b++;
		    if (b < RS.m)
		      {
			lm_b[i - a] = lm_b[b];
			lm_b[b] = j;
		      }
		    else
		      {
			a++;
			roots[no_roots++] = i;
		      }
		  }
		
		if (b < RS.m)
		  {
		    for (j = b + 1; j < RS.m; j++)
		      if ((lm_b[j] >> i) & 1)
			lm_b[j] ^= lm_b[i - a];
		    for (j = i - a - 1; j >= 0; j--)
		      if ((lm_b[j] >> i) & 1)
			lm_b[j] ^= lm_b[i - a];
		  }
		
	      }	/* Gaussian Elimination ends */
	    
	    
	    alpha = gamma = 0;
	    switch (no_roots)
	      {
	      case 0:
		return 0;
		break;
	      case 1:
		for (i = 0; i < roots[0]; i++)
		  if ((lm_b[i] >> roots[0]) & 1)
		    alpha ^= (1 << i);
		roots[0] = (1 << roots[0]) ^ alpha ^ beta;
		mult[0] = 1;
		return 1;
		break;
	      case 2:
		for (i = 0; i < roots[0]; i++)
		  {
		    if ((lm_b[i] >> roots[0]) & 1)
		      alpha ^= (1 << i);
		    if ((lm_b[i] >> roots[1]) & 1)
		      gamma ^= (1 << i);
		  }
		for (i = roots[0]; i < roots[1]; i++)
		  {
		    if ((lm_b[i] >> roots[1]) & 1)
		      gamma ^= (1 << (i + 1));
		  }
		roots[0] = (1 << roots[0]) ^ alpha ^ beta;
		roots[1] = (1 << roots[1]) ^ gamma ^ beta;
		roots[2] = roots[0] ^ roots[1] ^ beta;
		mult[0] = mult[1] = mult[2] = 1;
		return 3;
		break;
	      default:
		Exit ("Something's fishy while solving a degree 3 polynomial");
	      }
	  }
	case 4:
	  {
	    /*flag=0 signals eventually a polynomial where 
	      f[3] equals 0; flag=1 means f[1] equals 0 
	    */
	    flag = 1;	
	    if (f[1] == 0)
	      {
		if (f[3] == 0)
		  {
		    if (f[2] == 0)	/*a zero of multiplicity four */
		      {
			b = GF_log[f[0]] - GF_log[f[4]];
			b = (b < 0) ? (b + field_size -1) : b;
			b = (b & 1) ? ((b + field_size - 1) >> 1) : (b >> 1);
			roots[0] = GFsqrtE (b);
			mult[0] = 4;
			return 1;
			break;
		      }
		    else	/* the square of a quadratic polynomial */
		      {
			f[0] = GFsqrtE (GF_log[f[0]]);
			f[1] = GFsqrtE (GF_log[f[2]]);
			f[2] = GFsqrtE (GF_log[f[4]]);
			b = Find_Roots (f, 2, roots, mult);
			mult[0] = 2;
			mult[1] = 2;
			return b;
			break;
		      }
		  }
		else	
		  /* the cases that f[3]<>0 and f[1]==0  -> no shifting 
		     necessary but still we have to reverse f 
		  */
		  {
		    beta = 0;
		    alpha = f[0];
		    f[0] = f[4];
		    /* must reverse polynomial so that it becomes affine */
		    f[4] = alpha;
		    f[1] = f[3];
		  }
	      }
	    else	/*the case that f[1]<>0; */
	      {

		/* must now shift polynomial to make f[1] zero */
		if (f[3] != 0)
		  {
		    beta = GFsqrtE (GF_log[GFdivQ(f[1], f[3])]);
		    f[0] = f[0] ^ GFmultQ (f[1],beta) ^GFmultQ (f[2],GFsquare (beta)) ^GFmultQ (f[3],GFmultQ (GFsquare(beta),beta)) ^GFmultQ (f[4],GFsquare (GFsquare(beta)));
		    f[2] = f[2] ^ GFmultQ (beta, f[3]);
		    if (f[0] == 0)
		      {
			f[1] = 0;
			b = Find_Roots (f, 4, roots, mult);
			for (i = 0; i < b; i++)
			  roots[i] ^= beta;
			return b;
			break;
		      }	
		    /* taking care of the case that beta happens to be a root */
		    alpha = f[0];
		    f[0] = f[4];
		    /* must reverse polynomial so that it becomes affine */
		    f[4] = alpha;
		    f[1] = f[3];
		    f[3] = 0;
		  }
		else	
		  /* f[3]=0 -- no need to shift the polynomial, but flag it */
		  {
		    beta = 0;
		    flag = 0;
		  }
	      }	
	    /* at this point we have a degree four polynomial 
	       with f[1]=0 */
	    
	    /* next we set up the linear system of equations */
	    for (i = 0; i < RS.m; i++)
	      {
		/* lm_a[i] = GFmultExp (f[4],(i << 2)) ^ (f[2] ? 
		   GFmultExp (f[2],(i<<1)): 0) ^GFmultExp (f[1], i);
		*/
		lm_a[i] = GFmultQ (f[4],GFsquare(GFsquare(1<<i))) ^ 
		  GFmultQ (f[2],GFsquare(1<<i)) ^GFmultQ(f[1], (1<<i));
	      }
	    lm_a[RS.m] = f[0];	/* this sets up the lin. system of equations */
	    for (j = 0; j < (RS.m + 1); j++)
	      {
		lm_b[j] = 0;
	      }
	    for (j = 0; j < (RS.m + 1); j++)
	      {
		for (i = 0; i < RS.m; i++)
		  lm_b[i] ^=(((lm_a[j] >> (i)) & 1) << j);
	      }
	    no_roots = 0;
	    a = 0;
	    /*Gaussian elimination starts */
	    for (i = 0; i < RS.m + 1; i++)
	      {
		b = i - a;
		if (((lm_b[b] >> i) & 1) == 0)	/*pivot is not right */
		  {
		    j = lm_b[b++];
		    while ((b < (RS.m + 1)) && (((lm_b[b] >> i) & 1) == 0))
		      b++;
		    if (b < (RS.m + 1))
		      {
			lm_b[i - a] = lm_b[b];
			lm_b[b] = j;
		      }
		    else
		      {
			a++;
			roots[no_roots++] = i;
		      }
		  }
		
		if (b < (RS.m + 1))
		  {
		    for (j = b + 1; j < (RS.m + 1); j++)
		      if ((lm_b[j] >> i) & 1)
			lm_b[j] ^=lm_b[i - a];
		    for (j = i - a - 1; j >= 0; j--)
		      if ((lm_b[j] >> i) & 1)
			lm_b[j] ^=lm_b[i - a];
		  }
		
	      }	/* Gaussian Elimination ends */
	    
	    if (no_roots == 0)
	      {
		return 0;
		break;
	      }
	    alpha = 0;
	    gamma = 0;
	    delta = 0;
	    if (roots[--no_roots] != RS.m)
	      {
		return 0;
		break;
	      }
	    else
	      {
		returnval = (1 << (no_roots));		
		switch (no_roots)
		  {
		  case 0:
		    {
		      for (i = 0; i < RS.m; i++)
			{
			  if ((lm_b[i] >> RS.m) & 1)
			    delta ^= (1 << i);
			}
		      roots[0] = delta;
		      mult[0] = 1;
		      break;
		    }
		  case 1:
		    {
		      for (i = 0; i < roots[0]; i++)
			{
			  if ((lm_b[i] >> roots[0]) & 1)
			    gamma ^= (1 << i);
			  if ((lm_b[i] >> RS.m) & 1)
			    delta ^= (1 << i);
			}
		      gamma ^= (1 << roots[0]);
		      for (i = roots[0]; i < (RS.m - 1); i++)
			{
			  if ((lm_b[i] >> RS.m) & 1)
			    delta ^= (1 <<
				      (i + 1));
			}
		      roots[1] = gamma ^ (roots[0] = delta);
		      mult[0] = mult[1] = 1;
		      break;
		    }
		  case 2:
		    {
		      for (i = 0; i < roots[0]; i++)
			{
			  if ((lm_b[i] >> roots[0]) & 1)
			    alpha ^= (1 << i);
			  if ((lm_b[i] >> roots[1]) & 1)
			    gamma ^= (1 << i);
			  if ((lm_b[i] >> RS.m) & 1)
			    delta ^= (1 << i);
			}
		      alpha ^= (1 << roots[0]);
		      for (i = roots[0]; i < (roots[1] - 1);i++)
			{
			  if ((lm_b[i] >> roots[1]) & 1)
			    gamma ^= (1 << (i + 1));
			  if ((lm_b[i] >> RS.m) & 1)
			    delta ^= (1 <<  (i + 1));
			}
		      gamma ^= (1 << roots[1]);
		      for (i = roots[1] - 1; i < (RS.m - 2);
			   i++)
			{
			  if ((lm_b[i] >> RS.m) & 1)
			    delta ^= (1 <<(i + 2));
			}
		      roots[3] = gamma ^ (roots[2] =alpha ^ 
				  (roots[1] =gamma ^ (roots[0] = delta)));
		      mult[0] = mult[1] = mult[2] =mult[3] = 1;
		      break;
		    }
		  default:
		    {
		      Exit ("Something's fishy while solving a degree 4 polynomial");
		      break;
		    }
		  }

		if (flag)
		  for (i = 0; i < returnval; i++)
		    roots[i] =GFexpN (-GF_log[roots[i]]);
		for (i = 0; i < returnval; i++)
		  roots[i] ^= beta;
		return returnval;
		break;
	      }
	  }
	  
	default:
	  {
	    no_roots = 0;

	    /*--- This is the general Chien type search ---*/
	    /*j is the exponent of the currently investigated field element */
	    for (j = 0; j < (field_size - 1); j++)
	      {
		alpha = 0;
		for (i = 0; i <= n; i++)
		  alpha ^= f[i];
		if (alpha == 0)
		  {
		    roots[no_roots] = GF_antilog[j];
		    mult[no_roots] = 1;
		    for (i = 0; i <= n; i += 2)
		      alpha ^= f[i];
		    if (alpha == 0)
		      {
			mult[no_roots]++;
			for (i = 1; i <= (n - 1);
			     i += 4)
			  alpha ^= f[i] ^ f[i + 1];
			if ((n % 4) == 1)
			  alpha ^= f[n];
			if (alpha == 0)
			  {
			    mult[no_roots]++;
			    for (i = 2; i <= n; i += 4)
			      alpha ^= f[i];
			    if (alpha == 0)
			      {
				mult[no_roots]++;
				for (i = 3;i <= n; i += 8)
				  for (a = 0; a < 4; a++)
				    if ((i + a) <= n)
				      alpha ^= f[i + a];
				if (alpha == 0)
				  {
				    mult[no_roots]++;
				    for (i  =  4; i <= n; i += 8)
				      for (a = 0; a < 4; a += 2)
					if ((i + a) <= n)
					  alpha ^= f[i + a];
				    if (alpha == 0)
				      {
					mult[no_roots]++;
					for (i = 5; i <= n; i += 8)
					  for (a = 0; a < 2; a++)
					    if ((i + a) <= n)
					      alpha ^= f[i + a];
					if (alpha == 0)
					  {
					    mult[no_roots]++;
					    for (i = 6; i <= n; i = i + 8)
					      alpha ^= f[i];
					    if (alpha == 0)
					      {
						mult[no_roots]++;
						for (i = 7; i <= n; i += 16)
						  for (a = 0; a < 8; a++)
						    if ((i + a) <= n)
						      alpha ^= f[i + a];
						if (alpha == 0)
						  {
						    mult[no_roots]++;
						    for (i = 8; i <= n; i += 16)
						      for (a = 0; a < 8; a += 2)
							if ((i + a) <= n)
							  alpha ^= f[i + a];
						    if (alpha == 0)
						      {
							mult[no_roots]++;
							for (i = 9; i <= n; i += 16)
							  for (a = 0; a < 2; a++)
							    for (b = 0; b < 8; b += 4)
							      if ((i + a + b) <= n)
								alpha ^= f[i + a + b];
							if (alpha == 0)
							  {
							    mult[no_roots]++;
							  }
						      }
						  }
					      }
					  }
				      }
				  }
			      }
			  }
		      }
		    no_roots++;
		  }
		for (i = 0; i <= n; i++)
		  {
		    if (f[i] != 0)
		      f[i] = GFmultExp (f[i], i);
		  }
	      }
	    return no_roots;
	    break;
	  }
	}
    }
  return -1;
} /* end Find_Roots */


/*!
* \brief A function for finding roots of an error locating polynomial. 
*
* This function takes a univariate polynomial \f$f(X)\f$ and computes the roots of its reciprocal polynomial 
* in a given range of  \f$GF(q)\f$, \f$ \alpha^{start}\ldots \alpha^{endd}\f$. 
* The roots are returned in the byte array \e roots[] that   
* is assumed to be already allocated allocated by the user.
* \author Ralf Koetter
* \return The actual number of found different roots - not counting multiplicity
* \param f  is the input polynomial
* \param roots  the roots are returned here
* \param deriv the first derivative of \f$ f\f$ evaluated at the roots.
* \param n  the degree of \f$f\f$.
* \warning This procedure is specific for this program and will most likely not work properly  in any other context. 
           Also an error will be generated if the degree of \f$f\f$ exceeds the size of the field.
* \date October, 2002
* \bug no bugs known - but the limits in the seach have to be adjusted for the final code!
*/
int Find_Roots_for_error_locator (byte * f, int n, byte * roots, byte * 
				  deriv)
{
  int no_roots=0;
  register int i,j;
  byte alpha;
  const int start=0;
  const int endd=field_size-1;
  {
    /* only important in deric computaton and taken care of there */
    for (i=0;i<n;i++) f[i]=GFdivQ(f[i],f[n]);f[n]=1; 
    for (j = start; j < endd; j++)    
      /*point_list[j] is  the currently investigated field element */
      {
	alpha = 0;
	for (i = 0; i <= n; i++) alpha ^= f[i];
	if (alpha == 0)
	  {roots[no_roots] = GF_antilog[j];
	  for (i = 1; i <= n; i+=2) alpha ^= f[i];
	  deriv[no_roots++] =GFdivQ(alpha,GF_antilog[j]);
	  }
	for (i = 1; i <= n; i++)
	  {
	    /* f[i] = GFmultExp (f[i], i % (field_size-1) );*/ 
	    /* Gets rid of the error but slows it down!*/
	    f[i] = GFmultExp (f[i], i );
	  }
      }
    return no_roots;
  }
  return -1;
} /* end Find_Roots_for_error_locator */


/*!
* \brief The main function for identifying factors of a bivariate polynomial. 
*
* This function takes a bivariate polynomial \f$Q(X,Y)\f$ as part of a BI_Poly structure 
* and computes a root of type \f$ Y-\frac{\lambda(X)}{\sigma(X)}\f$ where the polynomials 
* \f$ \lambda(X)\f$ and \f$\sigma(X)\f$ satisfy
* the following two properties:
* - \f$ \mbox{degree}(\lambda)<\mbox{degree}(\sigma)\f$
* - \f$ \mbox{gcd}(X^{q-1}-1, \sigma(X))=\sigma(X)\f$, where \f$ q\f$ is the size of the ambient field.
*
* The two arrays "Error_Positions" and "Error_Values" contain the roots of \f$ \sigma(X) \f$ and the values of the expression 
* \f$ \frac{ \lambda(X_i)}{\sigma'(X_i)}\f$ evaluated at the corresponding roots \f$ X_i \f$ of \f$ \sigma(X) \f$.
*
* If \f$Q(X,Y)\f$ does not contain such a factor the function Factor_BI_Poly() returns -1.
*
* \author Ralf Koetter
* \return The number of roots of \f$\sigma(X)\f$
* \param P the input BI_Poly
* \param Error_Positions  if P-polynomials[][] contains a factor \f$ \frac{ \lambda(X_i)}{\sigma'(X_i)}\f$, a list of roots of \f$\sigma(X)\f$
* \param Error_Values the values of the expression  \f$ \frac{ \lambda(X_i)}{\sigma'(X_i)}\f$ evaluated at the corresponding roots \f$ X_i \f$ of \f$ \sigma(X) \f$.
* \date December, 2002
* \bug no bugs known - tested for about \f$10^8\f$ random cases!
*/
int Factor_BI_Poly(BI_Poly * P, byte *Error_Positions, byte *Error_Values)
{
  byte alpha,beta;
  int bb,aa,a,n;
  register int nr,i,j;

  alpha=0;
  j=-1;

  /* no boundary check -> if the whole polynomial is zero we 
     will make an error */
  do {
    j++;for (i=0;i<=P->Y_degree;i++) 
    alpha |= Factor_polynomial[i]=P->polynomial[i][j];
  } while (alpha==0); 

  nr=Find_Roots(Factor_polynomial,P->Y_degree,roots_of_factor_polynomial,
		mults_of_factor_polynomial)-1;

  /* This sets up all factorization problems found the first time 
     we factor Q(0,Y) */
  for (i=0;i<=nr;i++) 
    {
      Create_Factorization_Problem_from_BI_Poly(P, BI_factor_Polynomials[i], 
	 Max_N_Syndromes+Additional_Syndromes,j,
	 mults_of_factor_polynomial[i],roots_of_factor_polynomial[i]);
      Shift_BI_factor_Poly(roots_of_factor_polynomial[i], 
	 BI_factor_Polynomials[i]);
    }	

  while (nr>=0)
    {
      while ((BI_factor_Polynomials[nr]->x_start <= 
	      Max_N_Syndromes+Additional_Syndromes))
	{
	  if (BI_factor_Polynomials[nr]->mult==1) 
	    {
	      Factor_polynomial[0]=
		BI_factor_Polynomials[nr]->polynomial[0][BI_factor_Polynomials[nr]->x_start];
	      Factor_polynomial[1]=BI_factor_Polynomials[nr]->polynomial[1][BI_factor_Polynomials[nr]->x_start-BI_factor_Polynomials[nr]->y_slope];
	      beta=GFdivQ(Factor_polynomial[0],Factor_polynomial[1]);
	      BI_factor_Polynomials[nr]->S[++BI_factor_Polynomials[nr]->d] = beta;
	      Shift_BI_factor_Poly(beta, BI_factor_Polynomials[nr]);
		}
	  else 
	    {   
	      n=MIN(BI_factor_Polynomials[nr]->x_start/BI_factor_Polynomials[nr]->y_slope,BI_factor_Polynomials[nr]->y_degree);
	      for (i=0;i<=n;i++)
		Factor_polynomial[i]=BI_factor_Polynomials[nr]->polynomial[i][BI_factor_Polynomials[nr]->x_start-i*BI_factor_Polynomials[nr]->y_slope];
	      a=Find_Roots(Factor_polynomial,n,roots_of_factor_polynomial,mults_of_factor_polynomial);
	      if (a>1)
		{
		  for (i=1;i<a;i++)
		    {
		      Copy_Factorization_Problem(BI_factor_Polynomials[nr], BI_factor_Polynomials[nr+i], Max_N_Syndromes+Additional_Syndromes);
		      BI_factor_Polynomials[nr+i]->S[++BI_factor_Polynomials[nr+i]->d] = roots_of_factor_polynomial[i];
		      BI_factor_Polynomials[nr+i]->mult = mults_of_factor_polynomial[i];
		      Shift_BI_factor_Poly(roots_of_factor_polynomial[i], BI_factor_Polynomials[nr+i]);
		    }
		  BI_factor_Polynomials[nr]->S[++BI_factor_Polynomials[nr]->d] = roots_of_factor_polynomial[0];
		  BI_factor_Polynomials[nr]->mult = mults_of_factor_polynomial[0];
		  Shift_BI_factor_Poly(roots_of_factor_polynomial[0], BI_factor_Polynomials[nr]);
		  nr+=a-1;
		}
	      else 	
		if (a==1)
		  {
		    BI_factor_Polynomials[nr]->S[++BI_factor_Polynomials[nr]->d] = roots_of_factor_polynomial[0];
		    BI_factor_Polynomials[nr]->mult = mults_of_factor_polynomial[0];
		    Shift_BI_factor_Poly(roots_of_factor_polynomial[0], BI_factor_Polynomials[nr]);
		  }
		else nr--;
	    }     
	  if (nr<0) break; 
	}

      /* Now we have to process the Syndrome */
      if (nr<0) break; 
      bb=BMA(BI_factor_Polynomials[nr]->S,error_locator,error_evaluator,BI_factor_Polynomials[nr]->d);
      if (bb<= Max_N_Errors)
	{      	 
	  aa=Find_Roots_for_error_locator(error_locator,bb,Error_Positions,Derivative_of_locator); 
	  if (aa==bb) 
	    { 
	      for (i=0;i<aa;i++)
		{
		  alpha=error_evaluator[bb-1];
		  for (j=bb-2;j>=0;j--) alpha=GFmultQ(alpha,Error_Positions[i])^error_evaluator[j];
		  Error_Values[i]=GFdivQ(1,GFmultQ(Error_Positions[i],GFmultQ(alpha,Derivative_of_locator[i])));
		  Error_Positions[i] = GFdivQ(1,Error_Positions[i]);
		}	
	      return aa;
	    }
	} /* syndrome processing complete */
      nr--;
    }	 
  return -1;
}


/*!  
* \brief A function to allocate memory for an array of  BI_factor_Poly_struct type variables
* 
* For an explanantion of the various fields see  BI_factor_Poly_struct. The various members are intitialized to their most natural values.
* \author Ralf Koetter
* \return A ponter to an array of type BI_factor_Poly_struct
* \param max_X_degree The maximal \f$X\f$ degree of the allocated polynomial
* \param Y_degree The maximal \f$Y\f$ degree of the allocated polynomial, Also the allocated array of BI_factor_Poly_struct variables is Y_degree+1 variables long.
* \date October, 2002
* \warning Seems to work - not extensively tested
* \bug no bugs known
*/
BI_factor_Poly_struct **Allocate_BI_factor_Poly_array (int max_X_degree, int Y_degree)
{
  BI_factor_Poly_struct **Q;
  int i,j;

  if ((Q = (BI_factor_Poly_struct **) malloc ((Y_degree + 1) * sizeof (BI_factor_Poly_struct *))) == NULL)
    Exit ("Unable to allocate a bivariate polynomial for factorization!");
  
  for (j=0;j<=Y_degree;j++) 
    {		
      if ((Q[j] = (BI_factor_Poly_struct *) malloc (sizeof (BI_factor_Poly_struct))) == NULL)
	Exit ("Unable to allocate a bivariate polynomial for factorization!");
      
      Q[j]->x_max = max_X_degree;
      Q[j]->x_start = 1;
      Q[j]->y_degree = Y_degree;
      Q[j]->y_slope = 0;
      Q[j]->mult = 1;
      
      if ((Q[j]->polynomial =
	   (byte **) malloc ((Y_degree + 1) * sizeof (byte *))) == NULL)
	Exit ("Unable to allocate a bivariate polynomial for factorization!");
      
      for (i = 0; i <= Y_degree; i++)
	if ((Q[j]->polynomial[i] =
	     (byte *) malloc ((max_X_degree + 1) * sizeof (byte))) ==
	    NULL)
	  Exit ("Unable to allocate a bivariate polynomial for factorization!");
      
      if ((Q[j]->S =
	   (byte *) malloc ((max_X_degree + 1) * sizeof (byte))) ==
	  NULL)
	Exit ("Unable to allocate a bivariate polynomial for factorization!");
      
      Q[j]->d = -1;
    }

  return Q;
  }  /* end Allocate_BI_factor_Poly_struct */


/*!  
* \brief A function to free allocated memory for an array of  BI_factor_Poly_struct type variables
* 
* For an explanantion of the various fields see  BI_factor_Poly_struct. 
* \author Ralf Koetter
* \param P pointer to an array of BI_factor_Poly structures that will be freed
* \param Y_degree The \f$Y\f$ degree of the BI_factor_Poly structures, also the length of the array P.
* \date November, 2002
* \bug no bugs known
*/
void Free_BI_factor_Poly_array (BI_factor_Poly_struct **P, int Y_degree)
{    
  int i,j;
  for (i = 0; i <= Y_degree; i++) 
    {
      for (j=0;j<=Y_degree;j++)  free(P[i]->polynomial[j]);
      free(P[i]->S);
      free(P[i]->polynomial);
      free(P[i]);}
  free(P);
}


/*!  
* \brief A function to free all allocated global memory.
*  
* \author Ralf Koetter
* \date December, 2002
* \bug no bugs known
*/
void The_home_of_the_free()
{    
  Free_BI_factor_Poly_array(BI_factor_Polynomials,Max_Y_degree);
  free(Factor_polynomial);
  free(Derivative_of_locator);
  free(roots_of_factor_polynomial);
  free(mults_of_factor_polynomial);
  free(error_locator);
  free(error_evaluator);
  free(lm_a);
  free(lm_b);
  free(solve_quad_poly_a);
  free(solve_quad_poly_b);
  free(GF_log);
  free(GF_antilog); 
  free(Zech_Table);
}


/*! 
* \brief A function to implement the BMA. 
* 
* This function takes a syndrome array as input  
* and produces polynomials \f$f\f$ and \f$g\f$ so that \f$S=g/f\ mod\ (x^d)\f$ where 
* \f$ d\f$ is                                                                    
* the length of the syndrome array. The return value is the degree of     
* the polynomial \f$ f \f$. All memory is assumed to be allocated.                                                                                       
* \author Ralf Koetter
* \return The degree of the polynomial f. If succesful this value is the number of errors.
* \param f is the error locator
* \param g is the scratch polynomial doubling as error evaluator 
* \param S is the syndrome sequence
* \param d is the length of the syndrome sequence \f$S_0\ldots S_{d-1}\f$
* \date October, 2002
* \bug no bugs known
* \warning The last two lines of code are badly tested
*/
int BMA (byte * S, byte * f, byte * g, int d)
{
  int L_f = 0;		/* the degree of the f polynomial */
  int L_g = -1;		/* the degree of the g polynomial */
  byte temp;
  byte Delta_f;		/* the discrepancy */
  byte Delta_g = 1;	/* old discrepancy */
  register int i,j;
  byte *temp_f;
  byte flag=0;
  register int aa=-1;          /* aa is the difference between a_g and a_f */
  
  /*Initialalization */
  for (i=0;i<d;i++) f[i]=g[i]=0;
  f[0] = 1;
  
  /* BMA procedure starts */	
  for (j=0;j<d;j++)
    {	Delta_f = 0;
    for (i = 0; i <= L_f; i++) Delta_f ^= GFmultQ (S[j-L_f + i], f[i]); /* We start with the discrepancy computation */
    if (Delta_f != 0) 		/* investigate the next row and shift the g polynomial one back */
      {if (aa < 0)				/* f and g change places so that f can be updated and g can be kept  f ->g */
	{flag=~flag;
	L_g=L_f;
	L_f-=aa;
	aa=-aa;
	temp_f = f;f = g;g = temp_f; temp=Delta_g; Delta_g = Delta_f;Delta_f=temp;
	} /* f and g have changed places */
      temp = GFdivQ(Delta_f, Delta_g);
      for (i = aa;i <= (L_g + aa); i++) f[i] ^= GFmultQ(g[i - aa], temp);
      }
    aa--;
    }
  /* BMA procedure ends */
  for (i=0;i<=L_g;i++) g[i]=GFdivQ(g[i],Delta_g);
  if (flag) {for (i=0;i<=L_f;i++) {temp=f[i];f[i]=g[i];g[i]=temp;}}
  return L_f;
}
