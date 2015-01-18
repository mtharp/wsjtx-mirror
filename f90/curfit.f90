! subroutine curfit

! Source: Bevington, pages 237-239.

! Purpose
!   Make a least-squares fit to a non-linear function
!      with a linearization of the fitting function
 
! Ssage
!   call curfit (x, y, sigmay, npts, nterms, mode, a, deltaa,
!      sigmaa, flamda, yfit, chisqr)
 
! Description of parameters
!   x	   - array of data points for independent variable
!   y	   - array of data points for dependent variable
!   sigmay - array of standard deviations for y data points
!   npts   - number of pairs of data points
!   nterms - number of parameters
!   mode   - determines method of weighting least-squares fit
!	     +1 (instrumental) weight(i) = 1./sigmay(i)**2
!	      0 (no weighting) weight(i) = 1.
!	     -1 (statistical)  weight(i) = 1./y(i)
!   a	   - array of parameters
!   deltaa - array of increments for parameters a
!   sigmaa - array of standard deviations for parameters a
!   flamda - proportion of gradient search included
!   yfit   - array of calculated values of y
!   chisqr - reduced chi square for fit
 
! Subroutines and function subprograms required
!   functn (x, i, a)
!      evaluates the fitting function for the ith term
!   fchisq (y, sigmay, npts, nfree, mode, yfit)
!      evaluates reduced chi squared for fit to data
!   fderiv (x, i, a, deltaa, nterms, deriv)
!      evaluates the derivatives of the fitting function
!      for the ith term with respect to each parameter
!   matinv (array, nterms, det)
!      inverts a symmetric two-dimensional matrix of degree nterms
!      and calculates its determinant
 
! Comments
!   Dimension statement valid for nterms up to 10
!   Set flamda = 0.001 at beginning of search

subroutine curfit (x, y, sigmay, npts, nterms, mode, a, deltaa,           &
     sigmaa, flamda, yfit, chisqr)

  implicit real (8) (a - h, o - z)
  parameter (npmax=100,ntmax=10)
  double precision array
  dimension x (npmax), y (npmax), sigmay (npmax), a (5), deltaa (5),      &
       sigmaa (5), yfit (npmax)
  dimension weight (npmax), alpha (ntmax, ntmax), beta (ntmax),           &
       deriv (ntmax), array (ntmax, ntmax), b (ntmax)
  real(8) functn
  external functn

  nfree = npts - nterms
  if(nfree.le.0) then
     chisqr=0.
     return
  endif

! In case we're not solving for all parameters
  n=size(a)
  b(1:n)=a

! Evaluate weights
  if(mode.eq.0) weight=1.0
  if(mode.eq.1) weight=1.0/(sigmay*sigmay)
 
! Evaluate alpha and beta matrices 
  beta=0.
  alpha=0.

  do i = 1, npts
     call fderiv (x, i, a, deltaa, nterms, deriv)
     do j = 1, nterms
        beta(j)=beta(j) + weight(i)*(y(i) - functn(x, i, a)) * deriv(j)
        alpha(j,1:j) = alpha(j,1:j) + weight(i) * deriv(j) * deriv(1:j)
     enddo
  end do

  do j = 1, nterms
     alpha(1:j, j) = alpha (j,1:j)
  enddo
 
! Evaluate chi square at starting point 
  do i = 1, npts
     yfit (i) = functn (x, i, a)
  enddo
  chisq1 = fchisq (y, sigmay, npts, nfree, mode, yfit)

! Invert modified curvature matrix to find new parameters
71 do j = 1, nterms
     do k = 1, nterms
        array(j, k) = alpha(j, k)/sqrt(alpha(j, j) * alpha(k, k))
     enddo
     array (j, j) = 1. + flamda
  enddo

  call matinv (array, nterms, det)

  do j = 1, nterms
     b (j) = a (j)
     do k = 1, nterms
        b(j)=b(j) + beta(k) * array(j,k)/sqrt(alpha(j,j) * alpha(k, k))
     enddo
  enddo

! If chi square increased, increase flamda and try again
  do i = 1, npts
     yfit (i) = functn (x, i, b)
  enddo
  chisqr = fchisq (y, sigmay, npts, nfree, mode, yfit)
  if (chisqr .gt. chisq1) then
     flamda = 10. * flamda
     goto 71
  endif
 
! Evaluate parameters and uncertainties

  do j = 1, nterms
     a (j) = b (j)
     sigmaa (j) = sqrt (array (j, j) / alpha (j, j) )
  enddo
  flamda = flamda / 10.

  return
end subroutine curfit
