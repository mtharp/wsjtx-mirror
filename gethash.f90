subroutine gethash(ih,j,c1,g1,jz)

! Get call and grid correswponding to a hash code

  character c1*12,g1*4
  include 'hcom.f90'

  jz=np(ih,0)
  if(jz.eq.0 .or. j.gt.jz) then
     c1='            '
     g1='    '
  else
     i=np(ih,j)
     c1=dcall(i)
     g1=dgrid(i)
  endif

  return
end subroutine gethash
