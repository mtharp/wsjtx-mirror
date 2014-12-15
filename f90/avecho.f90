subroutine avecho(id2,ndop,nfrit,nsum,nclearave,nqual,        &
     f1,rms0,snrdb,dfreq,width,blue0,red0)

  integer RXLENGTH2,TXLENGTH2
  parameter (RXLENGTH2=33792)             !33*1024
  parameter (TXLENGTH2=27648)             !27*1024
  parameter (NFFT=32768,NH=NFFT/2)
  integer*2 id2(RXLENGTH2)                !Buffer for Rx data
  real blue(2000)     !Avg spectrum relative to initial Doppler echo freq
  real red(2000)      !Avg spectrum with Dither and changing Doppler removed
  real blue0(2000)
  real red0(2000)
  integer nsum      !Number of integrations
  real dop0         !Doppler shift for initial integration (Hz)
  real doppler      !Doppler shift for current integration (Hz)
  real s(8192)
  real x(NFFT)
  integer ipkv(1)
  complex c(0:NH)
  equivalence (x,c),(ipk,ipkv)
  save dop0,blue,red

  doppler=ndop
  sq=0.
  i00=2000
  do i=1,TXLENGTH2
     x(i)=id2(i+i00)
     sq=sq + x(i)*x(i)
  enddo
  rms0=sqrt(sq/TXLENGTH2)

  if(nclearave.ne.0) nsum=0
  nclearave=0
  if(nsum.eq.0) then
     dop0=doppler                         !Remember the initial Doppler
     blue=0.                              !Clear the average arrays
     red=0.
  endif

  x(TXLENGTH2+1:)=0.
  x=x/TXLENGTH2
  call four2a(x,NFFT,1,-1,0)
  df=12000.0/NFFT
  do i=1,8192
     s(i)=real(c(i))**2 + aimag(c(i))**2
  enddo

  fnominal=1500.0           !Nominal audio frequency w/o doppler or dither
  ia=nint((fnominal+dop0-nfrit)/df)
  ib=nint((f1+doppler-nfrit)/df)
  if(ia.lt.600 .or. ib.lt.600) go to 900
  if(ia.gt.7590 .or. ib.gt.7590) go to 900

  nsum=nsum+1

  do i=1,2000
     blue(i)=blue(i) + s(ia+i-1000)  !Center at initial doppler freq
     red(i)=red(i) + s(ib+i-1000)    !Center at expected echo freq
  enddo

  call pctile(red,200,50,r0)
  call pctile(red(1800),200,50,r1)

  sum=0.
  sq=0.
  do i=1,2000
     y=r0 + (r1-r0)*(i-100.0)/1800.0
     blue0(i)=blue(i)/y
     red0(i)=red(i)/y
     if(i.le.500 .or. i.ge.1501) then
        sum=sum+red0(i)
        sq=sq + (red0(i)-1.0)**2
     endif
  enddo
  ave=sum/1000.0
  rms=sqrt(sq/1000.0)

  redmax=maxval(red0)
  ipkv=maxloc(red0)
  fac=10.0/max(redmax,10.0)
  dfreq=(ipk-1000)*df
  snr=(redmax-ave)/rms
  halfmax=0.5*(redmax-ave) + ave

  snrdb=-99.0
  if(ave.gt.0.0) snrdb=10.0*log10(redmax/ave - 1.0) - 35.7

  nqual=(snr-2.5)/2.5
  if(nsum.lt.12)  nqual=(snr-3)/3
  if(nsum.lt.8)   nqual=(snr-3)/4
  if(nsum.lt.4)   nqual=(snr-4)/5
  if(nsum.lt.2)   nqual=0
  if(nqual.lt.0)  nqual=0
  if(nqual.gt.10) nqual=10

! Scale for plotting
  blue0=fac*blue0
  red0=fac*red0

  sum=0.
  do i=ipk,ipk+300
     if(red0(i).lt.1.0) exit
     sum=sum+(red0(i)-1.0)
  enddo
  do i=ipk-1,ipk-300,-1
     if(red0(i).lt.1.0) exit
     sum=sum+(red0(i)-1.0)
  enddo
  bins=sum/(red0(ipk)-1.0)
  width=df*bins
  nsmo=max(1.0,0.5*bins)

  do i=1,nsmo
     call smo121(red0,2000)
  enddo

900 return
end subroutine avecho
