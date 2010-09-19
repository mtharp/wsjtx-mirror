subroutine chklevel(kwave,iz,jz,nsec1,xdb1,xdb2)

! Called from wspr2 at ~5 Hz rate.

  integer*2 kwave(iz,jz)
  integer time

  nsec3=time()
  i2=48000*(nsec3-nsec1)
  if(i2.gt.114*48000) i2=114*48000
  i1=max(1,i2-48000+1)
  do i=i2,i1,-1
     if(kwave(1,i).ne.0) go to 10
  enddo

10 i4=i
  i3=max(1,i4-48000+1)
  npts=i4-i3+1
  s1=0.
  s2=0.
  do i=i3,i4
     s1=s1+kwave(1,i)
     if(iz.eq.2) s2=s2+kwave(2,i)
  enddo
  ave1=s1/npts
  ave2=s2/npts
  sq1=0.
  sq2=0.
  do i=i3,i4
     x1=kwave(1,i)-ave1
     sq1=sq1 + x1*x1
     if(iz.eq.2) then
        x2=kwave(2,i)-ave2
        sq2=sq2 + x2*x2
     endif
  enddo
  xdb1=-99.
  rms1=-99.
  if(sq1.gt.0.0) then
     rms1=sqrt(sq1/npts)
     xdb1=20.0*log10(rms1)
  endif

  xdb2=-99.
  rms2=-99.
  if(sq2.gt.0.0) then
     rms2=sqrt(sq2/npts)
     xdb2=20.0*log10(rms2)
  endif

  return
end subroutine chklevel
