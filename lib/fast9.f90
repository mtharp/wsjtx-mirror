subroutine fast9(id2,narg,line)

  parameter (NMAX=15*12000)
  parameter (NFFT=120,NH=NFFT/2,NQ=NFFT/4,JZ=NMAX/(NH/4))
  integer*2 id2(0:NMAX)
  integer narg(0:9)
  integer ii4(16)
  integer*1 i1SoftSymbolsScrambled(207)
  integer*1 i1SoftSymbols(207)
  real s1(JZ,NQ)
  real s2(340,NQ)
  real ss2(0:8,85)
  real ss3(0:7,69)
  real s(NQ)
  real ccf(0:340-1,10)
  real x(NFFT)
  complex c(0:NH)
  character*22 msg
  character*80 line(100)
  equivalence (x,c)
  include 'jt9sync.f90'

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
  nsps=NH
  s=0
  s2=0

  do j=1,jz
     ia=(j-1)*nsps/4
     ib=ia+nsps-1
     if(ib.gt.npts) exit
     x(1:NH)=id2(ia:ib)
     x(NH+1:)=0.
     call four2a(x,NFFT,1,-1,0)           !r2c
     k=mod(j-1,340)+1
     do i=1,NQ
        t=1.e-10*(real(c(i))**2 + aimag(c(i))**2)
        s1(j,i)=t
        s2(k,i)=s2(k,i)+t
        s(i)=s(i)+t
     enddo
  enddo

  df=12000.0/NFFT
!  do i=1,NQ
!     write(13,3001) i*df,s(i)
!3001 format(f10.3,e12.3)
!  enddo

  ii4=4*ii-3
  ccf=0.
  ccfbest=0.
  do k=1,10
     do lag=0,339
        t=0.
        do i=1,16
           j=ii4(i)+lag
           if(j.gt.340) j=j-340
           t=t + s2(j,k)
        enddo
        ccf(lag,k)=t
        if(t.gt.ccfbest) then
           ccfbest=t
           lagpk=lag
           kpk=k
        endif
!        if(k.eq.7) write(14,3002) lag,ccf(lag,7)    !Blue
!3002    format(i6,f10.3)
     enddo
  enddo

!  do k=1,10
!     write(16,3002) k,ccf(lagpk,k)                  !Red
!  enddo

  ipk=7

  do i=0,8
     j4=lagpk-4
     i2=2*i + ipk
     m=0
     do j=1,85
        j4=j4+4
        if(j4.gt.340) j4=j4-340
        if(j4.lt.1) j4=j4+340
        ss2(i,j)=s2(j4,i2)
        if(i.ge.1 .and. isync(j).eq.0) then
           m=m+1
           ss3(i-1,m)=ss2(i,j)
        endif
     enddo
  enddo

!  do j=1,85
!     write(15,3003) j,ss2(0:8,j)
!3003 format(i2,9f8.2)
!  enddo

! ###########################################

  ss=0.
  sig=0.
  do j=1,69
     smax=0.
     do i=0,7
        smax=max(smax,ss3(i,j))
        ss=ss+ss3(i,j)
     enddo
     sig=sig+smax
     ss=ss-smax
  enddo
  ave=ss/(69*7)                           !Baseline
  call pctile(ss2,9*85,35,xmed)
  ss3=ss3/ave
  sig=sig/69.                             !Signal
  t=max(1.0,sig - 1.0)
  snrdb=db(t) - 61.3
     
  m0=3
  k=0
  scale=10.0

  do j=1,69
     do m=m0-1,0,-1                   !Get bit-wise soft symbols
        if(m.eq.2) then
           r1=max(ss3(4,j),ss3(5,j),ss3(6,j),ss3(7,j))
           r0=max(ss3(0,j),ss3(1,j),ss3(2,j),ss3(3,j))
        else if(m.eq.1) then
           r1=max(ss3(2,j),ss3(3,j),ss3(4,j),ss3(5,j))
           r0=max(ss3(0,j),ss3(1,j),ss3(6,j),ss3(7,j))
        else
           r1=max(ss3(1,j),ss3(2,j),ss3(4,j),ss3(7,j))
           r0=max(ss3(0,j),ss3(3,j),ss3(5,j),ss3(6,j))
        endif

        k=k+1
        i4=nint(scale*(r1-r0))
        if(i4.lt.-127) i4=-127
        if(i4.gt.127) i4=127
        i1SoftSymbolsScrambled(k)=i4
     enddo
  enddo

  limit=10000
! Remove interleaving
  call interleave9(i1SoftSymbolsScrambled,-1,i1SoftSymbols)
  call jt9fano(i1SoftSymbols,limit,nlim,msg)

  nsync=0.25*ccfbest
  if(nsync.lt.0) nsync=0
  if(nsync.gt.10) nsync=10
  nsnr=nint(db(ccfbest)-22.0)
  xdt=0.
  freq=ipk*df

  write(line(1),1000) nutc,nsync,nsnr,xdt,nint(freq),0,msg
1000 format(i6.6,2i4,f5.1,i5,i3,2x,a22)

  return
end subroutine fast9
