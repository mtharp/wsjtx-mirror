subroutine jt8(dat,jz,cfile6,MinSigdB,DFTolerance,NFreeze,              &
             MouseDF2,NSyncOK,ccfblue,ccfred)

! Orchestrates the process of decoding JT8 messages, using data that
! have been 2x downsampled.  The search for shorthand messages has
! already been done.

  real dat(jz)                        !Raw data
  integer DFTolerance
  real ccfblue(-5:540),ccfred(-224:224)
  character line*90,decoded*24,deepmsg*24,special*5
  character csync*1,cfile6*6

! Attempt to synchronize: get DF and DT.
  call syncjt8(dat,jz,DFTolerance,NFreeze,MouseDF,dtx,dfx,snrx,      &
       snrsync,ccfblue,ccfred)
  nsync=nint(snrsync)
  nsnr=nint(snrx)
  ncount=0
  decoded='                        '

! If we get here, we have achieved sync!
  NSyncOK=1
  csync='*'
  ndf=nint(dfx)

  call cs_lock('jt8')
  write(11,1010) cfile6,nsync,nsnr,dtx,ndf,csync,decoded
1010 format(a6,i3,i5,f5.1,i5,1x,a1,1x,a24)
  call cs_unlock

  return
end subroutine jt8
