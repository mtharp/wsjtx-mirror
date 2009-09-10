subroutine pk78(msg,w,nw,nt1,nc1,nc2,ngph,n2,n5,iu)

  character*24 msg
  character*14 w(7)
  integer nt1(7),iu(3)

! 78-bit messages
  n2=0
  n5=0

  if(nt1(1).eq.1 .and. nt1(2).eq.1) then
     call pkcall(w(1),nc1,ntext1)
     call pkcall(w(2),nc2,ntext2)
     if(nw.ge.3 .and. w(3).ne.'OOO') then
        call pkgrid(w(3),ngph,ntext3)
     else
        call pkgrid('    ',ngph,ntext3)
     endif
     n2=0
  else if(nt1(1).eq.2 .and. nt1(2).eq.1) then
     call packpfx(w(1),nc1,ngph,nadd)
     call pkcall(w(2),nc2,ntext2)
     n2=1
     n5=4*nadd
  else if(nt1(1).eq.1 .and. nt1(2).eq.2) then
     call pkcall(w(1),nc1,ntext1)
     call packpfx(w(2),nc2,ngph,nadd)
     n2=2
     n5=4*nadd
  else
     n5=1
     call pktext(msg,iu)
  endif
  if(n5.ne.1 .and. w(nw).eq.'OOO') n5=n5+2

  return
end subroutine pk78
