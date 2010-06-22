subroutine runqqq(fname,cmnd,iret)

#ifdef CVF
  use dflib
#endif
  integer system

  character*(*) fname,cmnd

  iret=ichar(fname(1:1)) + ichar(cmnd(1:1))    !Silence compiler warning
#ifdef Win32
  iret=system('.\\kvasd2 -q')
#else
  iret=system('./kvasd2 -q')
#endif

  return
end subroutine runqqq

subroutine flushqqq(lu)

#ifdef CVF
  use dfport
#endif

  call flush(lu)

  return
end subroutine flushqqq

subroutine sleepqqq(n)
#ifdef CVF
  use dflib
      call sleepqq(n)
#else
      call usleep(n*1000)
#endif

  return

end subroutine sleepqqq
