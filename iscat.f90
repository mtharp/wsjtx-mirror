subroutine iscat(dat,jz,cfile6,MinSigdB,NFreeze,MouseDF,DFTolerance,    &
          NSyncOK,ccfblue,ccfred)

  real dat(jz)                !Raw audio data
  integer DFTolerance
  real s2(64,63)              !2D spectral array
  character cfile6*6,cf*1
  real ccfblue(-5:540),ccfred(-224:224)
  character decoded*24

  NsyncOK=0
  nfft=1024                   !Do FFTs of twice the symbol length
  nstep=128                   !Step by 1/4 symbols
  df=12000.0/nfft

  call synciscat(dat,jz,DFTolerance,NFreeze,MouseDF,                &
     dtx,dfx,snrx,snrsync,isbest,ccfblue,ccfred,s2)

  nadd=1
  call extract(s2,nadd,isbest,ncount,decoded)     !Extract the message

  nsync=nint(snrsync-2.0)
  nsnr=nint(snrx)
  if(nsnr.lt.-30 .or. nsync.lt.0) nsync=0
  nsnrlim=-32
  jdf=nint(dfx)
  cf=' '
  if(nsync.ge.1) cf='*'
  call cs_lock('iscat')
  write(11,1010) cfile6,nsync,nsnr,jdf,isbest,cf,decoded
1010 format(a6,i4,i5,i5,i3,a1,3x,a24)
  call cs_unlock

  return
end subroutine iscat
