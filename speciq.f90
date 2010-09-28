subroutine speciq(kwave,npts,iwrite,iqrx,nfiq)

  parameter (NFFT=32768)
  parameter (NH=NFFT/2)
  integer*2 kwave(2,npts)
  logical first
  real s(-NH+1:NH)
  complex c,z,zsum,zave
  common/fftcom2/c(0:NFFT-1),ss(-NH+1:NH)
  data first/.true./
  save first,nn

  if(first) then
     df=48000.0/NFFT
     ss=0.
     first=.false.
     nn=0
     zsum=0.
     rewind 50
  endif

  if(iwrite.lt.nfft) go to 900

  nn=nn+1
  fac=10.0**(-4.3)
  j=iwrite-nfft
  do i=0,nfft-1
     j=j+1
     if(iqrx.eq.0) then
        x=kwave(2,j)
        y=kwave(1,j)
     else
        x=kwave(1,j)
        y=kwave(2,j)
     endif
     c(i)=fac*cmplx(x,y)
  enddo

  call four2a(c,NFFT,1,-1,1)

  do i=0,nfft-1
     j=i
     if(j.gt.NH) j=j-nfft
     s(j)=real(c(i))**2 + aimag(c(i))**2
  enddo

  do i=-NH+1,NH
     u=1.0 - exp(-(0.2*s(i)))
     ss(i)=(1.0-u)*ss(i) + u*s(i)
  enddo

  call cs_lock('speciq')
!  do i=-NH+1,NH
!     write(50,3001) i*df,db(s(i)),db(ss(i))
!3001 format(3f12.3)
!  enddo

  ia=(nfiq+1000)/df
  ib=(nfiq+2000)/df
  smax=0.
  do i=ia,ib
     if(s(i).gt.smax) then
        smax=s(i)
        ipk=i
     endif
  enddo
  p=s(ipk) + s(-ipk)
  z=c(ipk)*c(nfft-ipk)/p
  zsum=zsum+z
  zave=zsum/nn
  tmp=sqrt(1.0 - (2.0*real(zave))**2)
  pha=asin(2.0*aimag(zave)/tmp)
  gain=tmp/(1.0-2.0*real(zave))
  write(*,3002)  nn,ipk*df,zave,gain,pha,db(s(ipk)),db(s(-ipk))
  write(50,3002) nn,ipk*df,zave,gain,pha,db(s(ipk)),db(s(-ipk))
3002 format(i5,f7.0,4f10.6,2f8.1)

  call flush(50)
  call cs_unlock

900 return
end subroutine speciq
