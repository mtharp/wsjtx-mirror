/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*                                                                             *
*                        ACTUAL DECODER FUNCTIONS                             *
*                                                                             *
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/


/**************************************************************************
*                                                                         *
*            Function Position_Compare(nType *a, nType *b)                *
*                                                                         *
***************************************************************************
*                                                                         *
*    This is a utility function used in Display_Lists to sort positions   *
*  according to their reliability. It serves as the comparsion function   *
*  cmp for the qsort library function.                                    *
*                                                                         *
*  NOTE: qsort using Position_Compare will sort in descending order.      *
*                                                                         *
**************************************************************************/

int Position_Compare(nType *a, nType *b)
{
  if ( MR_probabilities[*a] > MR_probabilities[*b] ) return (-1);
  if ( MR_probabilities[*a] < MR_probabilities[*b] ) return (1);
  return(0);
}   /* end Position_Compare */


/******************************************************************************
*                                                                             *
*                        Function Precode ()                                  *
*                                                                             *
*******************************************************************************
*                                                                             *
*    This function implements Reed-Solomon encoding via division by the       *
* generator polynomial. It is used to pre-code from MR symbols.               *
*                                                                             *
******************************************************************************/

void Precode(void)
{
  nType j;

  /* The first (MSB) RS.k symbols are just the MR symols */
  for (j = RS.n-1; j >= RS.r; j--)
    pre_codeword[j] = MR_symbols[j];  
  for ( ; j >= 0; j--) pre_codeword[j] = 0;

  /* Now compute the remainder */
  Remainder_Poly(pre_codeword,RS.g,RS.n-1,RS.r);

} /* end Precode */


/******************************************************************************
*                                                                             *
*                       Function MultiplyX ()                                 *
*                                                                             *
*******************************************************************************
*                                                                             *
*   This function takes the output of Demodulate_2 and produces the           *
* ReEncode_List and the Interpolate_List. Multiplicities of second most       *
* reliable symbols in positions corresponding to the ReEncode_List are        *
* artificially set to zero.                                                   *
*                                                                             *
******************************************************************************/

void MultiplyX(void)
{
  nType  j;                   /* position in the codeword */
  mType  m, m2;               /* runs over multiplicities */
  mType  MR_multiplicities[RSN];  /* multiplicities of MR symbols */
  nType  Multiplicity_Count[MAXMP1];  /* holds multiplicity counts */
  mType  m2_threshold;        /* multiplcty threshold @ undecided positions */
  nType  m_sum;               /* used in determining multiplcty threshold */
  nType  N_threshold_points;  /* number of points needed at the m_threshold */
  nType  N2_threshold_points; /* number of points needed at m2_threshold */
  nType  r2;                  /* counts these points */
  I_POINT *Interpolate_Point;   /* points to Interpolate_List */
  R_POINT *ReEncode_Point;      /* points to ReEncode_List */
  nType *Interpolate_Position;  /* points to Interpolate_Positions */
  nType *ReEncode_Position;     /* points to ReEncode_Positions */
  nType *ReEncode_Value;        /* points to ReEncode_Values */
  nType  Undecided_positions[RSN];    /* positions of undecided points */
  mType  Undecided_multiplicity[RSN]; /* multiplicity of these points */
  nType *Undecided_Point;              /* points to Undecided_positions */
  nType  u;                            /* counts undecided positions */
  byte  symbol;                        /* MR_symbol[j] - pre_codeword[j] */
  int    cost;                         /* intermediate costs of MR symbols  */

  /* Initialize the multiplicity counts */  
  m = max_m_plus1;
  do Multiplicity_Count[--m] = 0; 
  while (m);

   /* Assign and count multiplicities of MR symbols */  

  j = RS.n;
  do{
    j--;
    MR_multiplicities[j] = m = FloorMult[MR_probabilities[j]];
    Multiplicity_Count[m]++;
  } while (j);

   /* Determine the multiplicity threshold */  
  m = max_m;
  m_sum = Multiplicity_Count[max_m];
  for ( ; m_sum < RS.k; ) 
    {
      m_sum += Multiplicity_Count[--m];
    }
  m_threshold = m;
  if (m_threshold == 0) 
    {
      for (j = 0; j < RS.n; j++)
	decoded_codeword[j] = MR_symbols[j];
      return;
    }
       /* 
          This means that we need to ReEncode through points with
          multiplicity 0, which happens if and only if there are more
          than RS.n - RS.k erasures. Note that an erasure can be 
          defined as a position j, such that MR_multiplicities[j] = 0
       */
           
  N_threshold_points = Multiplicity_Count[m] - (m_sum - RS.k);
       /* 
          This is the number of points we need on ReEncode_List, 
          whose multiplicity is exactly equal to m_threshold 
       */

   /* Compute the interpolation cost for MR symbols */  

  I_cost = 0;
  I_cost += (m_sum - RS.k)*m*(m+1);
  do{ 
    cost = m;
    cost *= (--m);
    I_cost += Multiplicity_Count[m]*cost;
  } while (m >= 2);

   /* Initialize the undecided list */  
  Undecided_Point = &Undecided_positions[0];
  m = max_m_plus1;
  do Multiplicity_Count[--m] = 0; 
  while (m);

   /* Initialize pointers and counters */  
  Interpolate_Point = &Interpolate_List[0];
  ReEncode_Point = &ReEncode_List[0];
  N_Erasures = 0;
  Interpolate_Position = &Interpolate_Positions[0];
  N_ReEncodes = 0;
  ReEncode_Position = &ReEncode_Positions[0];
  ReEncode_Value = &ReEncode_Values[0];

  /* Start building the ReEncode and Interpolate lists */  
  u = 0;
  j = RS.n;
  do{
    m = MR_multiplicities[--j];
    if (m) {
      if (m < m_threshold)
	{
          /* Put two points on the Interpolate_List */
	  Interpolate_Point->Px = GFexpQ(j);      
	  Interpolate_Point->m = m;
	  Interpolate_Point->j = j;
	  *Interpolate_Position++ = j;
	  m2 = FloorMult[MR2_probabilities[j]];
	  if (m2)
	    {
	      Interpolate_Point->second = 1;
	      Interpolate_Point++->m2 = m2;
	      I_cost += m2*(m2+1);
	    }
	  else
	    {
              Interpolate_Point++->second = 0;
	    }
	}
      else if (m == m_threshold)
	{
          /* Put the point on the undecided list, in the meantime */
	  *Undecided_Point++ = j; 
	  Undecided_multiplicity[u++] = m2 = FloorMult[MR2_probabilities[j]];
	  Multiplicity_Count[m2]++;
	}
      else /* if (m > m_threshold) */
	{
          /* Put the point on the ReEncode_List */  
	  ReEncode_Point->m = m;
	  ReEncode_Point++->j = j;
	  if (j < RS.r) 
	    {
	      symbol = MR_symbols[j] ^ pre_codeword[j];
	      if (symbol)
		{
		  *ReEncode_Position++ = j;
		  *ReEncode_Value++ = GF_log[symbol] + RS.Psi_exp[j];
		  N_ReEncodes++;
		}
	    }
	}
    } /* end if (m) */
    else 
      {
	Erasure_Positions[N_Erasures] = j;
	N_Erasures++;
      }
  } while (j);
  
   /* Determine the multiplicity threshold for undecided positions */  
  m2_threshold = 0;
  m_sum = Multiplicity_Count[0];
  for ( ; m_sum < N_threshold_points; ) 
    m_sum += Multiplicity_Count[++m2_threshold];
  N2_threshold_points = 
    N_threshold_points - (m_sum - Multiplicity_Count[m2_threshold]);
  /* this is the number of undecided points we need on ReEncode
     List, whose MR2 multiplicity is exactly m2_threshold */
  /* Decide undecided points and complete the ReEncode/Interpolate lists */
  r2 = 0;
  do{
    m = Undecided_multiplicity[--u];
    j = *--Undecided_Point; 
    if (m < m2_threshold)
      {
	/* Put one point on the ReEncode_List */  
	ReEncode_Point->m = m_threshold;
	ReEncode_Point++->j = j;
	if (j < RS.r) 
	  {
	    symbol = MR_symbols[j] ^ pre_codeword[j];
	    if (symbol)
	      {
		*ReEncode_Position++ = j;
		*ReEncode_Value++ = GF_log[symbol] + RS.Psi_exp[j];
		N_ReEncodes++;
	      }
	  }
      }
    else if ( (m > m2_threshold) || (r2 >= N2_threshold_points) )
      {
	/* Put two points on the Interpolate_List */
	Interpolate_Point->Px = GFexpQ(j); 
	Interpolate_Point->m = m_threshold;
	Interpolate_Point->j = j;
	*Interpolate_Position++ = j;
	if (m)
	  {
	    Interpolate_Point->second = 1;
	    Interpolate_Point++->m2 = m;
	    I_cost += m*(m+1);
	  }
	else
          {
	    Interpolate_Point++->second = 0;
          }
      }
    else /* here ( (m == m2_threshold) && (r2 < N2_threshold_points) ) */
      {
	/* Put one point on the ReEncode_List */  
	ReEncode_Point->m = m_threshold;
	ReEncode_Point++->j = j;
	if (j < RS.r) 
	  {
	    symbol = MR_symbols[j] ^ pre_codeword[j];
	    if (symbol)
	      {
		*ReEncode_Position++ = j;
		*ReEncode_Value++ = GF_log[symbol] + RS.Psi_exp[j];
		N_ReEncodes++;
	      }
	  }
	r2++;
      }
  } while (u);

  /* Complete the computation of some values */  
  N_Interpolates = RS.r - N_Erasures;
  I_cost /= 2;
} /* end MultiplyX */


/******************************************************************************
*                                                                             *
*                       Function Predict()                                    *
*                                                                             *
*******************************************************************************
*                                                                             *
*   This function tries to predict whether algeabriac soft decoding will be   *
* succesfull, based on the assigned multiplicities and input probabilities.   *
* This is done by comparing the distance from expected score to Delta[cost],  *
* normalized by the standard deviation of the score, to a threshold.          *
*                                                                             *
******************************************************************************/
float Predict(void)
{
  long int cost;               /* total cost of assigned multiplctys  */
  long int score;              /* the expected score (quantized) */
  long int score_variance;     /* variance of the expected score  */ 
  /*
    This assumes that quantization_M * RS.n * max_m * max_m
    fits in a long integer. For normal parameters, this product
    is usually between 2^16 and 2^26, so "long int" is needed.
  */
  nType loop_counter;          /* controls interpolation/re-encoding loops  */
  I_POINT *Interpolate_Point;  /* points to the Interpolate_List      */
  R_POINT *ReEncode_Point;     /* points to the ReEncode_List         */
  nType j;                     /* position of the current Point     */
  register mType m, m2;        /* multiplicities of the current Point */
  register int tmp;            /* auxiliary, used in score computations */
  register int tmp2;           /* auxiliary, used in score computations */
  register int aux;            /* auxiliary, used in score computations */
  float x;                     /* Erf(x) = estimated probability of success */

   /*------- Compute the cost, the expected score, and its variance ------*/
   /* Initialize pointers and counters */  
  Interpolate_Point = &Interpolate_List[0];
  ReEncode_Point = &ReEncode_List[0];
  cost = score = score_variance = 0;

      /* Go thru the ReEncode list */
  loop_counter = RS.k;
  do{
    m = ReEncode_Point->m;
    cost += m * (m+1);
    score += tmp = m * MR_probabilities[ReEncode_Point->j];
    score_variance += ( (m<<quantization_bits) - tmp) * tmp;
    ReEncode_Point++;
    loop_counter--;
  } while (loop_counter);

  /* Go thru the Interpolate list */
  loop_counter = N_Interpolates;
  do{
    m = Interpolate_Point->m;
    j = Interpolate_Point->j;
    tmp =  m * MR_probabilities[j];
    if (Interpolate_Point->second)
      {
	m2 = Interpolate_Point->m2;
	tmp2 = m2 * MR2_probabilities[j];
	score += aux = tmp + tmp2;
	score_variance += ( (tmp*m + tmp2*m2)<<quantization_bits ) - aux * aux;
      }
    else
      {
	score += tmp;
	score_variance += ( (m<<quantization_bits) - tmp) * tmp;
      }
    Interpolate_Point++;
    loop_counter--;
  } while (loop_counter);

  cost >>= 1;
  cost += I_cost;

   /*------- Compute normalized (socre - Delta[cost]) and predict --------*/
  x = ( (float) (score - (Delta[cost]<<quantization_bits) ) )
    / ( (float) sqrt(score_variance) );
  return(x);
} /* end Predict */


/******************************************************************************
*                                                                             *
*                        Function ReEncode ()                                 *
*                                                                             *
*******************************************************************************
*                                                                             *
*   This function computes a codeword (in the evaluation code) that coincides *
* with the values on ReEncode_List[]->Py in the ReEncode_List[]->j positions. *
* The actual computation uses the ReEncode_Values[] which take into account   *
* pre-coding from the last RS.k symbols. The Py values on Interpolate_List    *
* are then updated accordingly.                                               *
*                                                                             *
******************************************************************************/
void ReEncode(void)
{
  I_POINT *Interpolate_Point;    /* points to Interpolate_List             */
  R_POINT *ReEncode_Point;       /* points to ReEncode_List                */
  eType delta[RSK];      /* adjusted exponents for re-encoding positions  */
  eType *delta_ptr;       /* pointer to delta[RS.k] */
  nType reEncode_counter; /* runs over the nonzero re-encoding positions   */
  nType loop_counter;     /* runs over interpolation/re-encoding positions */
  nType i;                /* the current interpolation position            */
  nType j;                /* runs over various positions                   */
  byte  c_i;              /* the computed codeword symbol/Theta(\alpha^i)  */
  int denominator;    /* denominator exponent in \delta_i, \Theta(alpha^i) */
  eType exponent;     /* overall exponent in \delta_i and \Theta(\alpha^i) */

   /*----- Compute the \delta_i values for the re-encoding positions ----*/
     /*
        The values $\delta_i$ are defined for the re-encoding positions as:
        $$
          \delta_i = { \gamma_i \over \Theta'(\alpha^{j_i}) \alpha^{j_i} }
        $$
        where j_i is re-encoding position, $\gamma_i = ReEncode_Point->Py$
        is the value to be re-encoded through (adjusted for the evaluation
        code), and $\Theta'(X)$ is the derivative of auxiliary polynomial
        $\Theta(X)$ described below. The method for the computation of the
        values of $\Theta'(X)$ is very similar to the method used below to 
        compute the values of $\Theta(X)$.
     */
  if ((loop_counter = N_ReEncodes))
    {
      delta_ptr = &delta[0]; 
      do{
	i = ReEncode_Positions[--loop_counter];
	/* this is the current re-encoding position */
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

	/* Compute the overall exponent and store it */
	if ( (exponent = ( denominator + ReEncode_Values[loop_counter] 
			   - i*RS.k - RS.Zech[i] ) % group_size) < 0 )
	  exponent += group_size;
	*delta_ptr++ = exponent;
      } while (loop_counter);

    } /* end if ((loop_counter = N_ReEncodes)) */

   /*------ Compute \Theta(\alpha^i) for the interpolation positions ----*/
     /*
        The $\Theta(X)$ auxiliary polynomial is given by:
        $$
          \Theta(X) = \prod_{r=1}^{RS.k} (X - \alpha^{j_r})
        $$
        where the product is over the re-encoding positions $j_1,...,j_k$.
        Herein, we compute the values $\Theta(\alpha^i)$ for interpolation
        positions, as follows:
        $$
          \Theta(\alpha^i) = \prod_{r=1}^{RS.k} (\alpha^i + \alpha^{j_r})
             = (\alpha^i)^{RS.k} \prod_{r=1}^{RS.k} (1 + \alpha^{j_r - i})
             = \alpha^{i*RS.k} { \prod_{j=1}^{RS.n} (1 + \alpha^{j - i})
                 \over \prod_{s=1}^{RS.n-RS.k} (1 + \alpha^{j_s - i}) }
        $$
        where the last product in the denominator is over the complement of
        the set of the re-encoding positions in the set of code positions.
        Since we only need the exponent of $\Theta(\alpha^i)$, it can be
        computed as $i*RS.k + RS.Zech[i] - denominator$ in what follows.
     */

  Interpolate_Point = &Interpolate_List[0];
  loop_counter = N_Interpolates;
  do{
    i = Interpolate_Point->j; /* that's the current interpolation position */
    /* Compute the exponent of the denominator */
    denominator = RS.Psi_exp[i];  /* this compensates for ->Py later */
    if (N_Erasures)
      {
        j = N_Erasures;
        do denominator += Zech[Erasure_Positions[--j]-i]; 
        while (j);
      }
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
    /* 
       This correction is needed because the C 
       % operator may return a negative value
    */ 
    
    /*------- Compute the codeword and update the Interpolate_List -------*/
    c_i = 0;
    if ((reEncode_counter = N_ReEncodes))
      {
	delta_ptr = &delta[0];
	/* This loop computes the codeword, up to factor of \Theta(\al^i) */
	do{
	  c_i ^= GFexpN(*delta_ptr++ - Zech[i-ReEncode_Positions[--reEncode_counter]]);
	} while (reEncode_counter);
      } /* end if ((reEncode_counter = N_ReEncodes)) */

     /* This updates the Interpolate_List */
    if (i >= RS.r)
      {
	Interpolate_Point->Py = c_i; 
	if (Interpolate_Point->second)
	  Interpolate_Point->Py2 = 
	    GFexpN(GF_log[(MR2_symbols[i] ^ MR_symbols[i])] - exponent) ^ c_i; 
	if ( (exponent += RS.Psi_exp[i]) >= group_size) exponent -= group_size;
	shift_codeword[i] = GFmultExp(MR_symbols[i],RS.Psi_exp[i]) 
	  ^ GFmultExp(c_i,exponent); 
      }
    else
      {
	Interpolate_Point->Py = 
	  GFexpN(GF_log[(MR_symbols[i] ^ pre_codeword[i])] - exponent) ^ c_i;
	if (Interpolate_Point->second)
	  Interpolate_Point->Py2 = 
	    GFexpN(GF_log[(MR2_symbols[i]^pre_codeword[i])] - exponent) ^ c_i;
	if ( (exponent += RS.Psi_exp[i]) >= group_size) 
	  exponent -= group_size;
	shift_codeword[i] = GFmultExp(pre_codeword[i],RS.Psi_exp[i]) 
          ^ GFmultExp(c_i,exponent);
      }
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
	if ( (exponent=(RS.k*i + RS.Zech[i] - denominator) % group_size) < 0 )
	  exponent += group_size;

	/* Compute the codeword */
	c_i = 0;
	if ((reEncode_counter = N_ReEncodes))
	  {
	    delta_ptr = &delta[0];
	    do{
	      c_i ^= GFexpN(*delta_ptr++ - 
		     Zech[i-ReEncode_Positions[--reEncode_counter]]); 
	    } while (reEncode_counter);
	  } /* end if ((reEncode_counter = N_ReEncodes)) */
	if (i >= RS.r)
	  shift_codeword[i] = GFmultExp(MR_symbols[i],RS.Psi_exp[i]) 
              ^ GFmultExp(c_i,exponent); 
	else
	  shift_codeword[i] = GFmultExp(pre_codeword[i],RS.Psi_exp[i]) 
              ^ GFmultExp(c_i,exponent);
      } while (loop_counter);
    } /* end if (N_Erasures) */

  /*-------- Complete the shift_codeword with ReEncode positions  ------*/

  loop_counter = RS.k;
  ReEncode_Point = &ReEncode_List[0];
  do{
    j = ReEncode_Point->j;  
    shift_codeword[j] = GFmult(MR_symbols[j],RS.Psi[j]); 
    ReEncode_Point++;
    loop_counter--;
  } while (loop_counter);

} /* end ReEncode */


/******************************************************************************
*                                                                             *
*                      Function Set_Groebner ()                               *
*                                                                             *
*******************************************************************************
*                                                                             *
*   This function initializes the Groebner basis for interpolation, using the *
* information in ReEncode_List. It computes exactly how many bases are needed *
* for a given I_cost. It also computes tail g(X) polynomials for bases with   *
* a high Y-degree, if needed (i.e. if the multiplicities on the ReEncode_List *
* are not all the same).                                                      *
*                                                                             *
******************************************************************************/
void Set_Groebner(void)
{
  mType Z_degrees[MAXYDP2];      /* Y-degrees of Groebner polynomials   */
  mType k;                       /* index of weighted[] and Z-degrees[] */
  /* The +2 above is a safety margin, +1 is needed */
  int   weighted_degree;         /* weighted-degree in the computation     */
  int   next_weighted_degree;    /* weighted-degree beyond m_threshold     */
  int   N_coefficients = 0;      /* total number of coefficients in Q(X,Y) */
  int   previous_N_coefficients; /* store previous value of N_coefficients */
  mType m;                       /* runs over multiplicities and Z-degrees */
  mType Z_degree;                /* current Z-degree (beyond m_threshold)  */
  nType r;                          /* runs over ReEncode_List in counting */
  nType g_degrees[MAXMP1];       /* degrees of auxiliary polynomials    */
  nType g_positions[MAXMP1][RSK]; /* positions for aux polynomials   */
  byte  *g_polynomials[MAXMP1];  /* auxiliary polynomials themselves  */
  nType g_degree;                   /* degree of the tail polynomial       */
  byte  *g;                         /* the overall tail polynomial         */
  byte  *aux_poly;                  /* points to g_polynomials[m], etc.    */
  byte  *aux1_poly;                 /* pointer used in case2 of the switch */
  nType aux_degree;                 /* degree of aux_poly, etc.            */
  nType *positions;                 /* points to g_positions[m]            */
  nType j, alpha;                   /* used in computation of polynomials  */
  BI_Poly       *Q;                 /* pointer to Groebner[k]              */
  int           *Q_degrees;         /* pointer to X_degrees in Groebner[k] */
  byte          *Q_poly;            /* points to polynomial of Groebner[k] */
  register int   x;                 /* indexes polynomials of Groebner[k]  */
  register mType y;                 /* indexes polynomials of Groebner[k]  */

   /*------------- Count the g_degrees from ReEncode_List ---------------*/ 
  m = max_m_plus1;
  do g_degrees[--m] = 0;
  while (m);

  r = RS.k;
  do{
    m = ReEncode_List[--r].m;
    g_positions[m][g_degrees[m]] = ReEncode_List[r].j;
    g_degrees[m]++;
  } while (r);

   /*--- Process bases beyond m_threshold with negative (-1,+1)-degree --*/  
  Z_degree = m_threshold+1;
  next_weighted_degree = g_degrees[m_threshold] - Z_degree;
  weighted_degree = -m_threshold;
  k = 0;

  for ( ; next_weighted_degree < 0; ) 
    {
      N_coefficients -= next_weighted_degree;
      /* Update for simple bases */
      for ( ; weighted_degree <= next_weighted_degree; weighted_degree++) 
	{
	  weighted_degrees[k] = weighted_degree;
	  Z_degrees[k] = -weighted_degree;
	  k++;
	}
      /* Update for the base beyond m_threshold */
      weighted_degrees[k] = next_weighted_degree;
      Z_degrees[k] = Z_degree;
      k++;
      /* Compute the next Z_degree and next weighted_degree */
      Z_degree++;
      if (Z_degree >= max_m_plus1) next_weighted_degree += RS.k;
      else
	{
	  for (m = m_threshold; m < Z_degree; m++)
	    /* these are all the extra g(X)*/ 
	    next_weighted_degree += g_degrees[m];
	}
      next_weighted_degree--;   /* this corresponds to increasing Z_degree */
    } /* for ( ; next_weighted_degree < 0; ) */

  /*---------- Now the next weighted_degree is nonnegative -------------*/  
  /* Update for the remaining simple bases */
  for ( ; weighted_degree <= 0; weighted_degree++) 
    {
      weighted_degrees[k] = weighted_degree;
      Z_degrees[k] = -weighted_degree;
      k++;
    }
  weighted_degree = 0;

  /* Compute the initial value of N_coefficients */  
  N_coefficients += (m_threshold*(m_threshold+1))/2;
  previous_N_coefficients = N_coefficients;
  N_coefficients += k*(next_weighted_degree+1);

     /* Process the remaining bases beyond m_threshold */  
  for ( ; N_coefficients <= I_cost; ) 
    {
      /* Update for the base beyond m_threshold */
      weighted_degrees[k] = next_weighted_degree;
      Z_degrees[k] = Z_degree;
      k++;
         /* Compute the next Z_degree and next weighted_degree */
      Z_degree++;
      weighted_degree = next_weighted_degree;
      if (Z_degree >= max_m_plus1) next_weighted_degree += RS.k;
      else
	{
	  for (m = m_threshold; m < Z_degree; m++) 
	    next_weighted_degree += g_degrees[m];  
	  /* these are all the extra g(X) tails */
	}
      next_weighted_degree--;   /* this corresponds to increasing Z_degree */

         /* Update the number of coefficients */
      previous_N_coefficients = N_coefficients;
      N_coefficients += k*(next_weighted_degree - weighted_degree) + 1;
      /* +1 is for the extra point at the same weighted-degree */
    } /* end for ( ; N_coefficients <= I_cost; ) */

   /*---------------- Initialize the Groebner basis ---------------------*/  
  max_Y_degree = Z_degree-1;
  max_weighted_degree = (I_cost-previous_N_coefficients-1)/k+1 
                         + weighted_degree;
  /*
    What we need to compute is \ceiling{x/k} + weighted_degree,
    where x = I_cost - previous_N_coefficients. In the above,
    we use the fact that \ceiling{x/k} = \floor{(x-1)/k} + 1.
  */
  max_X_degree = max_weighted_degree + max_Y_degree; 
  /* 
     To conserve memory (by loosing some speed),
     we could allocate the Groebner bases here.
  */
  
  /* Initialize the tail polynomial g(X) */
  if (max_Y_degree > m_threshold+2)
    {
      g = Alloc_Byte_Vector(weighted_degrees[max_Y_degree]+max_Y_degree+1);
      g[0] = 1; g_degree = 0;
    }
 
  /*-------------- Set the simple bases ----------------*/
  for (k = 0; k <= max_Y_degree; k++) 
    {
      Z_degree = Z_degrees[k];
      Q = Groebner[k];
      Q->Y_degree = Z_degree;
      Q->weighted_degree = weighted_degrees[k];
      if (Z_degree <= m_threshold)  /* Q(X,Y) is a simple basis */
	{
	  Q->max_X_degree = 0;
	  Q_degrees = Q->X_degrees;
	  y = max_Y_degree+1;
	  do Q_degrees[--y] = -1; while (y);
	  Q_degrees[Z_degree] = 0;
	  y = max_Y_degree+1;
	  do{
	    Q_poly = Q->polynomial[--y];
	    x = max_X_degree+1;
	    do Q_poly[--x] = 0; while (x);
	  } while (y);
	  Q->polynomial[Z_degree][0] = 1;
	} /* end if (Z_degree <= m_threshold) */
      else {   
	/*---- Here Z_degree > m_threshold, and Q(X,Y) has a g(X) tail ----*/
	/* Initialize the bivariate polynomial to zeros */
	Q_degrees = Q->X_degrees;
	y = max_Y_degree+1;
	do Q_degrees[--y] = -1; while (y);
	y = max_Y_degree+1;
	do{
	  Q_poly = Q->polynomial[--y];
	  x = max_X_degree+1;
	  do Q_poly[--x] = 0; while (x);
	} while (y);

	switch(max_Y_degree - m_threshold)
	  {

	    /* ------------------------------------------------------------ */
	  case 1:
	    /* ------------------------------------------------------------ */
	    /* Compute directly the Q->polynomial[Z_degree] */
	    aux_poly = Q->polynomial[Z_degree];
	    positions = g_positions[m_threshold];
	    aux_poly[0] = 1;
	    aux_degree = 0;
	    for ( ; aux_degree < g_degrees[m_threshold]; aux_degree++)
	      {
		alpha = positions[aux_degree];
		aux_poly[aux_degree+1] = 1;
		for (j = aux_degree; j; j--)
		  aux_poly[j] = GFmultExp(aux_poly[j],alpha) ^ aux_poly[j-1];
		aux_poly[0] = GFmultExp(aux_poly[0],alpha);
	      } 
	    Q->max_X_degree = Q_degrees[Z_degree] = g_degrees[m_threshold];    
	    break;
	    
	    /* ------------------------------------------------------------ */
	  default:
	    /* ------------------------------------------------------------ */
	    if (Z_degree <= max_m_plus1) 
	      {
                /* Compute the auxiliary polynomial g_{Z_degree-1}(X) */
		m = Z_degree-1;
		aux_poly = g_polynomials[m]=Alloc_Byte_Vector(g_degrees[m]+1);
		positions = g_positions[m];
		aux_poly[0] = 1;
		for (aux_degree = 0; aux_degree < g_degrees[m]; aux_degree++)
		  {
		    alpha = positions[aux_degree];
		    aux_poly[aux_degree+1] = 1;
		    for (j = aux_degree; j; j--)
		      aux_poly[j] = GFmultExp(aux_poly[j],alpha) 
                                    ^ aux_poly[j-1];
		    aux_poly[0] = GFmultExp(aux_poly[0],alpha);
		  } 

                 /* Compute the tail polynomial */
		for (m = m_threshold; m < Z_degree; m++) 
		  {
		    Multiply_Poly(g,g_polynomials[m],g_degree,g_degrees[m]);  
		    g_degree += g_degrees[m];
		  }
	      }  /* end  if (Z_degree <= max_m_plus1) */
	    else
	      {
		/* Compute the tail polynomial */
                for (m = m_threshold; m < max_m_plus1; m++) 
		  {
		    Multiply_Poly(g,g_polynomials[m],g_degree,g_degrees[m]);  
		    g_degree += g_degrees[m];
		  }
	      }

	    /* Finally, copy into the basis polynomial */
	    Q->max_X_degree = Q_degrees[Z_degree] = g_degree;
	    Q_poly = Q->polynomial[Z_degree];
	    x = g_degree+1;
	    do{
	      x--;
	      Q_poly[x] = g[x]; 
	    } while (x);

	    /* ------------------------------------------------------------ */
	  }  /* end switch(max_Y_degree - m_threshold) */

      }  /* end else {  (Z_degree > m_threshold) }   */
    } /* end for (k = 0; k <= max_Y_degree; k++) */

  /*--------------------- Free allocated memory ------------------------*/  
  if (max_Y_degree > m_threshold+1)
    {
      for (Z_degree = m_threshold; 
	   Z_degree < MIN(max_Y_degree,max_m_plus1); Z_degree++)
	free(g_polynomials[Z_degree]);
      free(g);
    }

   /*----------------------- Set the Sorter[] array ----------------------*/  
  for (k = 0; k <= max_Y_degree; k++) 
    Sorter[k] = k;

} /* end Set_Groebner */
