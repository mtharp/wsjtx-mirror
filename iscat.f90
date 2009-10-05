subroutine iscat(dat,jz,cfile6,MinSigdB,NFreeze,MouseDF,DFTolerance,    &
          NSyncOK,ccfblue,ccfred)

  parameter (NZMAX=3100)
  real dat(jz)                !Raw audio data
  integer DFTolerance
  real s2(64,NZMAX)        !2D spectral array
  character*6 cfile6
  real ccfblue(-5:540),ccfred(-224:224)

  NsyncOK=0
  nfft=1024                   !Do FFTs of twice the symbol length
  nstep=128                   !Step by 1/4 symbols
  df=12000.0/nfft

  call synciscat(dat,jz,DFTolerance,NFreeze,MouseDF,                &
     dtx,dfx,snrx,snrsync,isbest,ccfblue,ccfred1)

  nsync=nint(snrsync-2.0)
  nsnr=nint(snrx)
  if(nsnr.lt.-30 .or. nsync.lt.0) nsync=0
  nsnrlim=-32
  jdf=nint(dfx)

  call cs_lock('mtdecode')
  write(11,1010) cfile6,nsync,nsnr,jdf,isbest
1010 format(a6,i4,i5,i5,i3)

  call cs_unlock

! Compute 2D spectrum for display
!  nchan=64                   !Save 64 spectral channels
!  nstep=240                  !Set step size to ~20 ms
!  nz=jz/nstep                !# of spectra to compute  
!  call spec2d(dat,jz,nstep,s2,nchan,nz,psavg,sigma)
!  call s2shape(s2,nchan,nz,tbest)

  return
end subroutine iscat
