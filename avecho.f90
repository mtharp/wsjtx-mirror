subroutine avecho(d,jzz,t3a,t3b,f0,f1,fRIT,NSaveCum,AppDir,    &
     s1,s2,nsum,doppler,techo2,measure,ntc)

!  character*(*) avecho  !Interface for passing string to VB
  integer*1 d(jzz)   !Raw audio data
  real t3a          !Time that TX audio started (s)
  real t3b          !Time that RX recording started (s)
  real f0           !Nominal TX frequency (MHz)
  real f1           !Frequency of audio tone (Hz)
  real fRIT         !RX offset from TX dial frequency (Hz)
  real s1(600)      !Avg spectrum relative to initial Doppler echo freq
  real s2(600)      !Avg spectrum with Dither and changing Doppler removed
  real tmp(600)
  integer nsum      !Number of integrations

  character AppDir*80 !Installation directory for WSJT
  character fcum*99
  real dop0         !Doppler shift for initial integration (Hz)
  real doppler      !Doppler shift for current integration (Hz)

  real data(32768)
  real s(4096)
  real x(32770)
  complex c(0:16384)
  equivalence (x,c)
  common/echo/xdop(2),techo,ElMoon,mjd

  jz=min(jzz,32768)
!  avecho=' '

!2 call i1tor4(d,jz,data)    !Convert byte data to real

  dt3=t3b-t3a

  if(nsum.eq.0) then
     dop0=2.0*xdop(1)       !Remember the initial Doppler
     call zero(s1,600)
     call zero(s2,600)
  endif

  doppler=2.0*xdop(1)
  dt=1.0/11025.0
  df=2.0*11025.0/32768.0
  istart=(techo - (t3b-t3a))/dt
  if(istart.lt.1) istart=1
  if(istart.gt.jz) istart=jz
  nz=min(22050,jz-istart)
  call move(data(istart),x,nz)
  call zero(x(nz+1),32768-nz)
  call xfft(x,32768)

  fac=(1.0/32768.0)**2
  do i=1,4096                          !Compress spectrum by factor of 2
     j=2*i
     s(i)=real(c(j-1))**2 + imag(c(j-1))**2  + real(c(j))**2 + imag(c(j))**2
     s(i)=fac*s(i)
  enddo

  fnominal=1500           !Nominal audio frequency w/o doppler or dither
  ia=nint((fnominal+dop0-fRIT)/df)
  ib=nint((f1+doppler-fRIT)/df)
  if(ia.lt.300 .or. ib.lt.300) goto 900
  if(ia.gt.3795 .or. ib.gt.3795) goto 900

  nsum=nsum+1
  u=1.0/nsum
  if(ntc.lt.1) ntc=1
  if(nsum.gt.10*ntc) u=1.0/(10*ntc)
  do i=1,600
     s1(i)=(1.0-u)*s1(i) + u*s(ia+i-300)  !Center at initial doppler freq
     s2(i)=(1.0-u)*s2(i) + u*s(ib+i-300)  !Center at expected echo freq
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

  write(*,1010) nsum,sigdB,echosig,echodop,width,NQual
1010 format(i4,f6.1,f7.1,f8.1,f6.1,i4)

900 techo2=techo
  return
end subroutine avecho
