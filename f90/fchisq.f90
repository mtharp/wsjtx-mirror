! Function fchisq.f
 
! Source
!   Bevington, page 194.
 
! Purpose
!   Evaluate reduced chi square for fit of data
!     fchisq = sum ((y-yfit)**2 / sigma**2) / nfree
 
! Usage
!   result = fchisq (y, sigmay, npts, nfree, mode, yfit)
 
! Description of parameters
!   y      - array of data points
!   sigmay - array of standard deviations for data points
!   npts   - number of data points
!   nfree  - number of degrees of freedom
!   mode   - determines method of weighting least-squares fit
!            +1 (instrumental) weight(i) = 1./sigmay(i)**2
!             0 (no weighting) weight(i) = 1.
!            -1 (statistical)  weight(i) = 1./y(i)
!   yfit   - array of calculated values of y
 
! Subroutines and function subprograms required
!   none

real(8) function fchisq (y, sigmay, npts, nfree, mode, yfit)
  implicit real (8) (a - h, o - z)
  parameter (NPMAX=100)
  double precision chisq, weight
  dimension y (NPMAX), sigmay (NPMAX), yfit (NPMAX), weight(NPMAX)
  chisq = 0.
  if (nfree.le.0) then
     fchisq = 0.
     return
  endif
 
! Evaluate weights
  if(mode.eq.0) weight=1.0
  if(mode.eq.1) weight=1.0/(sigmay*sigmay)

! Accumulate chi square
 
  do i = 1, npts
     chisq = chisq + weight(i) * (y(i) - yfit(i))**2
  enddo

! Divide by number of degrees of freedom 
  free = nfree
  fchisq = chisq / free

  return
end function fchisq
