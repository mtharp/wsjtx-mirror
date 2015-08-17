subroutine genmsk(msg0,ichk,msgsent,itone,itype)

! Encodes a JTMSK message and returns msgsent, the message as it will
! be decoded, and an integer array i4tone(231) of MSK tone values 
! in the range 0-1.  

!  use packjt
  character*22 msg0
!  character*22 message                    !Message to be generated
  character*22 msgsent                    !Message as it will be received
!  integer*4 i4Msg6BitWords(13)            !72-bit message as 6-bit words
!  integer*1 i1Msg8BitBytes(13)            !72 bits and zero tail as 8-bit bytes
!  integer*1 i1EncodedBits(198)            !Encoded information-carrying bits
!  integer*1 i1ScrambledBits(207)          !Encoded bits after interleaving
  real xmsg(231)
  integer imsg(231)
  integer itone(231)                   !Tone #s, data and sync (values 0-1)
  integer b11(11)
  data b11/1,1,1,0,0,0,1,0,0,1,0/         !Barker 11 code

!  include 'jt9sync.f90'
  save

  call random_number(xmsg)
  where(xmsg.gt.0.5)
     imsg=1
  elsewhere
     imsg=0
  endwhere

  itone(1:11)=b11
  itone(12:76)=imsg(1:65)
  itone(77:87)=b11
  itone(88:153)=imsg(66:131)
  itone(154:164)=b11
  itone(165:231)=imsg(132:198)

  write(*,3001) itone
3001 format(70i1)

  ichk=0
  itype=0
  msgsent=msg0

  return
end subroutine genmsk
