program jt4code

! Provides examples of message packing, bit and symbol ordering,
! convolutional encoding, and other necessary details of the JT4
! protocol.

  character*22 msg0,msg,decoded
  character*72 c72
  integer   dgen(12)
  integer*1 symbol(216)
  integer*1 data1(13)                   !Decoded data (8-bit bytes)
  integer   data4a(9)                   !Decoded data (8-bit bytes)
  integer   data4(12)                   !Decoded data (6-bit bytes)
  integer mettab(0:255,0:1)             !Metric table
  integer ncode(206)
  integer npr(207)
  data npr/                                                         &
       0,0,0,0,1,1,0,0,0,1,1,0,1,1,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0, &
       0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,0,0, &
       1,0,0,1,0,0,1,1,1,1,1,0,0,0,1,0,1,0,0,0,1,1,1,1,0,1,1,0,0,1, &
       0,0,0,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,0,1,0,1, &
       0,1,1,1,0,0,1,0,1,1,0,1,1,1,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,1, &
       0,1,1,1,0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1, &
       1,0,0,1,1,0,0,0,0,1,1,0,0,0,1,0,1,1,0,1,1,1,1,0,1,0,1/


  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: JT65code "message"'
     go to 999
  endif
  call getmet4(7,mettab)
  call getarg(1,msg0)                     !Get message from command line
  msg=msg0

  call packmsg(msg,dgen)         !Pack 72-bit message into 12 six-bit symbols
  write(*,1020) msg0
1020 format('Message:   ',a22)            !Echo input message
  if(iand(dgen(10),8).ne.0) write(*,1030) !Is the plain text bit set?
1030 format('Plain text.')         
  write(*,1040) dgen
1040 format(/'Source-encoded message, 6-bit symbols: '/12i3)
  write(*,1041) dgen
1041 format(/'Source-encoded message, 72 bits: '/12b6.6)

  call encode4(msg,ncode)
  symbol(1:206)=ncode
  call interleave4(symbol,-1)         !Remove interleaving

  write(*,1050) symbol(1:206)
1050 format(/'Encoded information before interleaving, 206 bits:'/(70i1))

  write(*,1051) ncode(1:206)
1051 format(/'Encoded information after interleaving, 206 bits:'/(70i1))

  do i=1,206                          !Compute channel symbols, sync+2*data
     ncode(i)=2*ncode(i)+npr(i+1)
  enddo

  write(*,1052) npr(2:207)
1052 format(/'Sync vector, 206 bits:'/(70i1))

  write(*,1060) ncode(1:206)
1060 format(/'Channel symbols, 206 x 4-FSK symbols:'/(70i1))

  do i=1,206
     if(symbol(i).eq.1) then
        symbol(i)=-118
     else
        symbol(i)=118
     endif
  enddo

  nbits=72+31
  ndelta=50
  limit=100
  call fano232(symbol,nbits,mettab,ndelta,limit,data1,ncycles,metric,ncount)

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
     write(*,1070) decoded
1070 format(/'Decoded message: ',a22)
  endif

999 end program jt4code
