subroutine wspr1

#ifdef CVF
  use dfmt
  integer Thread0
  external wspr2
#endif

  include 'acom1.f90'

#ifdef CVF
!  Priority classes (for processes):
!     IDLE_PRIORITY_CLASS               64
!     NORMAL_PRIORITY_CLASS             32
!     HIGH_PRIORITY_CLASS              128

!  Priority definitions (for threads):
!     THREAD_PRIORITY_IDLE             -15
!     THREAD_PRIORITY_LOWEST            -2
!     THREAD_PRIORITY_BELOW_NORMAL      -1
!     THREAD_PRIORITY_NORMAL             0
!     THREAD_PRIORITY_ABOVE_NORMAL       1
!     THREAD_PRIORITY_HIGHEST            2
!     THREAD_PRIORITY_TIME_CRITICAL     15

  nrxdone=0
  m0=SetPriorityClass(GetCurrentProcess(),NORMAL_PRIORITY_CLASS)
! Start a thread for acquiring audio data
  Thread0=CreateThread(0,0,wspr2,0,CREATE_SUSPENDED,id0)
  m1=SetThreadPriority(Thread0,THREAD_PRIORITY_NORMAL)
  m2=ResumeThread(Thread0)
#else
! Start a thread for acquiring audio data
  ierr=th_wspr2()
#endif

  return
end subroutine wspr1
