subroutine txtone(c,t0,f1a)

  parameter (NZH=260000)                !2.7 * 96000
  parameter (NFFT=256*1024)
  parameter (NTX=27*8192)
  complex c(0:520000-1)
  complex ct(0:NFFT-1)

  ia=nint(0.25*96000)
  ib=nint(0.35*96000)
  rms=sqrt(real(dot_product(c(ia:ib),conjg(c(ia:ib))))/(ib-ia+1))

  ia=nint(0.35*96000)
  ib=nint(0.5*96000)
  n=0
  do i=ia,ib
     if(abs(c(i)).gt.100.0*rms) n=n+1
     if(n.gt.100) exit
  enddo
  t0=i/96000.0
  i0=nint(t0*96000.0)

  fac=1.0/NFFT
  ct(0:NTX-1)=fac*conjg(c(i0:i0+NTX-1))
  ct(0:NTX:2)=-ct(0:NTX:2)
  ct(NTX:)=0.
  call four2a(ct,nfft,1,-1,1)
  f1a=0.
  smax=0.
  df=96000.0/NFFT
  do i=0,NFFT-1
     f=i*df
     if(i.gt.NFFT/2) f=(i-NFFT)*df
     ss=real(ct(i))**2 + aimag(ct(i))**2
     if(ss.gt.smax) then
        smax=ss
        f1a=f
     endif
  enddo

  return
end subroutine txtone
