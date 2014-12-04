subroutine avecho(id2,ndop,nfrit,f1,nsum,nclearave)
!subroutine avecho(id2,ibuf0,ntc,necho,nfrit,ndither,nsave,f1,nsum,   &
!     nclearave,ss1,ss2)

  parameter (LENGTH=27*4096)
  parameter (NFFT=131072,NH=NFFT/2)
  integer*2 id2(LENGTH)                   !Buffer for Rx data
  real s1(600)      !Avg spectrum relative to initial Doppler echo freq
  real s2(600)      !Avg spectrum with Dither and changing Doppler removed
  real ss1(-224:224)
  real ss2(-224:224)
  real tmp(600)
  integer nsum      !Number of integrations
  real dop0         !Doppler shift for initial integration (Hz)
  real doppler      !Doppler shift for current integration (Hz)
  real s(8192)
  real x(NFFT)
  complex c(0:NH)
  equivalence (x,c)
  save s1,s2,dop0

  doppler=ndop
  sq=0.
  do i=1,LENGTH
     x(i)=id2(i)
     sq=sq + x(i)*x(i)
  enddo
  rms=sqrt(sq/LENGTH)
  sigdb=-99.0
  if(sq.gt.0.0) sigdb=10.0*log10((sq/LENGTH))
  if(sigdb.lt.-99.0) sigdb=-99.0

  if(nclearave.ne.0) nsum=0
  nclearave=0
  if(nsum.eq.0) then
     dop0=doppler                         !Remember the initial Doppler
     s1=0.                                !Clear the average arrays
     s2=0.
  endif

  x(LENGTH+1:)=0.
  x=x/LENGTH
  call four2a(x,NFFT,1,-1,0)
  df=48000.0/NFFT
  do i=1,8192
     s(i)=real(c(i))**2 + aimag(c(i))**2
  enddo

  fnominal=1500.0           !Nominal audio frequency w/o doppler or dither
  ia=nint((fnominal+dop0-nfrit)/df)
  ib=nint((f1+doppler-nfrit)/df)
  if(ia.lt.600 .or. ib.lt.600) go to 900
  if(ia.gt.7590 .or. ib.gt.7590) go to 900

  nsum=nsum+1

!  if(ntc.lt.1) ntc=1
!  u=1.0/nsum
!  if(nsum.gt.ntc) u=1.0/ntc
  do i=1,600
!     s1(i)=(1.0-u)*s1(i) + u*s(ia+i-300)  !Center at initial doppler freq
!     s2(i)=(1.0-u)*s2(i) + u*s(ib+i-300)  !Center at expected echo freq
     s1(i)=s1(i) + s(ia+i-300)  !Center at initial doppler freq
     s2(i)=s2(i) + s(ib+i-300)  !Center at expected echo freq
     j=i-300
     if(abs(j).le.224) then
        ss1(j)=s1(i)
        ss2(j)=s2(i)
     endif
  enddo

  call smo121(ss2,449)
  rewind 14
  do i=-224,224
     write(14,1100) i*df,ss1(i),ss2(i)
1100 format(f10.3,2e12.3)
  enddo

  write(*,3001) nsum,ndop,nfrit,nclearave,f1,sigdb,rms
3001 format(4i6,3f8.1)


900 return
end subroutine avecho
