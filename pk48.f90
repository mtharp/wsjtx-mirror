subroutine pk48(w,nw,nt1,pfx,sfx,nbit,nc1,ngph,n5)

  parameter (NBASE2=37*37*36)
  character*14 w(7)
  character pfx*3,sfx*1,c1*6
  character*8 opname
  integer nt1(7)

! 48-bit messages
  if(w(1).eq.'CQ' .and. nt1(2).eq.1 .and. nt1(3).eq.4) then
     n5=0
     call pkcall(w(2),nc1,ntext1)
     call pkgrid(w(3),ngph,ntext1)
  else if(w(1).eq.'QRZ' .and. nt1(2).eq.1) then
     n5=0
     call pkcall(w(2),nc1,ntext1)
     ngph=32527
  else if(w(1).eq.'CQ' .and. nt1(2).eq.15 .and. nt1(3).eq.1) then
     n5=2
     call pkcall(w(3),nc1,ntext1)
     read(w(2),*) n
     ngph=61000 + n - 32768
  else if(w(1).eq.'CQ' .and. nt1(2).eq.2) then
     call packpfx(w(2),nc1,ngph,nadd)
     n5=1+nadd
  else if(nt1(1).eq.3 .and. nt1(2).eq.1) then
     n5=3
     i1=index(w(1),'>')
     call hash(w(1)(2:i1-1),i1-2,ngph)
     call pkcall(w(2),nc1,ntext1)
     if(w(3).eq.'RRR') n5=19
  else if(w(1).eq.'DE' .and.  nt1(2).eq.2) then
     call packpfx(w(2),nc1,ngph,nadd)
     n5=4+nadd
     if(w(3).eq.'OOO') n5=10+nadd
     if(w(3).eq.'RO')  n5=16+nadd
     if(w(3).eq.'RRR') n5=23+nadd
  else if(w(1).eq.'DE' .and. nt1(2).eq.1 .and. nt1(3).eq.4) then
     n5=6
     call pkcall(w(2),nc1,ntext1)
     call pkgrid(w(3),ngph,ntext1)
     if(w(4).eq.'OOO') n5=12
     if(w(4).eq.'RO') n5=18
  else if(nt1(1).eq.1 .and. nt1(2).eq.3) then
     call pkcall(w(1),nc1,ntext1)
     i1=index(w(2),'>')
     call hash(w(2)(2:i1-1),i1-2,ngph)
     if(w(3).eq.'OOO') n5=7
     if(w(3).eq.'RO') n5=13
     if(w(3).eq.'RRR') n5=20
  else if(nt1(1).eq.2 .and. w(2).eq.'OOO') then
     call packpfx(w(1),nc1,ngph,nadd)
     n5=8+nadd
  else if(nt1(1).eq.2 .and. w(2).eq.'RO') then
     call packpfx(w(1),nc1,ngph,nadd)
     n5=14+nadd
  else if(nt1(1).eq.2 .and. w(2).eq.'RRR') then
     call packpfx(w(1),nc1,ngph,nadd)
     n5=21+nadd
  endif

!  if(w(1).eq.'73' .and. w(2).eq.'DE' .and. nt1(3).eq.1 .and.     &
!       nt1(4).eq.4) n5=25
!  if(w(1).eq.'73' .and. w(2).eq.'DE' .and. nt1(3).eq.2) n5=26      !or 27
!  if(w(1).eq.'TNX' .and. w(3).eq.'73' .and. w(4).eq.'GL') then
!     opname=w(2)
!     n5=28
!  endif
!  if(w(1).eq.'OP' .and. w(3).eq.'73' .and. w(4).eq.'GL') then
!     opname=w(2)
!     n5=29
!  endif

  if(n5.ge.0) nbit=48

  return
end subroutine pk48
