subroutine gen65(msg0,ichk,msgsent,itone,itext)

! Encodes a JT65 message to yieild itone(1:126)
! Temporarily, does not implement EME shorthands

  character*22 msg0
  character*22 message          !Message to be generated
  character*22 msgsent          !Message as it will be received
  integer itone(126)
  character*3 cok               !'   ' or 'OOO'
  integer dgen(13)
  integer sent(63)
  logical text
  integer nprc(126)
  data nprc/1,0,0,1,1,0,0,0,1,1,1,1,1,1,0,1,0,1,0,0,  &
            0,1,0,1,1,0,0,1,0,0,0,1,1,1,0,0,1,1,1,1,  &
            0,1,1,0,1,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,  &
            0,0,1,1,0,1,0,1,0,1,0,0,1,0,0,0,0,0,0,1,  &
            1,0,0,0,0,0,0,0,1,1,0,1,0,0,1,0,1,1,0,1,  &
            0,1,0,1,0,0,1,1,0,0,1,0,0,1,0,0,0,0,1,1,  &
            1,1,1,1,1,1/
  save

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

  write(39,*) 'A'; flush(39)
  nspecial=0
!  call chkmsg(message,cok,nspecial,flip)
  if(nspecial.eq.0) then
     call packmsg(message,dgen,text)     !Pack message into 72 bits
     write(39,*) 'B'; flush(39)
     itext=0
     if(text) itext=1
     call unpackmsg(dgen,msgsent)        !Unpack to get message sent
     write(39,*) 'C'; flush(39)
     if(ichk.ne.0) go to 999             !Return if checking only

     nsendingsh=0
     call rs_encode(dgen,sent)           !Apply Reed-Solomon code
  write(39,*) 'D'; flush(39)
     call interleave63(sent,1)           !Apply interleaving
  write(39,*) 'E'; flush(39)
     call graycode65(sent,63,1)          !Apply Gray code
  write(39,*) 'F'; flush(39)
     nsym=126                            !Symbols per transmission
     nsps=4096
  else
     nsym=32
     nsps=16384
     nsendingsh=1                         !Flag for shorthand message
  endif

  k=0
  do j=1,nsym
     if(nprc(j).eq.0) then
        k=k+1
        itone(j)=sent(k)+2
     else
        itone(j)=0
     endif
  enddo

999 return
end subroutine gen65
