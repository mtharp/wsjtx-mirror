subroutine gen4(msg0,ichk,msgsent,i4tone,itype)

! Encode a JT4 message.  Returns msgsent, the message as it will be
! decoded, an integer array i4tone(206) of 4-FSK tons values in the
! range 0-3; and itype, the JT message type.  

  use jt4
  character*22 msg0
  character*22 message          !Message to be generated
  character*22 msgsent          !Message as it will be received
  integer i4tone(206)
  integer*4 i4Msg6BitWords(13)            !72-bit message as 6-bit words
  integer mettab(-128:127,0:1)
  save

  call getmet4(mettab,ndelta)

  message=msg0
  call fmtmsg(message,iz)
  call packmsg(message,i4Msg6BitWords,itype)  !Pack into 12 6-bit bytes
  call unpackmsg(i4Msg6BitWords,msgsent)      !Unpack to get msgsent
  if(ichk.ne.0) go to 999
  call encode4(message,i4tone)            !Encode the information bits

  i4tone=2*i4tone + npr(2:)               !Data = MSB, sync = LSB

999 return
end subroutine gen4
