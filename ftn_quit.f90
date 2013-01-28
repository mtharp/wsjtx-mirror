subroutine ftn_quit
!f2py threadsafe
  call four2a(a,-1,-1,1,1)
  call cs_destroy
  call timer('wsjt    ',1)
  call timer('wsjt    ',101)

  return
end subroutine ftn_quit
