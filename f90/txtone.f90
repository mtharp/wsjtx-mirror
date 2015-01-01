subroutine txtone(c,t0,f1a,smax)

  parameter (NZH=260000)                !2.7 * 96000
  parameter (NFFT=256*1024)
  parameter (NTX=27*8192)
  complex c(0:520000-1)
  complex ct(0:NFFT-1)
  real s(1000)

  ss=0.
  base=0.
  do i=1,1000
     ia=(i-1)*96
     ib=ia+95
     s(i)=sum(real(c(ia:ib)*conjg(c(ia:ib))))
     write(71,3001) i,0.001*i,s(i),base
3001 format(i10,f10.3,2e12.3)
     if(i.gt.900) ss=ss+s(i)
  enddo
  flush(71)
  base=ss/100.0

  do i=1000,1,-1
     if(s(i).lt.0.2*base) exit
  enddo
  t0=0.001*i + 0.02
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
