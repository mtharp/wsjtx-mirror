subroutine srcenc(cmode,msg,nbit,iu)

! Source-encode a user message

! nbit - message length in bits
!-----------------------------------------------------
!   2: shorthand
!  30: 28+2 = nc1+n2
!  48: 28+15+5 = nc1+ngph+n5
!  78: 28+28+15+1+2+3+1 = nc1+nc2+ngph+n2+(n1+n3)+ntext
! nw     - number of words
! len(7) - length of each word in characters
! nt1(7) - type of each word
! n5    - 5-bit or 6-bit value, determines 48-bit message type
! nt1 Word type
!----------------------
!  0  other
!  1  call 
!  2  p/call or call/s
!  3  hcall
!  4  grid
!  5  CQ
!  6  DE
!  7  QRZ
!  8  OOO
!  9  RO
! 10  RRR
! 11  73
! 12  TNX
! 13  OP
! 14  GRID?
! 15  nnn

  parameter (NBASE=37*36*10*27*27*27)
  character*5 cmode
  character*24 msg
  character*14 w(7)
  character pfx*3,sfx*1
  integer lenw(7),nt1(7)
  integer iu(3)
  
  w=''
  lenw=0
  nt1=0

  nbit=-1
  nc1=-1
  nc2=-1
  ngph=-1
  n2=-1
  n5=-1
  pfx='   '
  sfx=' '
  iu=0

  i1=index(msg,' 26 ')
  if(cmode.eq.'JTMS' .and. i1.ge.4) then
     msg=msg(:i1)//'OOO'//msg(i1+3:)
  endif
  i1=index(msg,' R26 ')
  if(cmode.eq.'JTMS' .and. i1.ge.4) then
     msg=msg(:i1)//'RO'//msg(i1+4:)
  endif

  call parse(msg,msglen,w,nw,lenw,nt1,pfx,sfx)
  if(nw.lt.1) go to 10                 !Error return, blank message

! Shorthand messages
  if(nw.eq.1) then
     if(w(1).eq.'RO') then
        iu(1)=ishft(1,30)
        nbit=2
     else if(w(1).eq.'RRR') then
        iu(1)=ishft(2,30)
        nbit=2
     else if(w(1).eq.'73') then
        iu(1)=ishft(3,30)
        nbit=2
     endif
     if(nbit.eq.2) go to 10
  endif

  call pk30(w,nw,nt1,nbit,nc1,n2)
  if(nbit.eq.30) then
     iu(1)=4*nc1+n2
     iu(1)=ishft(nc1,4) + ishft(n2,2)
     go to 10
  endif

  call pk48(w,nw,nt1,pfx,sfx,nbit,nc1,ngph,n5)
  if(nbit.eq.48) then
     iu(1)=ishft(nc1,4) + iand(ishft(ngph,-11),15)
     m11=2**11 - 1
     iu(2)=ishft(iand(ngph,m11),21) + ishft(n5,16)
     go to 10
  endif

  nbit=78
  call pk78(msg,w,nw,nt1,nc1,nc2,ngph,n2,n5,iu)
  if(iand(n5,1).eq.0) then
     iu(1)=ishft(nc1,4) + iand(ishft(nc2,-24),15)
     iu(2)=ishft(nc2,8) + iand(ishft(ngph,-7),255)
     iu(3)=ishft(ngph,25) + ishft(iand(n2,3),23) + ishft(n5,18)
  else
     nc1=ishft(iu(1),-4)
     nc2=ishft(iand(iu(1),15),24) + ishft(iu(2),-8)
     ngph=ishft(iand(iu(2),255),7) + ishft(iu(3),-25)
     n2=iand(ishft(iu(3),-23),3)
  endif

10 continue

  return
end subroutine srcenc
