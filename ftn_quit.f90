subroutine ftn_quit
  include 'acom1.f90'
  call fthread_mutex_destroy(mtx1)
  return
end subroutine ftn_quit
