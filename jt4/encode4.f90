subroutine encode4(message,imsg,ncode)

  parameter (MAXCALLS=7000,MAXRPT=63)
  integer imsg(72)
  integer ncode(206)
  character*22 message          !Message to be generated
  character*3 cok               !'   ' or 'OOO'
  character*72 c72
  integer dgen(13)
  integer*1 data0(13),symbol(206)
  logical text

  call chkmsg(message,cok,nspecial,flip)
  call packmsg(message,dgen,text)  !Pack 72-bit message into 12 six-bit symbols
  write(c72,1000) dgen(1:12)
1000 format(12b6.6)
  read(c72,1010) imsg
1010 format(72i1)
  call entail(dgen,data0)
  call encode232(data0,206,symbol)       !Convolutional encoding
  do i=1,206
     ncode(i)=symbol(i)
  enddo

end subroutine encode4
