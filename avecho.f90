subroutine avecho(y1,ibuf0,ntc,necho,nfrit,ndither,dlatency,nsave,f1,nsum)

  parameter (NBSIZE=1024*2048)
  integer*2 y1(NBSIZE)                   !Buffer for Rx data
  real d(28672)                          !Real audio data
  real s1(600)      !Avg spectrum relative to initial Doppler echo freq
  real s2(600)      !Avg spectrum with Dither and changing Doppler removed
  real tmp(600)
  integer nsum      !Number of integrations
  real dop0         !Doppler shift for initial integration (Hz)
  real doppler      !Doppler shift for current integration (Hz)
  real data(32768)
  real s(8192)
  real x(32770)
  complex c(0:16384)
  equivalence (x,c)
  common/echo/xdop(2),techo,ElMoon,mjd
  save s1,s2,dop0

  if(ibuf0.lt.1) print*,'IBUF0:',ibuf0
  k=2048*(ibuf0-1)  
  do i=1,14*2048
     k=k+1
     if(k.gt.NBSIZE) k=k-NBSIZE
     d(i)=y1(k)
  enddo

  if(nsum.eq.0) then
     dop0=2.0*xdop(1)       !Remember the initial Doppler
     s1=0.
     s2=0.
  endif

  doppler=2.0*xdop(1)
  dt=1.0/12000.0
!  df=2*12000.0/32768.0
  df=12000.0/32768.0
  istart=1
  nz=14*2048 + 1 - istart
  x(1:24030)=d(istart:istart+24029)
  x(24031:)=0.0
  call xfft(x,32768)

  fac=(1.0/32768.0)**2
!  do i=1,4096                          !Compress spectrum by factor of 2
!     j=2*i
!     s(i)=real(c(j-1))**2 + aimag(c(j-1))**2  + real(c(j))**2 + aimag(c(j))**2
!     s(i)=fac*s(i)
!     if(nsave.ne.0) write(51,3001) i*df,s(i),db(s(i))
!3001 format(f10.3,2f12.3)
!  enddo
  do i=1,8192
     s(i)=real(c(i))**2 + aimag(c(i))**2
     s(i)=fac*s(i)
     if(nsave.ne.0) write(51,3001) i*df,s(i),db(s(i))
3001 format(f10.3,2f12.3)
  enddo

  fnominal=1500.0           !Nominal audio frequency w/o doppler or dither
  ia=nint((fnominal+dop0-nfrit)/df)
  ib=nint((f1+doppler-nfrit)/df)
  
!  if(ia.lt.300 .or. ib.lt.300) goto 900
!  if(ia.gt.3795 .or. ib.gt.3795) goto 900
  if(ia.lt.600 .or. ib.lt.600) goto 900
  if(ia.gt.7590 .or. ib.gt.7590) goto 900

  nsum=nsum+1
  u=1.0/nsum
  if(ntc.lt.1) ntc=1
  if(nsum.gt.10*ntc) u=1.0/(10*ntc)
  do i=1,600
     s1(i)=(1.0-u)*s1(i) + u*s(ia+i-300)  !Center at initial doppler freq
     s2(i)=(1.0-u)*s2(i) + u*s(ib+i-300)  !Center at expected echo freq
     if(nsave.ne.0) write(52,3001) (i-300)*df,s1(i),s2(i)
  enddo

  call pctile(s2,tmp,600,50,x0)
  call pctile(s2,tmp,600,84,x1)
  rms=x1-x0
  peak=-1.e30
  do i=1,600
     if(s2(i).gt.peak) then
        peak=s2(i)
        ipk=i
     endif
  enddo

  s2half=0.5*(peak-x0) + x0

  ia=ipk
  ib=ipk
  do i=1,100
     if((ipk-i).lt.1) go to 11
     ia=ipk-i
     if(s2(ia).le.s2half) goto 11
  enddo
11 do i=1,100
     if((ipk+i).gt.600) go to 21
     ib=ipk+i
     if(s2(ib).le.s2half) goto 21
  enddo
21 width=df*(ib-ia-1)

  exchsig=-99.
  if(x0.gt.0.0) echosig=10.0*log10(peak/x0 - 1.0) - 35.7
  echodop=df*(ipk-300)
  snr=0.
  if(rms.gt.0.0) snr=(peak-x0)/rms

  sq=0.
  do i=1,jz
     sq=sq+data(i)*data(i)
  enddo
  sigdB=db(sq/jz) - 18.25
  if(sigdB.lt.-99.0) sigdB=-99.0

  NQual=(snr-2.5)/2.5
  if(nsum.lt.12)  NQual=(snr-3)/3
  if(nsum.lt.8)   NQual=(snr-3)/4
  if(nsum.lt.4)   NQual=(snr-4)/5
  if(nsum.lt.2)   NQual=0
  if(NQual.lt.0)  NQual=0
  if(NQual.gt.10) NQual=10

!  write(*,1009) nsum,sigdB,echosig,echodop,width,NQual,ibuf0
!1009 format(i4,f6.1,f7.1,f8.1,f6.1,i4,i8)

  rewind 11
  write(11,1010) nsum,sigdB,echosig,echodop,width,NQual
1010 format(i4,f6.1,f7.1,f8.1,f6.1,i4)
  write(21,1010) nsum,sigdB,echosig,echodop,width,NQual
  call flushqqq(11)
  call flushqqq(21)

900 techo2=techo
  return
end subroutine avecho
