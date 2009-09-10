program WSJT8codes

! Documents the WSJT8 protocols by producing examples of source encoding, 
! error-control encoding, bit and symbol ordering, and other essential 
! details for each implemented mode.

  character*24 msg,msg0,msg1
  character*80 infile
  character cmode*5,cerr*1
  integer iu0(3)                                !Source-encoded data
  integer iu(3)                                 !Recovered data
  integer gsym(63)                              !Generated channel symbols
  
  nargs=iargc()
  if(nargs.lt.2 .or. nargs.gt.3) then
     print*,'Usage: WSJT8code "message" mode'
     print*,'       WSJT8code -f infile mode'
     go to 999
  endif

  call getarg(1,msg0)                     !Retrieve message from command line
  if(msg0(1:2).eq.'-f') then
     call getarg(2,infile)
     open(10,file=infile,status='old')
     call getarg(3,cmode)
     iters=999
  else
     iters=1
     call getarg(2,cmode)
  endif

  if(iters.gt.1) write(*,1000) 
1000 format('Message',16x,'Bits  Source-encoded data',11x,             &
          'Decoded message'/79('-'))

  do iter=1,iters
     if(iters.gt.1) read(10,1002,end=999) msg0
1002 format(a24)
     call msgtrim(msg0,msglen)
     if(msg0(1:1).eq.' ') then
        write(*,1002) 
        go to 100
     endif

! Source-encode the message:
     msg1=msg0
     call srcenc(cmode,msg1,nbit,iu0)
! Message length will be nbit=2, 30, 48, or 78

     if(nbit.eq.2) then
        iu=iu0
     else
! Apply FEC and do the channel encoding
        call chenc(cmode,nbit,iu0,gsym)
! Decode channel symbols to recover source-encoded message bits
        call chdec(cmode,nbit,gsym,iu)
     endif

! Remove source encoding, recover the human-readable message.
     call srcdec(cmode,nbit,iu,msg)

     cerr=' '
     if(msg.ne.msg0) cerr='*'
     write(*,1010) msg0,nbit,iu0,cerr,msg(:14)
1010 format(a24,i3,1x,3z9,2x,a1,1x,a14)

100  continue
  enddo

999 end program WSJT8codes
