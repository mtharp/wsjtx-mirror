subroutine mskdf(cdat,npts,nfft1,f0,ldebug,dfx,snrsq2)

! Determine DF for a JTMSK signal.

  parameter (NZ=32768)
  complex cdat(npts)                    !Analytic signal
  real s(NZ)
  real ccf(-1200:1200)                  !Correct limits?
  complex c(NZ)
  logical ldebug
  data nsps/6/
  save c

  ntol=400
  df1=12000.0/nfft1
  nh=nfft1/2
  fac=1.0/(nfft1**2)
  fac=1.0

  do i=1,npts
     c(i)=fac*cdat(i)**2
  enddo
  c(npts+1:nfft1)=0.
  call four2a(c,nfft1,1,-1,1)

! In the "doubled-frequencies" spectrum of squared cdat:
  fa=2.0*(f0-ntol)
  fb=2.0*(f0+ntol)
  j0=nint(2.0*f0/df1)
  ja=nint(fa/df1)
  jb=nint(fb/df1)
  jd=nfft1/nsps

  do j=1,nh+1
     s(j)=real(c(j))**2 + aimag(c(j))**2
     if(ldebug) then
        write(72,3001) (j-1)*df1,s(j),db(s(j))
3001    format(3f12.3)
     endif
  enddo

  ccf=0.
  kmin=10000
  kmax=-kmin
  do j=ja,jb
     k=j-j0-1
     kmin=min(k,kmin)
     kmax=max(k,kmax)
     ccf(k)=s(j) + s(j+jd)
  enddo

  call pctile(ccf(ja-j0-1),jb-ja+1,50,base)
  ccf=ccf/base

  smax=0.
  jpk=0
  do k=kmin,kmax
     j=k+j0+1
     if(ccf(k).gt.smax) then
        smax=ccf(k)
        jpk=j
     endif
     if(ldebug) then
        write(73,3002) 0.5*(j-1)*df1-f0,ccf(k)
3002    format(2f12.3)
     endif
  enddo

  fpk=(jpk-1)*df1  
  dfx=0.5*fpk-f0
  snrsq2=smax

  return
end subroutine mskdf
