subroutine srcdec(cmode,nbit,iu,msg)

! Unpack a user message from source-encoded form.

  parameter (NBASE=37*36*10*27*27*27)
  parameter (NBASE2=37*37*36)
  parameter (N15=32768)
  character*5 cmode
  integer iu(3)
  character cgp*4,msg*24,c12*12
  character*12 c1,c2
  character*12 dcall(0:N15-1)
  logical first
  data first/.true./
  save first,dcall

  if(first) then
     dcall='            '
     first=.false.
  endif

  msg=''
  c1=''
  c2=''
  c12=''

  if(nbit.eq.2) then
     n=ishft(iu(1),-30)
     if(n.eq.1) msg='RO'
     if(n.eq.2) msg='RRR'
     if(n.eq.3) msg='73'
     go to 100
  else if(nbit.eq.30) then
     nc1=ishft(iu(1),-4)
     n2=iand(ishft(iu(1),-2),3)
     ndb=nc1-NBASE - 1003 - 1 - 30
     if(nc1.lt.NBASE) then
        call unpkcall(nc1,c12)
        if(n2.eq.0) then
           msg='CQ '//c12
        else if(n2.eq.1) then
           msg='DE '//c12
        else if(n2.eq.2) then
           msg=c12//' OOO'
        else
           msg=c12//' RO'
        endif
     else if(nc1.eq.NBASE+1003+1) then
        msg='GRID?'
     else if(nc1.gt.NBASE+1003+100) then
        ngph=nc1-NBASE - 1003 - 100
        call unpkgrid(ngph,cgp)
        msg=cgp
     else
        ndb=nc1-NBASE - 1003 - 1 - 31
        if(abs(ndb).le.30) then
           write(msg,'("BEST ",i3.2)'),ndb
           if(msg(6:6).eq.' ') msg(6:6)='+'
        else if(ndb.eq.31) then
           msg='RRR TNX 73'
        else if(ndb.eq.32) then
           msg='TNX 73 GL'
        endif
     endif

  else if(nbit.eq.48) then
     nc1=ishft(iu(1),-4)
     ngph=ishft(iand(iu(1),15),11) + ishft(iu(2),-21)
     n5=iand(ishft(iu(2),-16),31)
     call unpkcall(nc1,c12)
     if(n5.eq.0) then
        call unpkgrid(ngph,cgp)
        if(cgp.eq.'QRZ ') then
           msg='QRZ '//c12
        else
           msg='CQ '//c12//cgp
        endif
     else if(n5.eq.1 .or. n5.eq.2) then
        ng=ngph + 32768*(n5-1)
        if(ng.lt.61000) then
           call unpackpfx(ng,c12)
           msg='CQ '//c12
        else
           msg='CQ nnn '//c12
           write(msg(4:6),'(i3.3)') ng-61000
        endif
     else if(n5.eq.3 .or.n5.eq.19) then
        call unpkcall(nc1,c12)
        i1=index(dcall(ngph),' ')
        i2=index(c12,' ')
        if(i1.eq.1) then
           if(n5.eq.3) msg='<...> '//c12(:i2-1)
           if(n5.eq.19) msg='<...> '//c12(:i2-1)//' RRR'
        else
           if(n5.eq.3) msg='<'//dcall(ngph)(:i1-1)//'> '//c12(:i2-1)
           if(n5.eq.19) msg='<'//dcall(ngph)(:i1-1)//'> '//c12(:i2-1)//' RRR'
        endif
     else if(n5.eq.4 .or. n5.eq.5) then
        ng=ngph + 32768*(n5-4)
        call unpackpfx(ng,c12)
        msg='DE '//c12
     else if(n5.eq.6 .or. n5.eq.12 .or. n5.eq.18) then
        call unpkcall(nc1,c12)
        i1=index(c12,' ')
        call unpkgrid(ngph,cgp)
        if(n5.eq.6) msg='DE '//c12(:i1)//cgp
        if(n5.eq.12) msg='DE '//c12(:i1)//cgp//' OOO'
        if(n5.eq.18) msg='DE '//c12(:i1)//cgp//' RO'
     else if(n5.eq.7 .or. n5.eq.13 .or. n5.eq.20) then
        call unpkcall(nc1,c12)
        i1=index(dcall(ngph),' ')
        i2=index(c12,' ')
        if(i1.eq.1) then
           if(n5.eq.7) msg=c12(:i2-1)//' <...> OOO'
           if(n5.eq.13) msg=c12(:i2-1)//' <...> RO'
           if(n5.eq.20) msg=c12(:i2-1)//' <...> RRR'
        else
           if(n5.eq.7) msg=c12(:i2-1)//' <'//dcall(ngph)(:i1-1)//'> OOO'
           if(n5.eq.13) msg=c12(:i2-1)//' <'//dcall(ngph)(:i1-1)//'> RO'
           if(n5.eq.20) msg=c12(:i2-1)//' <'//dcall(ngph)(:i1-1)//'> RRR'
        endif
     else if(n5.eq.8 .or. n5.eq.9) then
        ng=ngph + 32768*(n5-8)
        call unpackpfx(ng,c12)
        msg=c12//' OOO'
     else if(n5.eq.10 .or. n5.eq.11) then
        ng=ngph + 32768*(n5-10)
        call unpackpfx(ng,c12)
        msg='DE '//c12//' OOO'
     else if(n5.eq.14 .or. n5.eq.15) then
        ng=ngph + 32768*(n5-14)
        call unpackpfx(ng,c12)
        msg=c12//' RO'
     else if(n5.eq.16 .or. n5.eq.17) then
        ng=ngph + 32768*(n5-16)
        call unpackpfx(ng,c12)
        msg='DE '//c12//' RO'
     else if(n5.eq.21 .or. n5.eq.22) then
        ng=ngph + 32768*(n5-21)
        call unpackpfx(ng,c12)
        msg=c12//' RRR'
     else if(n5.eq.23 .or. n5.eq.24) then
        ng=ngph + 32768*(n5-23)
        call unpackpfx(ng,c12)
        msg='DE '//c12//' RRR'
     endif
  else if(nbit.eq.78) then
     nc1=ishft(iu(1),-4)
     nc2=ishft(iand(iu(1),15),24) + ishft(iu(2),-8)
     ngph=ishft(iand(iu(2),255),7) + ishft(iu(3),-25)
     n2=iand(ishft(iu(3),-23),3)
     n5=iand(ishft(iu(3),-18),31)
     if(iand(n5,1).ne.0) then
        call unpktext(iu,msg)
        go to 100
     endif
     if(n2.eq.0) then
        call unpkcall(nc1,c1)
        call unpkcall(nc2,c2)
        call unpkgrid(ngph,cgp)
        msg=c1(:6)//' '//c2(:6)//' '//cgp
     else if(n2.eq.1) then
        ng=ngph + 32768*(n5/4)
        call unpkcall(nc1,c12)
        call unpackpfx(ng,c12)
        call unpkcall(nc2,c2)
        i1=index(c12,' ')
        msg=c12(:i1)//c2(:6)
     else if(n2.eq.2) then
        call unpkcall(nc1,c1)
        call unpkcall(nc2,c12)
        ng=ngph + 32768*(n5/4)
        call unpackpfx(ng,c12)
        i1=index(c12,' ')
        msg=c1//' '//c12(:i1-1)
     endif
     if(iand(n5,2).ne.0) then
        do i=24,1,-1
           if(msg(i:i).ne.' ') go to 10
        enddo
10      i2=i
        msg(i2+2:)='OOO'
     endif
  else
     print*,'Unsupported nbit value:',nbit
     stop
  endif

  if(c12(1:2).ne.' ') then
     i1=index(c12,' ')
     if(i1.ne.1) then
        call hash(c12,i1-1,ih)
        dcall(ih)=c12(:i1-1)
     endif
     i1=index(c1,' ')
     if(i1.ne.1) then
        call hash(c1,i1-1,ih)
        dcall(ih)=c12(:i1-1)
     endif
     i1=index(c2,' ')
     if(i1.ne.1) then
        call hash(c2,i1-1,ih)
        dcall(ih)=c12(:i1-1)
     endif
  endif

100 call msgtrim(msg,nmsg)

  i1=index(msg,' OOO ')
  if(cmode.eq.'JTMS' .and. i1.ge.4) then
     msg=msg(:i1)//'26'//msg(i1+4:)
  endif
  i1=index(msg,' RO ')
  if(cmode.eq.'JTMS' .and. i1.ge.4) then
     msg=msg(:i1)//'R26'//msg(i1+4:)
  endif

  return
end subroutine srcdec
