program jt4code

! Provides examples of message packing, bit and symbol ordering,
! convolutional encoding, and other necessary details of the JT4
! protocol.

  character*22 msg0,msg,decoded
  character*72 c72
  integer   dgen(12)
  integer*1 symbol(206)
  integer*1 data0(13)
  integer*1 data1(13)                   !Decoded data (8-bit bytes)
  integer data4a(9)                   !Decoded data (8-bit bytes)
  integer data4(12)                   !Decoded data (6-bit bytes)
  integer ncode(206)
  integer iknown(72)
  integer imsg(72)
  real*4  sym(0:1,206)
  common/scalecom/scale

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: JT65code "message"'
     go to 999
  endif
  call getarg(1,msg0)                     !Get message from command line
  msg=msg0

  write(*,1020) msg0
1020 format('Message:   ',a22)            !Echo input message

  call encode4(msg,imsg,ncode)
  if(imsg(57).ne.0) write(*,1030)         !Is the free-text bit set?
1030 format('Free text.')
  write(*,1040) imsg
1040 format(/'Source-encoded message, 72 bits:'/(50i1))

  symbol=ncode
  call interleave4(symbol,1)
  write(*,1050) symbol
1050 format(/'Channel symbols, 206 bits:'/(50i1))

  do i=1,206
     if(symbol(i).eq.0) then
        sym(0,i)=5.
        sym(1,i)=1.
     else
        sym(1,i)=5.
        sym(0,i)=1.
     endif
  enddo
  call interleave4a(sym,-1)

  scale=10.0
  nadd=1
  amp=5.0
  iknown=0
  imsg=0
  nbits=72+31
  ndelta=30
  limit=100

  call fano232(sym,nadd,amp,iknown,imsg,nbits,ndelta,limit,data1,    &
       ncycles,metric,ncount)
  nlim=ncycles/nbits

  if(ncount.ge.0) then
     do i=1,9
        i4=data1(i)
        if(i4.lt.0) i4=i4+256
        data4a(i)=i4
     enddo
     write(c72,1100) (data4a(i),i=1,9)
1100 format(9b8.8)
     read(c72,1102) data4
1102 format(12b6)
     call unpackmsg(data4,decoded)
     write(*,1060) decoded
1060 format(/'Decoded message: ',a22)
  else
     print*,'Error: Fano decoder failed.'
  endif

999 end program jt4code
