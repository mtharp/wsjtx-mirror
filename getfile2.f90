!----------------------------------------------------- getfile
subroutine getfile2(fname,len)

#ifdef Win32
  use dflib
#endif

  parameter (NDMAX=661500)  ! =60*11025
  character*(*) fname
  character infile*15
  parameter (NSMAX=60*96000)          !Samples per 60 s file
  integer*2 id(4,NSMAX)               !46 MB: raw data from Linrad timf2
  common/datcom/nutc,newdat2,id
  include 'gcom1.f90'
  include 'gcom2.f90'
  include 'gcom4.f90'

1 if(ndecoding.eq.0) go to 2
#ifdef Win32
  call sleepqq(100)
#else
  call usleep(100*1000)
#endif

  go to 1

2 do i=len,1,-1
     if(fname(i:i).eq.'/' .or. fname(i:i).eq.'\\') go to 10
  enddo
  i=0
10 filename=fname(i+1:)
  ierr=0

#ifdef Win32
!  open(10,file=fname,form='binary',status='old',err=998)
  n=8*NSMAX
  call rfile3a(fname,id,n,ierr)
  if(ierr.ne.0) then
     print*,'Error opening or reading file: ',fname,ierr
     go to 999
  endif
#else
  call rfile2(fname,hdr,44+2*NDMAX,nr)
#endif

  read(filename(8:11),*) nutc
  ndiskdat=1
  ndecoding=4
  mousebutton=0
  go to 999

998 ierr=1001
999 close(10)
  return
end subroutine getfile2
