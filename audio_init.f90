!------------------------------------------------ audio_init
subroutine audio_init(ndin,ndout)

  include 'gcom1.f90'
  include 'gcom2.f90'

  nmode=2
  if(mode(5:5).eq.'A') mode65=1
  if(mode(5:5).eq.'B') mode65=2
  if(mode(5:5).eq.'C') mode65=4
  ndevout=ndout
  TxOK=0
  Transmitting=0
  nfsample=11025
  nspb=1024
  nbufs=2048
  nmax=nbufs*nspb
  nwave=60*nfsample
  ngo=1
  f0=800.0
  do i=1,nwave
     iwave(i)=nint(32767.0*sin(6.283185307*i*f0/nfsample))
  enddo

  ierr=start_threads(ndevin,ndevout,y1,y2,nmax,iwrite,iwave,nwave,    &
       11025,NSPB,TRPeriod,TxOK,ndebug,Transmitting,            &
       Tsec,ngo,nmode,tbuf,ibuf,ndsec,PttPort,devin_name,devout_name)

  return
end subroutine audio_init
