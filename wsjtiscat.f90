subroutine wsjtiscat(dat,jz,cfile6,MinSigdB,NSyncOK,s2,psavg)

  parameter (NZMAX=3100)
  real dat(jz)                !Raw audio data
  integer DFTolerance
  real s2(64,NZMAX)        !2D spectral array
  character*6 cfile6

  nchan=64                   !Save 64 spectral channels
  nstep=240                  !Set step size to ~20 ms
  nz=jz/nstep                !# of spectra to compute
  NsyncOK=0


! Compute the 2D spectrum.
  df=12000.0/256.0            !FFT resolution ~47 Hz
  dtbuf=nstep/12000.0
  stlim=nslim2                !Single-tone threshold
  print*,'a',jz,nstep,nchan,nz
  call spec2d(dat,jz,nstep,s2,nchan,nz,psavg,sigma)
  print*,'b',nz,sigma
  dftolerance=400
  istart=1

  call cs_lock('mtdecode')
  write(11,1050) cfile6
1050 format(a6,'  hello from wsjtiscat')
  call cs_unlock

  call s2shape(s2,nchan,nz,tbest)
  print*,'c',nchan,nz,tbest,s2(1,1),s2(2,1)

  return
end subroutine wsjtiscat
