subroutine genmsk(msg0,ichk,msgsent,i4tone,itype)

! Encodes a JTMSK message and returns msgsent, the message as it will
! be decoded, and an integer array i4tone(231) of MSK tone values 
! in the range 0-1.  

  use packjt
  character*22 msg0
  character*22 message                    !Message to be generated
  character*22 msgsent                    !Message as it will be received
  integer*4 i4Msg6BitWords(13)            !72-bit message as 6-bit words
  integer*1 i1Msg8BitBytes(13)            !72 bits and zero tail as 8-bit bytes
  integer*1 i1EncodedBits(198)            !Encoded information-carrying bits
!  integer*1 i1ScrambledBits(207)          !Encoded bits after interleaving
  integer i4tone(231)                   !Tone #s, data and sync (values 0-1)
  integer*1 i1hash(4)
  integer b11(11)
  data b11/1,1,1,0,0,0,1,0,0,1,0/         !Barker 11 code
  equivalence (ihash,i1hash)
  save

  if(msg0(1:1).eq.'@') then
     read(msg0(2:5),*,end=1,err=1) nfreq
     go to 2
1    nfreq=1000
2    i4tone(1)=nfreq
  else
     message=msg0
     do i=1,22
        if(ichar(message(i:i)).eq.0) then
           message(i:)='                      '
           exit
        endif
     enddo

     do i=1,22                               !Strip leading blanks
        if(message(1:1).ne.' ') exit
        message=message(i+1:)
     enddo

     call packmsg(message,i4Msg6BitWords,itype)  !Pack into 12 6-bit bytes
     call unpackmsg(i4Msg6BitWords,msgsent)      !Unpack to get msgsent
     if(ichk.ne.0) go to 999
     call entail(i4Msg6BitWords,i1Msg8BitBytes)  !Add tail, make 8-bit bytes
!     write(*,3001) i4Msg6BitWords(1:12)
!3001 format(12b6.6)
!     write(*,3002) i1Msg8BitBytes(1:9)
!3002 format(9b8.8)

     ihash=nhash(i1Msg8BitBytes,9,146)
     ihash=2*iand(ihash,32767)
     i1Msg8BitBytes(10)=i1hash(2)
     i1Msg8BitBytes(11)=i1hash(1)
!     write(*,3010) ihash,i1Msg8BitBytes(10:11)
!3010 format(/b16.16/b8.8,b8.8)
!     print*,i1Msg8BitBytes(1:11)

     nsym=198
     kc=13
     nc=2
     nbits=87
     call enc213(i1Msg8BitBytes,nbits,i1EncodedBits,nsym,kc,nc)

! Insert sync symbols
     i4tone(1:11)=b11
     i4tone(12:76)=i1EncodedBits(1:65)
     i4tone(77:87)=b11
     i4tone(88:153)=i1EncodedBits(66:131)
     i4tone(154:164)=b11
     i4tone(165:231)=i1EncodedBits(132:198)
  endif
     
999 return
end subroutine genmsk
