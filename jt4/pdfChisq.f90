real*4 function pdfChisq(y,n,s)

! Compute differential probability of measuring power y from a chi-squared
! distribution with n degrees of freedom.  Noise level is assumed normalized
! to 1.0; signal level is s.  (s=0 means a central chisq distribution; 
! nonzero s means a noncentral distribution.)

  real*8 bess,bessi,bessi0,bessi1,x8
  save a1,n0
  data n0/-99/

  if(n.ne.n0) then
     a1=-0.5*n*log(2.0) - gammln(0.5d0*n)
     n0=n
  endif

  if(s.eq.0.0) then
     p0log=a1 + (n/2-1)*log(y) -0.5*y
     pdfChisq=exp(max(p0log,-40.0))
  else
     x8=sqrt(y)*s
     bess=1.d0
     if(n/2-1.eq.0) bess=bessi0(x8)
     if(n/2-1.eq.1) bess=bessi1(x8)
     if(n/2-1.gt.1) bess=bessi(n/2-1,x8)
     p1log=-log(2.0) + 0.25*(n-2)*log(y/s**2) -0.5*(s**2+y) + log(bess)
     pdfChisq=exp(max(p1log,-40.0))
  endif

  return
end function pdfChisq
