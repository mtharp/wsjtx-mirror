subroutine fast9(id2,narg,line)

  parameter (NMAX=30*12000)
  parameter (MAXQ=120)
  integer*2 id2(0:NMAX)
  integer narg(0:9)
  integer*1 i1SoftSymbols(207)
  real s1(720000)                  !It's actually s1(nq,jz)
  real s2(340,MAXQ)
  real ss2(0:8,85)
  real ss3(0:7,69)
  character*22 msg
  character*80 line(100)
  save s1,nsubmode0
  data nsubmode0/-1/

  nutc=narg(0)
  npts=min(narg(1),NMAX)
  nsubmode=narg(2)
  newdat=narg(3)
  minsync=narg(4)
  npick=narg(5)
  t0=0.001*narg(6)
  t1=0.001*narg(7)
  maxlines=narg(8)

  line(1:100)(1:1)=char(0)
  s=0
  s2=0

  nsps=60 * 2**(7-nsubmode)
  nh=nsps
  nfft=nh*2
  nq=nh/2
  istep=nsps/4
  jz=NMAX/istep
  df=12000.0/nfft
  nfa=500
  nfb=900
!  print*,'A',newdat,nsubmode,nfft,jz,nq

  if(newdat.eq.1 .or. nsubmode.ne.nsubmode0) then
     print*,'Computing symbol spectra'
     call spec9f(id2,npts,nsps,s1,jz,nq)          !Compute symbol spectra, s1 
  endif
  nsubmode0=nsubmode

  call foldspec9f(s1,nq,jz,s2)                    !Fold symbol spectra into s2

! Find sync; put sync'ed symbol spectra into ss2 and ss3
  call sync9f(s2,nq,nfa,nfb,ss2,ss3,ipk,ccfbest) 

  call softsym9f(ss2,ss3,snrdb,i1SoftSymbols)     !Compute soft symbols

  limit=10000
  call jt9fano(i1SoftSymbols,limit,nlim,msg)      !Invoke Fano decoder
!  print*,limit,nlim,msg

!  if(nlim.lt.limit) then
     nsync=0.25*ccfbest
     if(nsync.lt.0) nsync=0
     if(nsync.gt.10) nsync=10
     nsnr=nint(db(ccfbest)-22.0)
     xdt=0.
     freq=ipk*df
     write(line(1),1000) nutc,nsync,nsnr,xdt,nint(freq),0,msg
1000 format(i6.6,2i4,f5.1,i5,i3,2x,a22)
!  endif

  return
end subroutine fast9

include 'foldspec9f.f90'
