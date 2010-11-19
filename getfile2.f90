subroutine getfile2(fname,len)

  character*(*) fname
  real*8 sq

  include 'datcom.f90'
  include 'gcom1.f90'
  include 'gcom2.f90'
  include 'gcom4.f90'
  integer*2 id(2,NSMAX)

1 if(ndecoding.eq.0) go to 2
  call usleep(100*1000)

  go to 1

2 do i=len,1,-1
     if(fname(i:i).eq.'/' .or. fname(i:i).eq.'\\') go to 10
  enddo
  i=0
10 filename=fname(i+1:)
  ierr=0

  n=4*NSMAX
  ndecoding=4
  monitoring=0
  kbuf=1

!###
! NB: not really necessary to read whole file at once.  Save memory!
  call rfile3a(fname,id,n,ierr)
  do i=1,NSMAX
     dd(1,i,1)=id(1,i)
     dd(2,i,1)=id(2,i)
  enddo
!###

  if(ierr.ne.0) then
     print*,'Error opening or reading file: ',fname,ierr
     go to 999
  endif

  sq=0.
  ka=0.1*NSMAX
  kb=0.8*NSMAX
  do k=ka,kb
     sq=sq + dd(1,k,1)**2 + dd(2,k,1)**2
  enddo
  sqave=174*sq/(kb-ka+1)
  rxnoise=10.0*log10(sqave) - 48.0
  call cs_lock('getfile2')
  read(filename(8:11),*,err=20,end=20) nutc
  call cs_unlock
  go to 30
20 nutc=0

30 ndiskdat=1
  mousebutton=0
  fcenter=144.130
  if(fcfile.gt.1.5 .and. fcfile.lt.11000.0) fcenter=fcfile
  fcfile=0.d0

999 return
end subroutine getfile2
