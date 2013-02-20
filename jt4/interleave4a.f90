subroutine interleave4a(sym,ndir)
  real sym(0:1,0:205),tmp(0:1,0:205)
  integer j0(0:205)
  logical first
  data first/.true./
  save first,j0

  if(first) then
     k=-1
     do i=0,255
        m=i
        n=iand(m,1)
        n=2*n + iand(m/2,1)
        n=2*n + iand(m/4,1)
        n=2*n + iand(m/8,1)
        n=2*n + iand(m/16,1)
        n=2*n + iand(m/32,1)
        n=2*n + iand(m/64,1)
        n=2*n + iand(m/128,1)
        if(n.le.205) then
           k=k+1
           j0(k)=n
        endif
     enddo
     first=.false.
  endif

  if(ndir.eq.1) then
     do i=0,205
        tmp(0,j0(i))=sym(0,i)
        tmp(1,j0(i))=sym(1,i)
     enddo
  else
     do i=0,205
        tmp(0,i)=sym(0,j0(i))
        tmp(1,i)=sym(1,j0(i))
     enddo
  endif

  do i=0,205
     sym(0,i)=tmp(0,i)
     sym(1,i)=tmp(1,i)
  enddo

  return
end subroutine interleave4a
