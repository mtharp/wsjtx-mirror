subroutine pk30(w,nw,nt1,nbit,nc1,n2)

  parameter (NBASE=37*36*10*27*27*27)
  character*14 w(7)
  integer nt1(7)

! 30-bit messages
  if(nw.le.2) then
     if(w(1).eq.'CQ' .and. nt1(2).eq.1) then
        call pkcall(w(2),nc1,ntext1)
        n2=0
        nbit=30
     else if(w(1).eq.'DE' .and. nt1(2).eq.1) then
        call pkcall(w(2),nc1,ntext1)
        n2=1
        nbit=30
     else if(nt1(1).eq.1 .and. w(2).eq.'OOO') then
        call pkcall(w(1),nc1,ntext1)
        n2=2
        nbit=30
     else if(nt1(1).eq.1 .and. w(2).eq.'RO') then
        call pkcall(w(1),nc1,ntext1)
        n2=3
        nbit=30
     else if(w(1).eq.'GRID?') then
        nc1=NBASE + 1003 + 1
        n2=0
        nbit=30
     else if(nt1(1).eq.4) then
        n2=0
        nbit=30
        call pkgrid(w(1),ngph,ntext1)
        nc1=NBASE + 1003 + 100 + ngph
        ngph=-1
     else if(w(1).eq.'BEST') then
        read(w(2),*,err=10,end=10) ndb
        if(ndb.lt.-30) ndb=-30
        if(ndb.gt.30) ndb=30
        nc1=NBASE + 1003 + 1 + 31 + ndb
        n2=0
        nbit=30
     endif
  else if(nw.eq.3 .and. w(1).eq.'RRR' .and. W(2).eq.'TNX' .and.       &
       w(3).eq.'73') then
     nc1=NBASE + 1003 + 1 + 31 + 31
     n2=0
     nbit=30
  else if(nw.eq.3 .and. w(1).eq.'TNX' .and. W(2).eq.'73' .and.       &
       w(3).eq.'GL') then
     nc1=NBASE + 1003 + 1 + 31 + 32
     n2=0
     nbit=30
  endif

10  return
end subroutine pk30
