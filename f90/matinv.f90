! Subroutine matinv.f
 
! Source
!   Bevington, pages 302-303.
 
! Purpose
!   Invert a symmetric matrix and calculate its determinant
 
! Usage
!   call matinv (array, norder, det)
 
! Description of parameters
!   array  - input matrix which is replaced by its inverse
!   norder - degree of matrix (order of determinant)
!   det    - determinant of input matrix
 
! Subroutines and function subprograms required
!   none
 
! Comment
!   Dimension statement valid for norder up to 10
 
subroutine matinv (array, norder, det)
  implicit real (8) (a - h, o - z)
  dimension array (10, 10), ik (10), jk (10)

  det = 1.
  do k = 1, norder

! Find largest element array(i,j) in rest of matrix

     amax = 0.
21   do i = k, norder
        do j = k, norder
           if (abs(amax) .lt. abs(array(i, j) )) then
              amax = array(i, j)
              ik(k) = i
              jk(k) = j
           endif
        enddo
     enddo

! Interchange rows and columns to put amax in array(k,k)

     if (amax.eq.0.d0) then
        det = 0.
        return
     endif

     i = ik(k)
     if(i.lt.k) go to 21
     if(i.gt.k) then
        do j = 1, norder
           tmp = array (k, j)
           array (k, j) = array (i, j)
           array (i, j) = -tmp
        enddo
     endif

     j = jk (k)
     if(j.lt.k) go to 21
     if(j.gt.k) then
        do i = 1, norder
           tmp = array (i, k)
           array (i, k) = array (i, j)
           array (i, j) = -tmp
        enddo
     endif

! Accumulate elements of inverse matrix

     do i = 1, norder
        if(i.ne.k) array(i,k) = -array(i,k)/amax
     end do

     do i = 1, norder
           if(i.eq.k) cycle
        do j = 1, norder
           if(j.ne.k) array(i,j)=array(i,j) + array(i,k)*array(k,j)
        enddo
     enddo

     do j = 1, norder
        if(j.ne.k) array(k,j) = array(k,j)/amax
     end do

     array (k, k) = 1. / amax
     det = det * amax
  enddo

! Restore ordering of matrix

   do l = 1, norder
      k = norder - l + 1
      j = ik (k)
      if (j.gt.k) then
         do i = 1, norder
            tmp = array (i, k)
            array (i, k) = - array (i, j)
            array (i, j) = tmp
         enddo
      endif

      i = jk (k)
      if(i.gt.k) then
         do j = 1, norder
            tmp = array (k, j)
            array (k, j) = - array (i, j)
            array (i, j) = tmp
         enddo
      endif
   end do
 
  return
 end subroutine matinv
