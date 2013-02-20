subroutine encode4(message,ncode)

  parameter (MAXCALLS=7000,MAXRPT=63)
  integer ncode(206)
  character*22 message          !Message to be generated
  character*3 cok               !'   ' or 'OOO'
  integer dgen
  integer*1 data0(13),symbol(206)
  logical text
  common/jt4com1/dgen(13)

  call chkmsg(message,cok,nspecial,flip)
  call packmsg(message,dgen,text)  !Pack 72-bit message into 12 six-bit symbols
  call entail(dgen,data0)
  call encode232(data0,206,symbol)       !Convolutional encoding
  call interleave4(symbol,1)             !Apply JT4 interleaving
  do i=1,206
     ncode(i)=symbol(i)
  enddo

end subroutine encode4
