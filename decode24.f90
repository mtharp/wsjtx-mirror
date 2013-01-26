subroutine decode24(dat,npts,dtx,dfx,flip,mode,mode4,width,mycall,hiscall,  &
  hisgrid,decoded,ncount,deepbest,qbest,ichbest,submode)

! Decodes JT65 data, assuming that DT and DF have already been determined.

  parameter (MAXAVE=120)
  real dat(npts)                        !Raw data
  character decoded*22,deepmsg*22,deepbest*22
  character*12 mycall,hiscall
  character*6 hisgrid
  character submode*1
  real*8 dt,df,phi,f0,dphi,twopi,phi1,dphi1
  complex*16 cz,cz1,c0,c1
  real*4 rsymbol(207,7)
  real*4 sym(207)
  integer nsum(7)
  integer amp
  integer mettab(0:255,0:1)             !Metric table
  integer nch(7)
  integer npr2(207)
  common/ave/ppsave(207,7,MAXAVE),nflag(MAXAVE),nsave,iseg(MAXAVE)
  data mode0/-999/
  data nsum/7*0/,rsymbol/1449*0.0/
  data npr2/                                                         &
       0,0,0,0,1,1,0,0,0,1,1,0,1,1,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0,  &
       0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,0,0,  &
       1,0,0,1,0,0,1,1,1,1,1,0,0,0,1,0,1,0,0,0,1,1,1,1,0,1,1,0,0,1,  &
       0,0,0,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,0,1,0,1,  &
       0,1,1,1,0,0,1,0,1,1,0,1,1,1,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,1,  &
       0,1,1,1,0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1,  &
       1,0,0,1,1,0,0,0,0,1,1,0,0,0,1,0,1,1,0,1,1,1,1,0,1,0,1/

  data nch/1,2,4,9,18,36,72/
  save mettab,mode0,nsum,rsymbol

  if(mode.ne.mode0) call getmet24(mode,mettab)
  mode0=mode
  twopi=8*atan(1.d0)
  dt=2.d0/11025             !Sample interval (2x downsampled data)
  df=11025.d0/2520.d0       !Tone separation for JT4A mode
  nsym=206
  amp=15
  istart=nint(dtx/dt)              !Start index for synced FFTs
  if(istart.lt.0) istart=0
  nchips=0
  qbest=-1.e30
  deepmsg='                      '
  ichbest=-1

! Should amp be adjusted according to signal strength?
! Compute soft symbols using differential BPSK demodulation
  c0=0.                                !### C0=amp ???
  k=istart
  phi=0.d0
  phi1=0.d0

  nw=0.5*width/df
  if(nw.gt.mode4) nw=mode4
  do ich=1,7
     if(nch(ich).ge.nw) exit
  enddo

40 ich=ich+1
  nchips=nch(ich)
  nspchip=1260/nchips
  k=istart
  phi=0.d0
  phi1=0.d0
  fac2=1.e-8 * sqrt(float(mode4))
  do j=1,nsym+1
     if(flip.gt.0.0) then
        f0=1270.46 + dfx + (npr2(j)-1.5)*mode4*df
        f1=1270.46 + dfx + (2+npr2(j)-1.5)*mode4*df
     else
        f0=1270.46 + dfx + (1-npr2(j)-1.5)*mode4*df
        f1=1270.46 + dfx + (3-npr2(j)-1.5)*mode4*df
     endif
     dphi=twopi*dt*f0
     dphi1=twopi*dt*f1
     sq0=0.
     sq1=0.
     do nc=1,nchips
        phi=0.d0
        phi1=0.d0
        c0=0.
        c1=0.
        do i=1,nspchip
           k=k+1
           phi=phi+dphi
           phi1=phi1+dphi1
           cz=dcmplx(cos(phi),-sin(phi))
           cz1=dcmplx(cos(phi1),-sin(phi1))
           if(k.le.npts) then
              c0=c0 + dat(k)*cz
              c1=c1 + dat(k)*cz1
           endif
        enddo
        sq0=sq0 + real(c0)**2 + aimag(c0)**2
        sq1=sq1 + real(c1)**2 + aimag(c1)**2
     enddo
     sq0=fac2*sq0
     sq1=fac2*sq1
     rsym=amp*(sq1-sq0)
     if(j.ge.1) then
        rsymbol(j,ich)=rsym
        sym(j)=rsym
     endif
  enddo
  
  call extract4(sym,nadd,ncount,decoded)     !Do the KV decode

  qual=0.                                    !Now try deep search
  neme=1
  call deep24(sym(2),neme,flip,mycall,hiscall,hisgrid,deepmsg,qual)
  if(qual.gt.qbest) then
     qbest=qual
     deepbest=deepmsg
     ichbest=ich
  endif

  if(ncount.ge.0) then
     ichbest=ich
     go to 100
  endif
  if(mode.eq.7 .and. nchips.lt.mode4) go to 40

100 if(ncount.lt.0) then
     decoded=deepbest
     qual=qbest
  endif
  submode=char(ichar('A')+ichbest-1)
  ppsave(1:207,1:7,nsave)=rsymbol(1:207,1:7)  !Save data for message averaging

  return
end subroutine decode24
