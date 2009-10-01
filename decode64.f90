subroutine decode64(dat,npts,dtx,dfx,flip,ndepth,neme,                 &
     mycall,hiscall,hisgrid,mode64,nafc,decoded,ncount,                &
     deepmsg,qual)

! Decodes JT65 data, assuming that DT and DF have already been determined.

  real dat(npts)                        !Raw data
  real s2(77,126)
  real s3(64,63)
  real ftrack(126)
  character decoded*22,deepmsg*22
  character mycall*12,hiscall*12,hisgrid*6
  include 'avecom.f90'
!  include 'prcom.h'

  dt=2.0/11025.0                   !Sample interval (2x downsampled data)
  istart=nint(dtx/dt)              !Start index for synced FFTs
  nsym=126

! Compute spectra of the channel symbols
  f0=1270.46 + dfx
  call spec2d64(dat,npts,nsym,flip,istart,f0,ftrack,nafc,mode64,s2)

!### FIX THIS ###
  do j=1,63
     do i=1,64
        s3(i,j)=s2(i+5,j)              !FIX THIS
     enddo
  enddo
  nadd=mode64

  call extract(s3,nadd,ncount,decoded)     !Extract the message
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
