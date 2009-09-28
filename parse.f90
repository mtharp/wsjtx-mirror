subroutine parse(msg,msglen,w,nw,lenw,nt1,pfx,sfx)

! nt1 
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

  character*24 msg
  character*14 w(7)
  character c10*10,c6*6
  character g4*4,pfx*3,sfx*1
  integer lenw(7),nt1(7)
  logical text

  lenw=0
  nt1=0
  nhash=0

  call msgtrim(msg,msglen)

! Parse into words
  i2=0
  pfx=''
  sfx=''
  do i=1,7
     i1=i2+1
     i2=index(msg(i1:),' ') + i1 - 1
     if(i2.eq.0) i2=msglen+1
     w(i)=msg(i1:i2-1)
     lenw(i)=min(i2-i1,14)
     nw=i
     nt1(i)=0

     c10=w(i)
     ii=index(c10,'/')
     if(ii.eq.0) then
        c6=c10
        nt1(i)=1
     else if(ii.le.4 .and.c10(ii+2:ii+2).ne.' ') then
        c6=c10(ii+1:)                          !strip prefix
        pfx=c10(:ii-1)
        nt1(i)=2
     else
        c6=c10(:ii-1)                          !strip suffix
        sfx=c10(ii+1:)
        nt1(i)=2
     endif
     call packcall(c6,ncall,text)
     if(text) nt1(i)=0                          !Oops, NG as call

     if(lenw(i).eq.4) then
        g4=w(i)
        call packgrid(w(i),ngrid,text)
        if(.not.text) nt1(i)=4
     endif

     if(w(i).eq.'CQ') nt1(i)=5
     if(w(i).eq.'DE') nt1(i)=6
     if(w(i).eq.'QRZ') nt1(i)=7
     if(w(i).eq.'OOO') nt1(i)=8
     if(w(i).eq.'RO') nt1(i)=9
     if(w(i).eq.'RRR') nt1(i)=10
     if(w(i).eq.'73') nt1(i)=11
     if(w(i).eq.'TNX') nt1(i)=12
     if(w(i).eq.'OP') nt1(i)=13
     if(w(i).eq.'GRID?') nt1(i)=14
     read(w(i),'(i)',err=30) nnn
     nt1(i)=15
30   if(index(w(i),'<').eq.1) then
        nt1(i)=3
        nhash=1
     endif
     if(i2-1.ge.msglen) go to 900
  end do
  go to 900

800 nw=-1                                   !Error flag

900 if(nhash.eq.1) then
     pfx='   '
     sfx=' '
  endif

  return
end subroutine parse
