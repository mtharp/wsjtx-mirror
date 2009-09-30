subroutine pk48(cmode,w,nw,lenw,nt1,pfx,sfx,nbit,nc1,ngph,n5)

  parameter (NBASE2=37*37*36)
  character*5 cmode
  character*14 w(7)
  character pfx*3,sfx*1
  integer lenw(7),nt1(7)

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
     call pkpfx(w(2),nc1,ngph,nadd)
     n5=1+nadd
  else if(nt1(1).eq.3 .and. nt1(2).eq.1) then
     n5=3
     i1=index(w(1),'>')
     call hash(w(1)(2:i1-1),i1-2,ngph)
     call pkcall(w(2),nc1,ntext1)
     if(w(3).eq.'RRR') n5=19
  else if(w(1).eq.'DE' .and.  nt1(2).eq.2) then
     call pkpfx(w(2),nc1,ngph,nadd)
     n5=4+nadd
     if(w(3).eq.'OOO' .or. (cmode.eq.'JTMS' .and. w(3).eq.'26')) n5=10+nadd
     if(w(3).eq.'RO' .or. (cmode.eq.'JTMS' .and. w(3).eq.'R26')) n5=16+nadd
     if(w(3).eq.'RRR') n5=23+nadd
  else if(w(1).eq.'DE' .and. nt1(2).eq.1 .and. nt1(3).eq.4) then
     n5=6
     call pkcall(w(2),nc1,ntext1)
     call pkgrid(w(3),ngph,ntext1)
     if(w(4).eq.'OOO' .or. (cmode.eq.'JTMS' .and. w(4).eq.'26')) n5=12
     if(w(4).eq.'RO' .or. (cmode.eq.'JTMS' .and. w(4).eq.'R26')) n5=18
  else if(nt1(1).eq.1 .and. nt1(2).eq.3) then
     call pkcall(w(1),nc1,ntext1)
     i1=index(w(2),'>')
     call hash(w(2)(2:i1-1),i1-2,ngph)
     if(w(3).eq.'OOO' .or. (cmode.eq.'JTMS' .and. w(3).eq.'26')) n5=7
     if(w(3).eq.'RO' .or. (cmode.eq.'JTMS' .and. w(3).eq.'R26')) n5=13
     if(cmode.eq.'JTMS' .and. w(3).eq.'27')  n5=30
     if(cmode.eq.'JTMS' .and. w(3).eq.'R27') n5=31
     if(w(3).eq.'RRR') n5=20
  else if(nt1(1).eq.2 .and. w(2).eq.'OOO' .or.                   &
       (cmode.eq.'JTMS' .and. w(2).eq.'26')) then
     call pkpfx(w(1),nc1,ngph,nadd)
     n5=8+nadd
  else if(nt1(1).eq.2 .and. w(2).eq.'RO' .or.                    &
       (cmode.eq.'JTMS' .and. w(2).eq.'R26')) then
     call pkpfx(w(1),nc1,ngph,nadd)
     n5=14+nadd
  else if(nt1(1).eq.2 .and. w(2).eq.'RRR') then
     call pkpfx(w(1),nc1,ngph,nadd)
     n5=21+nadd
  else if(w(1).eq.'73' .and. w(2).eq.'DE' .and. nt1(3).eq.1 .and.     &
       nt1(4).eq.4) then
     n5=25
     call pkcall(w(3),nc1,ntext1)
     call pkgrid(w(4),ngph,ntext1)
  else if(w(1).eq.'73' .and. w(2).eq.'DE' .and. nt1(3).eq.2) then
     call pkpfx(w(3),nc1,ngph,nadd)
     n5=26+nadd
  else if(w(1).eq.'TNX' .and. w(3).eq.'73' .and. w(4).eq.'GL') then
     call pkname(w(2),lenw(2),nc1,ngph)
     n5=28
  else if(w(1).eq.'OP' .and. w(3).eq.'73' .and. w(4).eq.'GL') then
     call pkname(w(2),lenw(2),nc1,ngph)
     n5=29
  endif

  if(n5.ge.0) nbit=48

  return
end subroutine pk48
