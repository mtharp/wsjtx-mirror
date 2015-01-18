! Subroutine fderiv.f (non-analytical)
 
! Source
!   Bevington, page 242.
 
! Purpose
!   Evaluate derivatives of function for least-squares search
!      for arbitrary function given by functn
 
! Usage
!   call fderiv (x, i, a, deltaa, nterms, deriv)
 
! Description of parameters
!   x         - array of data points for independent variable
!   i         - index of data points
!   a         - array of parameters
!   deltaa - array of parameter increments
!   nterms - number of parameters
!   deriv  - derivatives of function
 
! Subroutines and function subprograms required
!   functn (x, i, a)
!      Evaluates the fitting function for the ith term
 
subroutine fderiv (x, i, a, deltaa, nterms, deriv)
  implicit real (8)(a - h, o - z)
  dimension x (100), a (5), deltaa (5), deriv (5)
  real(8) functn
  external functn

  do j = 1, nterms
     aj = a(j)
     delta = deltaa(j)
     a(j) = aj + delta
     yfit = functn(x,i,a)
     a(j) = aj - delta
     deriv(j) = (yfit - functn(x,i,a))/(2.0d0*delta)
     a(j) = aj
  enddo

     return
   end subroutine fderiv
