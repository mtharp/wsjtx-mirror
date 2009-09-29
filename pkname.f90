subroutine pkname(name,len,nc1,ngph)

  character*9 name
  real*8 dn

  dn=0
  iz=min(len,7)
  do i=1,iz
     n=ichar(name(i:i))
     if(n.ge.97 .and. n.le.122) n=n-32
     dn=27*dn + n-64
  enddo
  if(len.lt.7) then
     do i=len+1,7
        dn=27*dn
     enddo
  endif

  ngph=mod(dn,32768.d0)
  dn=dn/32768.d0
  nc1=dn

  return
end subroutine pkname
