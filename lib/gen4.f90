subroutine gen4(msg0,ichk,msgsent,i4tone,itype)

! Encode a JT4 message and returns msgsent, the message as it will be
! decodes; an integer array i4tone(207) of 4-FSK tons values in the
! range 0-3; and itype, the JT message type.  (If ichk is nonzero, the
! tones are not computed.)

  character*22 msg0
  character*22 message          !Message to be generated
  character*22 msgsent          !Message as it will be received
!  character*3 cok               !'   ' or 'OOO'
  integer i4tone(206)
  integer dgen(12)
!  integer*1 data1(13)
  integer*1 symbol(216)
  integer npr(207)
  data npr/                                                         &
       0,0,0,0,1,1,0,0,0,1,1,0,1,1,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0, &
       0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,0,0, &
       1,0,0,1,0,0,1,1,1,1,1,0,0,0,1,0,1,0,0,0,1,1,1,1,0,1,1,0,0,1, &
       0,0,0,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,0,1,0,1, &
       0,1,1,1,0,0,1,0,1,1,0,1,1,1,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,1, &
       0,1,1,1,0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1, &
       1,0,0,1,1,0,0,0,0,1,1,0,0,0,1,0,1,1,0,1,1,1,1,0,1,0,1/
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

!###
  
  call packmsg(message,dgen,itype)  !Pack 72-bit message into 12 six-bit symbols
!  write(*,1020) msg0
!1020 format('Message:   ',a22)            !Echo input message
!  if(iand(dgen(10),8).ne.0) write(*,1030) !Is the plain text bit set?
!1030 format('Plain text.')         
!  write(*,1040) dgen
!1040 format(/'Source-encoded message, 6-bit symbols: '/12i3)
!  write(*,1041) dgen
!1041 format(/'Source-encoded message, 72 bits: '/12b6.6)

  call encode4(message,i4tone)
  symbol(1:206)=i4tone
  call interleave4(symbol,-1)         !Remove interleaving

!  write(*,1050) symbol(1:206)
!1050 format(/'Encoded information before interleaving, 206 bits:'/(70i1))

!  write(*,1051) i4tone(1:206)
!1051 format(/'Encoded information after interleaving, 206 bits:'/(70i1))

  do i=1,206                          !Compute channel symbols, sync+2*data
     i4tone(i)=2*i4tone(i)+npr(i+1)
  enddo

!###

  nsym=207                               !Symbols per transmission

  if(flip.lt.0.0 .and. (ngrid.lt.32402 .or. ngrid.gt.32464)) then
     do i=22,1,-1
        if(msgsent(i:i).ne.' ') exit
     enddo
     msgsent=msgsent(1:i)//' OOO'
  endif
  do i=22,1,-1
     if(msgsent(i:i).ne.' ') goto 20
  enddo
20 nmsg=i

  return
end subroutine gen4

