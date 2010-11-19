subroutine sysqqq(cmnd,iret)

  integer system
  character*(*) cmnd

  iret=system(cmnd)

  return
end subroutine sysqqq
