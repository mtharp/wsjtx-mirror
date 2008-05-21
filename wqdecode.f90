subroutine wqdecode(data0,message,ntype)

  parameter (N15=32758)
  integer*1 data0(11)
  character*22 message
  character*12 callsign
  character*3 cdbm
  character*2 crpt
  character*4 grid
  character*9 name
  character*32 fmt
  logical first
  character*12 dcall(0:N15-1)
  data first/.true./
  save first,dcall

  if(first) then
     dcall='            '
     first=.false.
  endif

  message='                      '
  call unpack50(data0,n1,n2)
  call unpackcall(n1,callsign)
  i1=index(callsign,' ')
  call unpackgrid(n2/128,grid)
  ntype=iand(n2,127) -64

! Standard WSPR message (types 0 3 7 10 13 17 ... 60)
  nu=mod(ntype,10)
  if(ntype.ge.0 .and. ntype.le.60 .and. (nu.eq.0 .or. nu.eq.3 .or.   &
       nu.eq.7)) then
     write(cdbm,'(i3)'),ntype
     if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
     if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
     message=callsign(1:i1)//grid//' '//cdbm
     call hash(callsign,i1-1,ih)
     dcall(ih)=callsign(:i1)

! "Best DX" WSPR response (type 1)
  else if(ntype.eq.1) then
     message=grid//' DE '//callsign

! CQ (msg 3; types 2,4,5)
  else if(ntype.eq.2) then
     message='CQ '//callsign(:i1)//grid
     call hash(callsign,i1-1,ih)
     dcall(ih)=callsign(:i1)

! Reply to CQ (msg #2; type 6
  else if(ntype.eq.6) then
     ih=(n2-64-ntype)/128
     if(dcall(ih)(1:1).ne.' ') then
        i2=index(dcall(ih),' ')
        message='<'//dcall(ih)(:i2-1)//'> '//callsign(:i1-1)
     else
        message='<...> '//callsign
     endif
     call hash(callsign,i1-1,ih)
     dcall(ih)=callsign(:i1-1)

! Reply to CQ (msg #2; type 8
  else if(ntype.eq.8) then
     message='DE '//callsign(:i1)//grid
     call hash(callsign,i1-1,ih)
     dcall(ih)=callsign(:i1-1)

! Calls and report (msg #3; types -1 to -9)
  else if(ntype.le.-1 .and. ntype.ge.-9) then
     write(crpt,1010) -ntype
1010 format('S',i1)
     ih=(n2-62-ntype)/128
     if(dcall(ih)(1:1).ne.' ') then
        i2=index(dcall(ih),' ')
        message=callsign(:i1)//'<'//dcall(ih)(:i2-1)//'> '//crpt
     else
        message=callsign(:i1)//'<...> '//crpt
     endif
     call hash(callsign,i1-1,ih)
     dcall(ih)=callsign(:i1-1)

! Calls and R and report (msg #4; types -28 to -36)
  else if(ntype.le.-28 .and. ntype.ge.-36) then
     write(crpt,1010) -(ntype+27)
     ih=(n2-64+28-ntype)/128
     if(dcall(ih)(1:1).ne.' ') then
        i2=index(dcall(ih),' ')
        message=callsign(:i1)//'<'//dcall(ih)(:i2-1)//'> '//'R '//crpt
     else
        message=callsign(:i1)//'<...> '//'R '//crpt
     endif

! Calls and RRR (msg#5; type 12)
  else if(ntype.eq.12) then
     ih=(n2-64+28-ntype)/128
     if(dcall(ih)(1:1).ne.' ') then
        i2=index(dcall(ih),' ')
        message=callsign(:i1)//'<'//dcall(ih)(:i2-1)//'> RRR'
     else
        message=callsign(:i1)//'<...> RRR'
     endif
     call hash(callsign,i1-1,ih)
     dcall(ih)=callsign(:i1-1)

! Calls and RRR (msg#5; type 14)
  else if(ntype.eq.14) then
     ih=(n2-64+28-ntype)/128
     if(dcall(ih)(1:1).ne.' ') then
        i2=index(dcall(ih),' ')
        message='<'//dcall(ih)(:i2-1)//'> '//callsign(:i1)//'RRR'
     else
        message=callsign(:i1)//'<...> RRR'
     endif
     call hash(callsign,i1-1,ih)
     dcall(ih)=callsign(:i1-1)

! TNX [name] 73 GL (msg #6; type 18)
  else if(ntype.eq.18) then
     ng=(n2-18-64)/128
     call unpackname(n1,ng,name,len)
     message='TNX '//name(:len)//' 73 GL'

! OP [name] 73 GL (msg #6; type 18)
  else if(ntype.eq.-56) then
     ng=(n2+56-64)/128
     call unpackname(n1,ng,name,len)
     message='OP '//name(:len)//' 73 GL'

! 73 DE [call] [grid] (msg #6; type 19)
  else if(ntype.eq.19) then
     ng=(n2-19-64)/128
     message='73 DE '//callsign(:i1)//grid
     call hash(callsign,i1-1,ih)
     dcall(ih)=callsign(:i1-1)

! [power] W [gain] DBD 73 GL (msg#6; type 24)
  else if(ntype.eq.24) then
     ng=(n2-24-64)/128 - 32
     i1=1
     if(n1.gt.0) i1=log10(float(n1)) + 1
     i2=1
     if(ng.ge.10) i2=2
     if(ng.lt.0) i2=i2+1
     fmt="(i4,' W ',i2,' DBD 73 GL')"
     fmt(3:3)=char(48+i1)
     fmt(12:12)=char(48+i2)
     write(message,fmt) n1,ng

! [plain text] (msg#6; type -57)
  else if(ntype.eq.-57) then
     ng=n2/128
     call unpacktext2(n1,ng,message)
  endif

  return
end subroutine wqdecode
