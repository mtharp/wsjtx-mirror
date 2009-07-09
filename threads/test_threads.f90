program test_threads

  character arg*12
  external sub1,sub2,sub3,sub4
  common/acom/ iters,ndone(4),mtx,ltx,nsum

  if(iargc().ne.2) then
     print*,'Usage:    test_threads <iters> <ltx>'
     print*,'Examples: test_threads 100 0'
     print*,'          test_threads 10000 1'
     print*,'   ltx=0: no mutexes'
     print*,'   ltx=1: use mutex locks'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) iters
  call getarg(2,arg)
  read(arg,*) ltx

  ndone=0
  nsum=0
  if(ltx.ne.0) then
     print*,'Using mutex lockouts.'
     call fthread_mutex_init(mtx)
  else
     print*,'No mutex lockouts.'
  endif

  call fthread_create(sub1,id1)
  call fthread_create(sub2,id2)
  call fthread_create(sub3,id3)
  call fthread_create(sub4,id4)

10 if(sum(ndone).eq.4) go to 900
  call sleep(1)
  go to 10

900 write(*,1900) nsum
1900 format('nsum:',i10)
  if(ltx.ne.0) call fthread_mutex_destroy(mtx)
999 end program test_threads

!------------------------------------------------- sub1
subroutine sub1
  character*80 ctemp
  common/acom/ iters,ndone(4),mtx,ltx,nsum
  n=1
  do i=1,iters
     if(ltx.ne.0) call fthread_mutex_lock(mtx)
     nsum=nsum+1
     write(10,1000) n,i
1000 format(2i10)
     if(ltx.ne.0) call fthread_mutex_unlock(mtx)
  enddo
  ndone(n)=1
  return
end subroutine sub1

!------------------------------------------------- sub2
subroutine sub2
  character*80 ctemp
  common/acom/ iters,ndone(4),mtx,ltx,nsum
  n=2
  do i=1,iters
     if(ltx.ne.0) call fthread_mutex_lock(mtx)
     nsum=nsum+1
     write(10,1000) n,i
1000 format(2i10)
     if(ltx.ne.0) call fthread_mutex_unlock(mtx)
  enddo
  ndone(n)=1
  return
end subroutine sub2

!------------------------------------------------- sub3
subroutine sub3
  character*80 ctemp
  common/acom/ iters,ndone(4),mtx,ltx,nsum
  n=3
  do i=1,iters
     if(ltx.ne.0) call fthread_mutex_lock(mtx) 
     nsum=nsum+1
     write(10,1000) n,i
1000 format(2i10)
     if(ltx.ne.0) call fthread_mutex_unlock(mtx)
  enddo
  ndone(n)=1
  return
end subroutine sub3

!------------------------------------------------- sub4
subroutine sub4
  character*80 ctemp
  common/acom/ iters,ndone(4),mtx,ltx,nsum
  n=4
  do i=1,iters
     if(ltx.ne.0) call fthread_mutex_lock(mtx)
     nsum=nsum+1
     write(10,1000) n,i
1000 format(2i10)
     if(ltx.ne.0) call fthread_mutex_unlock(mtx)
  enddo
  ndone(n)=1
  return
end subroutine sub4
