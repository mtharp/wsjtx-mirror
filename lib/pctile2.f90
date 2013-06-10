subroutine pctile2(x,npts,npct,xpct)

  parameter (NH=1000)
  real x(npts)
  integer hist(0:NH)

  xmax=maxval(x)
  xmin=minval(x)
!  xave=sum(x)/npts

  xmax=sqrt(xmax)
  xmin=sqrt(xmin)

  hist=0
  s=NH/(xmax-xmin)
  do i=1,npts
     n=nint(s*(sqrt(x(i))-xmin))
     hist(n)=hist(n)+1
  enddo
     
  nsum=0
  nchk=nint(npct*0.01*npts)
  do i=1,NH
     nsum=nsum+hist(i)
     if(nsum.ge.nchk) exit
  enddo
  xpct=xmin + (i-0.5)*(xmax-xmin)/NH
  xpct=xpct**2

!  write(71,*) npts,npct,nsum,nchk,i,xmin,xmax,xpct
!  call flush(71)

  return
end subroutine pctile2
