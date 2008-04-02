subroutine startdec

#ifdef CVF
  use dfmt
  integer Thread3
  external decode
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

  ndecdone=0
  m0=SetPriorityClass(GetCurrentProcess(),NORMAL_PRIORITY_CLASS)
! Start a thread for playing audio data
  Thread3=CreateThread(0,0,decode,0,CREATE_SUSPENDED,id1)
  m1=SetThreadPriority(Thread3,THREAD_PRIORITY_NORMAL)
  m2=ResumeThread(Thread3)
#else
! Start a thread for playing audio data
!  ierr=start_threads(ndevin,ndevout,y1,y2,nmax,iwrite,iwave,nwave,        &
!       11025,NSPB,TRPeriod,TxOK,ndebug,Transmitting,                      &
!       Tsec,ngo,nmode,tbuf,ibuf,ndsec,PttPort,devin_name,devout_name)
#endif

  return
end subroutine startdec
