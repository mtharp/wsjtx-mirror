subroutine runqqq(fname,cmnd,iret)

  integer system
  character*(*) fname,cmnd

  iret=system('KVASD_g95 -q > dev_null')

  return
end subroutine runqqq
