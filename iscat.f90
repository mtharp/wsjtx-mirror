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

  print*,'A',jz,Nfreeze,MouseDF,DFTolerance
  call synciscat(dat,jz,DFTolerance,NFreeze,MouseDF,                &
     dtx,dfx,snrx,snrsync,ccfblue,ccfred1,isbest)
  print*,'C'

  call cs_lock('mtdecode')
  write(11,1050) cfile6
1050 format(a6,'  hello from wsjtiscat')
  call cs_unlock

! Compute 2D spectrum for display
  nchan=64                   !Save 64 spectral channels
  nstep=240                  !Set step size to ~20 ms
  nz=jz/nstep                !# of spectra to compute  
!  call spec2d(dat,jz,nstep,s2,nchan,nz,psavg,sigma)
!  call s2shape(s2,nchan,nz,tbest)

  print*,'D'
  return
end subroutine iscat
