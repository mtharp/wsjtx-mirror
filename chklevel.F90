subroutine chklevel

! Called from wspr2 at ~5 Hz rate.

#ifdef CVF
  use dfport
#else
  integer time
#endif

  include 'acom1.f90'

  nsec3=time()
  i2=12000*(nsec3-nsec1)
  if(i2.gt.114*12000) i2=114*12000
  i1=max(1,i2-12000+1)
  do i=i2,i1,-1
     if(iwave(i).ne.0) go to 10
  enddo

10  i4=i
  i3=max(1,i4-12000+1)
  npts=i4-i3+1
  s=0.
  do i=i3,i4
     s=s+iwave(i)
  enddo
  ave=s/npts
  sq=0.
  do i=i3,i4
     x=iwave(i)-ave
     sq=sq + x*x
  enddo
  xdb1=-99.
  rms1=-99.
  if(sq.gt.0.0) then
     rms1=sqrt(sq/npts)
     xdb1=20.0*log10(rms1)
  endif

  return
end subroutine chklevel
