subroutine unpkname(nc1,ngph,name)

  character*9 name
  real*8 dn

  dn=32768.d0*nc1 + ngph
  do i=9,1,-1
     j=mod(dn,27.d0)
     if(j.ge.1) then
        name(i:i)=char(64+j)
     else
        name(i:i)=' '
     endif
     dn=dn/27.d0
  enddo

  return
end subroutine unpkname
