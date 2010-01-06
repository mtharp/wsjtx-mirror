subroutine decode64(dat,jz,dtx,dfx,flip,ndepth,isbest,                 &
     mycall,hiscall,hisgrid,mode64,nafc,decoded,ncount,                &
     deepmsg,qual)

! Decodes JT65 data, assuming that DT and DF have already been determined.

  real dat(jz)                        !Raw data
  real s2(74,87)
  real s3(64,63)
  real ftrack(87)
  character*22 decoded,deepmsg
  character mycall*12,hiscall*12,hisgrid*6
  include 'avecom.f90'
!  include 'prcom.h'

  dt=2.0/12000.0                   !Sample interval (2x downsampled data)
  istart=nint(dtx/dt)              !Start index for synced FFTs
  nsym=87

! Compute spectra of the channel symbols
  f0=1270.46 + dfx
  call spec2d64(dat,jz,nsym,flip,istart,f0,ftrack,nafc,mode64,s2)

  do k=1,21
     j1=k+6
     j2=k+33
     j3=k+60
     do i=1,64
        s3(i,k)=s2(i+5,j1)
        s3(i,k+21)=s2(i+5,j2)
        s3(i,k+42)=s2(i+5,j3)
     enddo
  enddo
  nadd=mode64

  call extract(s3,nadd,isbest,ncount,decoded,ndec)     !Extract the message
  qual=0.
!  if(ndepth.ge.1) call deep65(s3,mode64,neme,                         &
!       flip,mycall,hiscall,hisgrid,deepmsg,qual)

  if(ncount.lt.0) decoded='                      '

! Suppress "birdie messages":
  if(decoded(1:7).eq.'000AAA ') decoded='                      '
  if(decoded(1:7).eq.'0L6MWK ') decoded='                      '

! Save symbol spectra for possible decoding of average.
!### FIX THIS ###
!  do j=1,63
!     call move(s2(8,k),ppsave(1,j,nsave),64)
!  enddo

  return
end subroutine decode64
