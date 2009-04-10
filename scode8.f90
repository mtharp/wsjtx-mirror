program scode8

!  Tests source encoding of WSJT8 messages: modes I-Scat, M-Scat, JT64

  character*22 msg0,msg,decoded,cok*3
  integer dgen(12),sent(63),recd(12),era(51)

      nargs=iargc()
      if(nargs.ne.1) then
         print*,'Usage: scode8 "message"'
         go to 999
      endif

      call getarg(1,msg0)                     !Get message from command line
      msg=msg0

      call chkmsg(msg,cok,nspecial,flip)      !See if it includes "OOO" report
      if(nspecial.gt.0) then                  !or is a shorthand message
         write(*,1010) 
 1010    format('Shorthand message.')
         go to 999
      endif

      call packmsg(msg,dgen)                  !Pack message into 72 bits
      write(*,1020) msg0
 1020 format('Message:   ',a22)               !Echo input message
      if(iand(dgen(10),8).ne.0) write(*,1030)  !Is the plain text bit set?
 1030 format('Plain text.')         
      write(*,1040) dgen
 1040 format('Packed message, 6-bit symbols: ',12i3) !Display packed symbols

      call unpackmsg(dgen,decoded)            !Unpack the user message
      write(*,1060) decoded,cok
 1060 format('Decoded message: ',a22,2x,a3)
 999  end
