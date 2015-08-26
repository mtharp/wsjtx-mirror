program JTMSKcode

! Generate simulated data for testing of JTMSK

  use packjt
  character msg*22,decoded*22,bad*1,msgtype*13
  integer*4 i4tone(234)                   !Channel symbols (values 0-1)
  integer*1 e1(201)
  integer*1 r1(201)
  integer*1 d8(13)
  integer mettab(0:255,0:1)               !Metric table for BPSK modulation
  integer*1 i1hash(4)
  integer*4 i4Msg6BitWords(12)            !72-bit message as 6-bit words
  character*72 c72
!  real*8 twopi,dt,f0,f1,f,phi,dphi
  equivalence (ihash,i1hash)

  include 'testmsg.f90'

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: JTMSKcode "message"'
!     print*,'       JTMSKcode -t'
     go to 999
  endif

  call getarg(1,msg)
  nmsg=1
  if(msg(1:2).eq."-t") nmsg=NTEST


  open(10,file='bpskmetrics.dat',status='old')
  bias=0.5
  scale=20.0
  do i=0,255
     read(10,*) xjunk,x0,x1
     mettab(i,0)=nint(scale*(x0-bias))
     mettab(i,1)=nint(scale*(x1-bias))
  enddo


  write(*,1010)
1010 format("     Message                 Decoded                Err? Type"/   &
            74("-"))
  do imsg=1,nmsg
     if(nmsg.gt.1) msg=testmsg(imsg)
     call fmtmsg(msg,iz)                !To upper case, collapse multiple blanks
     ichk=0
     call genmsk(msg,ichk,decoded,i4tone,itype)   !Encode message into tone #s
     msgtype=""
     if(itype.eq.1) msgtype="Std Msg"
     if(itype.eq.2) msgtype="Type 1 prefix"
     if(itype.eq.3) msgtype="Type 1 suffix"
     if(itype.eq.4) msgtype="Type 2 prefix"
     if(itype.eq.5) msgtype="Type 2 suffix"
     if(itype.eq.6) msgtype="Free text"

! Extract the data symbols, skipping over sync and parity bits
     n1=35
     n2=69
     n3=94

     r1(1:n1)=i4tone(11+1:11+n1)
     r1(n1+1:n1+n2)=i4tone(23+n1+1:23+n1+n2)
     r1(n1+n2+1:n1+n2+n3)=i4tone(35+n1+n2+1:35+n1+n2+n3)
     where(r1.eq.0) r1=127
     where(r1.eq.1) r1=-127

     j=0
     do i=1,99
        j=j+1
        e1(j)=r1(i)
        j=j+1
        e1(j)=r1(i+99)
     enddo

     do i=1,198
        n=0
        if(e1(i).lt.0) n=1
        write(41,4001) i,n
4001    format(2i5)
     enddo

     nb1=87
     call vit213(e1,nb1,mettab,d8,metric)

     ihash=nhash(d8,9,146)
     ihash=2*iand(ihash,32767)
     decoded="                      "
     if(d8(10).eq.i1hash(2) .and. d8(11).eq.i1hash(1)) then
        write(c72,1012) d8(1:9)
1012    format(9b8.8)
        read(c72,1014) i4Msg6BitWords
1014    format(12b6.6)
        call unpackmsg(i4Msg6BitWords,decoded)      !Unpack to get msgsent
     endif

     bad=" "
     if(decoded.ne.msg) bad="*"
     write(*,1020) imsg,msg,decoded,bad,itype,msgtype
1020 format(i2,'.',2x,a22,2x,a22,3x,a1,i3,": ",a13)

  enddo

  if(nmsg.eq.1) then
     open(10,file='JTMSKcode.out',status='unknown')
     do j=1,234
        write(10,1030) j,i4tone(j)
1030    format(2i5)
     enddo
     close(10)
  endif

999 end program JTMSKcode
