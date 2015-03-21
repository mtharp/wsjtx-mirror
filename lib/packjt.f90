module packjt

  contains

subroutine packbits(dbits,nsymd,m0,sym)

! Pack 0s and 1s from dbits() into sym() with m0 bits per word.
! NB: nsymd is the number of packed output words.

  integer sym(nsymd)
  integer*1 dbits(*)

  k=0
  do i=1,nsymd
     n=0
     do j=1,m0
        k=k+1
        m=dbits(k)
        n=ior(ishft(n,1),m)
     enddo
     sym(i)=n
  enddo

  return
end subroutine packbits

subroutine unpackbits(sym,nsymd,m0,dbits)

! Unpack bits from sym() into dbits(), one bit per byte.
! NB: nsymd is the number of input words, and m0 their length.
! there will be m0*nsymd output bytes, each 0 or 1.

  integer sym(nsymd)
  integer*1 dbits(*)

  k=0
  do i=1,nsymd
     mask=ishft(1,m0-1)
     do j=1,m0
        k=k+1
        dbits(k)=0
        if(iand(mask,sym(i)).ne.0) dbits(k)=1
        mask=ishft(mask,-1)
     enddo
  enddo

  return
end subroutine unpackbits

subroutine packcall(callsign,ncall,text)

! Pack a valid callsign into a 28-bit integer.

  parameter (NBASE=37*36*10*27*27*27)
  character callsign*6,c*1,tmp*6
  logical text

  text=.false.

! Work-around for Swaziland prefix:
  if(callsign(1:4).eq.'3DA0') callsign='3D0'//callsign(5:6)

  if(callsign(1:3).eq.'CQ ') then
     ncall=NBASE + 1
     if(callsign(4:4).ge.'0' .and. callsign(4:4).le.'9' .and.        &
          callsign(5:5).ge.'0' .and. callsign(5:5).le.'9' .and.      &
          callsign(6:6).ge.'0' .and. callsign(6:6).le.'9') then
        read(callsign(4:6),*) nfreq
        ncall=NBASE + 3 + nfreq
     endif
     return
  else if(callsign(1:4).eq.'QRZ ') then
     ncall=NBASE + 2
     return
  else if(callsign(1:3).eq.'DE ') then
     ncall=267796945
     return
  endif

  tmp='      '
  if(callsign(3:3).ge.'0' .and. callsign(3:3).le.'9') then
     tmp=callsign
  else if(callsign(2:2).ge.'0' .and. callsign(2:2).le.'9') then
     if(callsign(6:6).ne.' ') then
        text=.true.
        return
     endif
     tmp=' '//callsign(:5)
  else
     text=.true.
     return
  endif

  do i=1,6
     c=tmp(i:i)
     if(c.ge.'a' .and. c.le.'z')                                &
          tmp(i:i)=char(ichar(c)-ichar('a')+ichar('A'))
  enddo

  n1=0
  if((tmp(1:1).ge.'A'.and.tmp(1:1).le.'Z').or.tmp(1:1).eq.' ') n1=1
  if(tmp(1:1).ge.'0' .and. tmp(1:1).le.'9') n1=1
  n2=0
  if(tmp(2:2).ge.'A' .and. tmp(2:2).le.'Z') n2=1
  if(tmp(2:2).ge.'0' .and. tmp(2:2).le.'9') n2=1
  n3=0
  if(tmp(3:3).ge.'0' .and. tmp(3:3).le.'9') n3=1
  n4=0
  if((tmp(4:4).ge.'A'.and.tmp(4:4).le.'Z').or.tmp(4:4).eq.' ') n4=1
  n5=0
  if((tmp(5:5).ge.'A'.and.tmp(5:5).le.'Z').or.tmp(5:5).eq.' ') n5=1
  n6=0
  if((tmp(6:6).ge.'A'.and.tmp(6:6).le.'Z').or.tmp(6:6).eq.' ') n6=1

  if(n1+n2+n3+n4+n5+n6 .ne. 6) then
     text=.true.
     return 
  endif

  ncall=nchar(tmp(1:1))
  ncall=36*ncall+nchar(tmp(2:2))
  ncall=10*ncall+nchar(tmp(3:3))
  ncall=27*ncall+nchar(tmp(4:4))-10
  ncall=27*ncall+nchar(tmp(5:5))-10
  ncall=27*ncall+nchar(tmp(6:6))-10

  return
end subroutine packcall

subroutine unpackcall(ncall,word,iv2,psfx)

  parameter (NBASE=37*36*10*27*27*27)
  character word*12,c*37,psfx*4

  data c/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ '/

  word='......' 
  psfx='    '
  n=ncall
  iv2=0
  if(n.ge.262177560) go to 20
  word='......'
!  if(n.ge.262177560) go to 999            !Plain text message ...
  i=mod(n,27)+11
  word(6:6)=c(i:i)
  n=n/27
  i=mod(n,27)+11
  word(5:5)=c(i:i)
  n=n/27
  i=mod(n,27)+11
  word(4:4)=c(i:i)
  n=n/27
  i=mod(n,10)+1
  word(3:3)=c(i:i)
  n=n/10
  i=mod(n,36)+1
  word(2:2)=c(i:i)
  n=n/36
  i=n+1
  word(1:1)=c(i:i)
  do i=1,4
     if(word(i:i).ne.' ') go to 10
  enddo
  go to 999
10 word=word(i:)
  go to 999

20 if(n.ge.267796946) go to 999

! We have a JT65v2 message
  if((n.ge.262178563) .and. (n.le.264002071)) then
! CQ with prefix
     iv2=1
     n=n-262178563
     i=mod(n,37)+1
     psfx(4:4)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(3:3)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(2:2)=c(i:i)
     n=n/37
     i=n+1
     psfx(1:1)=c(i:i)

  else if((n.ge.264002072) .and. (n.le.265825580)) then
! QRZ with prefix
     iv2=2
     n=n-264002072
     i=mod(n,37)+1
     psfx(4:4)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(3:3)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(2:2)=c(i:i)
     n=n/37
     i=n+1
     psfx(1:1)=c(i:i)

  else if((n.ge.265825581) .and. (n.le.267649089)) then
! DE with prefix
     iv2=3
     n=n-265825581
     i=mod(n,37)+1
     psfx(4:4)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(3:3)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(2:2)=c(i:i)
     n=n/37
     i=n+1
     psfx(1:1)=c(i:i)

  else if((n.ge.267649090) .and. (n.le.267698374)) then
! CQ with suffix
     iv2=4
     n=n-267649090
     i=mod(n,37)+1
     psfx(3:3)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(2:2)=c(i:i)
     n=n/37
     i=n+1
     psfx(1:1)=c(i:i)

  else if((n.ge.267698375) .and. (n.le.267747659)) then
! QRZ with suffix
     iv2=5
     n=n-267698375
     i=mod(n,37)+1
     psfx(3:3)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(2:2)=c(i:i)
     n=n/37
     i=n+1
     psfx(1:1)=c(i:i)

  else if((n.ge.267747660) .and. (n.le.267796944)) then
! DE with suffix
     iv2=6
     n=n-267747660
     i=mod(n,37)+1
     psfx(3:3)=c(i:i)
     n=n/37
     i=mod(n,37)+1
     psfx(2:2)=c(i:i)
     n=n/37
     i=n+1
     psfx(1:1)=c(i:i)

  else if(n.eq.267796945) then
! DE with no prefix or suffix
     iv2=7
     psfx = '    '
  endif

999 if(word(1:3).eq.'3D0') word='3DA0'//word(4:)

  return
end subroutine unpackcall

subroutine packgrid(grid,ng,text)

  parameter (NGBASE=180*180)
  character*4 grid
  character*1 c1
  logical text

  text=.false.
  if(grid.eq.'    ') go to 90               !Blank grid is OK

! First, handle signal reports in the original range, -01 to -30 dB
  if(grid(1:1).eq.'-') then
     read(grid(2:3),*,err=800,end=800) n
     if(n.ge.1 .and. n.le.30) then
        ng=NGBASE+1+n
        go to 900
     endif
     go to 10
  else if(grid(1:2).eq.'R-') then
     read(grid(3:4),*,err=800,end=800) n
     if(n.ge.1 .and. n.le.30) then
        ng=NGBASE+31+n
        go to 900
     endif
     go to 10
! Now check for RO, RRR, or 73 in the message field normally used for grid
  else if(grid(1:4).eq.'RO  ') then
     ng=NGBASE+62
     go to 900
  else if(grid(1:4).eq.'RRR ') then
     ng=NGBASE+63
     go to 900
  else if(grid(1:4).eq.'73  ') then
     ng=NGBASE+64
     go to 900
  endif

! Now check for extended-range signal reports: -50 to -31, and 0 to +49.
10 n=99
  c1=grid(1:1)
  read(grid,*,err=20,end=20) n
  go to 30
20 read(grid(2:4),*,err=30,end=30) n
30 if(n.ge.-50 .and. n.le.49) then
     if(c1.eq.'R') then
        write(grid,1002) n+50
1002    format('LA',i2.2)
     else
        write(grid,1003) n+50
1003    format('KA',i2.2)
     endif
     go to 40
  endif

! Maybe it's free text ?
  if(grid(1:1).lt.'A' .or. grid(1:1).gt.'R') text=.true.
  if(grid(2:2).lt.'A' .or. grid(2:2).gt.'R') text=.true.
  if(grid(3:3).lt.'0' .or. grid(3:3).gt.'9') text=.true.
  if(grid(4:4).lt.'0' .or. grid(4:4).gt.'9') text=.true.
  if(text) go to 900

! OK, we have a properly formatted grid locator
40 call grid2deg(grid//'mm',dlong,dlat)
  long=int(dlong)
  lat=int(dlat+ 90.0)
  ng=((long+180)/2)*180 + lat
  go to 900

90 ng=NGBASE + 1
  go to 900

800 text=.true.
900 continue

  return
end subroutine packgrid

subroutine unpackgrid(ng,grid)

  parameter (NGBASE=180*180)
  character grid*4,grid6*6

  grid='    '
  if(ng.ge.32400) go to 10
  dlat=mod(ng,180)-90
  dlong=(ng/180)*2 - 180 + 2
  call deg2grid(dlong,dlat,grid6)
  grid=grid6(:4)
  if(grid(1:2).eq.'KA') then
     read(grid(3:4),*) n
     n=n-50
     write(grid,1001) n
1001 format(i3.2)
     if(grid(1:1).eq.' ') grid(1:1)='+'
  else if(grid(1:2).eq.'LA') then
     read(grid(3:4),*) n
     n=n-50
     write(grid,1002) n
1002 format('R',i3.2)
     if(grid(2:2).eq.' ') grid(2:2)='+'
  endif
  go to 900

10 n=ng-NGBASE-1
  if(n.ge.1 .and.n.le.30) then
     write(grid,1012) -n
1012 format(i3.2)
  else if(n.ge.31 .and.n.le.60) then
     n=n-30
     write(grid,1022) -n
1022 format('R',i3.2)
  else if(n.eq.61) then
     grid='RO'
  else if(n.eq.62) then
     grid='RRR'
  else if(n.eq.63) then
     grid='73'
  endif

900 return
end subroutine unpackgrid

subroutine packmsg(msg,dat,itype)

! Packs a JT4/JT9/JT65 message into twelve 6-bit symbols

! itype Message Type
!--------------------
!   1   Standardd message
!   2   Type 1 prefix
!   3   Type 1 suffix
!   4   Type 2 prefix
!   5   Type 2 suffix
!   6   Free text
!  -1   Does not decode correctly

  parameter (NBASE=37*36*10*27*27*27)
  parameter (NBASE2=262178562)
  character*22 msg
  integer dat(12)
  character*12 c1,c2
  character*4 c3
  character*6 grid6
  logical text1,text2,text3

  itype=1
  call fmtmsg(msg,iz)

  if(msg(1:6).eq.'CQ DX ') msg(3:3)='9'

! See if it's a CQ message
  if(msg(1:3).eq.'CQ ') then
     i=3
! ... and if so, does it have a reply frequency?
     if(msg(4:4).ge.'0' .and. msg(4:4).le.'9' .and.                  &
          msg(5:5).ge.'0' .and. msg(5:5).le.'9' .and.                &
          msg(6:6).ge.'0' .and. msg(6:6).le.'9') i=7
     go to 1
  endif

  do i=1,22
     if(msg(i:i).eq.' ') go to 1       !Get 1st blank
  enddo
  go to 10                             !Consider msg as plain text
      
1 ia=i
  c1=msg(1:ia-1)
  do i=ia+1,22
     if(msg(i:i).eq.' ') go to 2       !Get 2nd blank
  enddo
  go to 10                             !Consider msg as plain text

2 ib=i
  c2=msg(ia+1:ib-1)

  do i=ib+1,22
     if(msg(i:i).eq.' ') go to 3       !Get 3rd blank
  enddo
  go to 10                             !Consider msg as plain text

3 ic=i
  c3='    '
  if(ic.ge.ib+1) c3=msg(ib+1:ic)
  if(c3.eq.'OOO ') c3='    '           !Strip out the OOO flag
  call getpfx1(c1,k1,nv2a)
  if(nv2a.ge.4) go to 10
  call packcall(c1,nc1,text1)
  if(text1) go to 10
  call getpfx1(c2,k2,nv2b)
  call packcall(c2,nc2,text2)
  if(text2) go to 10
  if(nv2a.eq.2 .or. nv2a.eq.3 .or. nv2b.eq.2 .or. nv2b.eq.3) then
     if(k1.lt.0 .or. k2.lt.0 .or. k1*k2.ne.0) go to 10
     if(k2.gt.0) k2=k2+450
     k=max(k1,k2)
     if(k.gt.0) then
        call k2grid(k,grid6)
        c3=grid6(:4)
     endif
  endif
  call packgrid(c3,ng,text3)

  if(nv2a.lt.4 .and. nv2b.lt.4 .and. (.not.text1) .and. (.not.text2) .and.  &
       (.not.text3)) go to 20

  nc1=0
  if(nv2b.eq.4) then
     if(c1(1:3).eq.'CQ ')  nc1=262178563 + k2
     if(c1(1:4).eq.'QRZ ') nc1=264002072 + k2 
     if(c1(1:3).eq.'DE ')  nc1=265825581 + k2
  else if(nv2b.eq.5) then
     if(c1(1:3).eq.'CQ ')  nc1=267649090 + k2
     if(c1(1:4).eq.'QRZ ') nc1=267698375 + k2
     if(c1(1:3).eq.'DE ')  nc1=267747660 + k2
  endif
  if(nc1.ne.0) go to 20

! The message will be treated as plain text.
10 itype=6
  call packtext(msg,nc1,nc2,ng)
  ng=ng+32768

! Encode data into 6-bit words
20 continue
  if(itype.ne.6) itype=max(nv2a,nv2b)
  dat(1)=iand(ishft(nc1,-22),63)                !6 bits
  dat(2)=iand(ishft(nc1,-16),63)                !6 bits
  dat(3)=iand(ishft(nc1,-10),63)                !6 bits
  dat(4)=iand(ishft(nc1, -4),63)                !6 bits
  dat(5)=4*iand(nc1,15)+iand(ishft(nc2,-26),3)  !4+2 bits
  dat(6)=iand(ishft(nc2,-20),63)                !6 bits
  dat(7)=iand(ishft(nc2,-14),63)                !6 bits
  dat(8)=iand(ishft(nc2, -8),63)                !6 bits
  dat(9)=iand(ishft(nc2, -2),63)                !6 bits
  dat(10)=16*iand(nc2,3)+iand(ishft(ng,-12),15) !2+4 bits
  dat(11)=iand(ishft(ng,-6),63)
  dat(12)=iand(ng,63)

  return
end subroutine packmsg

subroutine unpackmsg(dat,msg)

  parameter (NBASE=37*36*10*27*27*27)
  parameter (NGBASE=180*180)
  integer dat(12)
  character c1*12,c2*12,grid*4,msg*22,grid6*6,psfx*4,junk2*4
  logical cqnnn

  cqnnn=.false.
  nc1=ishft(dat(1),22) + ishft(dat(2),16) + ishft(dat(3),10)+         &
       ishft(dat(4),4) + iand(ishft(dat(5),-2),15)

  nc2=ishft(iand(dat(5),3),26) + ishft(dat(6),20) +                   &
       ishft(dat(7),14) + ishft(dat(8),8) + ishft(dat(9),2) +         &
       iand(ishft(dat(10),-4),3)

  ng=ishft(iand(dat(10),15),12) + ishft(dat(11),6) + dat(12)

  if(ng.ge.32768) then
     call unpacktext(nc1,nc2,ng,msg)
     go to 100
  endif

  call unpackcall(nc1,c1,iv2,psfx)
  if(iv2.eq.0) then
! This is an "original JT65" message
     if(nc1.eq.NBASE+1) c1='CQ    '
     if(nc1.eq.NBASE+2) c1='QRZ   '
     nfreq=nc1-NBASE-3
     if(nfreq.ge.0 .and. nfreq.le.999) then
        write(c1,1002) nfreq
1002    format('CQ ',i3.3)
        cqnnn=.true.
     endif
  endif

  call unpackcall(nc2,c2,junk1,junk2)
  call unpackgrid(ng,grid)

  if(iv2.gt.0) then
! This is a JT65v2 message
     do i=1,4
        if(ichar(psfx(i:i)).eq.0) psfx(i:i)=' '
     enddo

     n1=len_trim(psfx)
     n2=len_trim(c2)
     if(iv2.eq.1) msg='CQ '//psfx(:n1)//'/'//c2(:n2)//' '//grid
     if(iv2.eq.2) msg='QRZ '//psfx(:n1)//'/'//c2(:n2)//' '//grid
     if(iv2.eq.3) msg='DE '//psfx(:n1)//'/'//c2(:n2)//' '//grid
     if(iv2.eq.4) msg='CQ '//c2(:n2)//'/'//psfx(:n1)//' '//grid
     if(iv2.eq.5) msg='QRZ '//c2(:n2)//'/'//psfx(:n1)//' '//grid
     if(iv2.eq.6) msg='DE '//c2(:n2)//'/'//psfx(:n1)//' '//grid
     if(iv2.eq.7) msg='DE '//c2(:n2)//' '//grid
     if(iv2.eq.8) msg=' '
     go to 100
  else
     
  endif

  grid6=grid//'ma'
  call grid2k(grid6,k)
  if(k.ge.1 .and. k.le.450)   call getpfx2(k,c1)
  if(k.ge.451 .and. k.le.900) call getpfx2(k,c2)

  i=index(c1,char(0))
  if(i.ge.3) c1=c1(1:i-1)//'            '
  i=index(c2,char(0))
  if(i.ge.3) c2=c2(1:i-1)//'            '

  msg='                      '
  j=0
  if(cqnnn) then
     msg=c1//'          '
     j=7                                  !### ??? ###
     go to 10
  endif

  do i=1,12
     j=j+1
     msg(j:j)=c1(i:i)
     if(c1(i:i).eq.' ') go to 10
  enddo
  j=j+1
  msg(j:j)=' '

10 do i=1,12
     if(j.le.21) j=j+1
     msg(j:j)=c2(i:i)
     if(c2(i:i).eq.' ') go to 20
  enddo
  if(j.le.21) j=j+1
  msg(j:j)=' '

20 if(k.eq.0) then
     do i=1,4
        if(j.le.21) j=j+1
        msg(j:j)=grid(i:i)
     enddo
     if(j.le.21) j=j+1
     msg(j:j)=' '
  endif

100 continue
  if(msg(1:6).eq.'CQ9DX ') msg(3:3)=' '

  return
end subroutine unpackmsg

subroutine packtext(msg,nc1,nc2,nc3)

  parameter (MASK28=2**28 - 1)
  character*13 msg
  character*42 c
  data c/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ +-./?'/

  nc1=0
  nc2=0
  nc3=0

  do i=1,5                                !First 5 characters in nc1
     do j=1,42                            !Get character code
        if(msg(i:i).eq.c(j:j)) go to 10
     enddo
     j=37
10   j=j-1                                !Codes should start at zero
     nc1=42*nc1 + j
  enddo

  do i=6,10                               !Characters 6-10 in nc2
     do j=1,42                            !Get character code
        if(msg(i:i).eq.c(j:j)) go to 20
     enddo
     j=37
20   j=j-1                                !Codes should start at zero
     nc2=42*nc2 + j
  enddo

  do i=11,13                              !Characters 11-13 in nc3
     do j=1,42                            !Get character code
        if(msg(i:i).eq.c(j:j)) go to 30
     enddo
     j=37
30   j=j-1                                !Codes should start at zero
     nc3=42*nc3 + j
  enddo

! We now have used 17 bits in nc3.  Must move one each to nc1 and nc2.
  nc1=nc1+nc1
  if(iand(nc3,32768).ne.0) nc1=nc1+1
  nc2=nc2+nc2
  if(iand(nc3,65536).ne.0) nc2=nc2+1
  nc3=iand(nc3,32767)

  return
end subroutine packtext

subroutine unpacktext(nc1,nc2,nc3,msg)

  character*22 msg
  character*44 c
  data c/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ +-./?'/

  nc3=iand(nc3,32767)                      !Remove the "plain text" bit
  if(iand(nc1,1).ne.0) nc3=nc3+32768
  nc1=nc1/2
  if(iand(nc2,1).ne.0) nc3=nc3+65536
  nc2=nc2/2

  do i=5,1,-1
     j=mod(nc1,42)+1
     msg(i:i)=c(j:j)
     nc1=nc1/42
  enddo

  do i=10,6,-1
     j=mod(nc2,42)+1
     msg(i:i)=c(j:j)
     nc2=nc2/42
  enddo

  do i=13,11,-1
     j=mod(nc3,42)+1
     msg(i:i)=c(j:j)
     nc3=nc3/42
  enddo
  msg(14:22) = '         '

  return
end subroutine unpacktext

end module packjt
