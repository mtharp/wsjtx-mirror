subroutine getfile(fname,len)

#ifdef CVF
  use dflib
#endif

  character*(*) fname
  character*80 filename
  include 'acom1.f90'
  integer*1 hdr(44),n1
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  common/hdr/ariff,lenfile,awave,afmt,lenfmt,nfmt2,nchan2, &
     nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata,d2
  equivalence (ariff,hdr),(n1,n4),(d1,d2)

1 if(ndecoding.eq.0) go to 2
!#ifdef CVF
!  call sleepqq(100)
!#else
!  call usleep(100*1000)
!#endif
!  go to 1

2 do i=len,1,-1
     if(fname(i:i).eq.'/' .or. fname(i:i).eq.'\\') go to 10
  enddo
  i=0
10 filename=fname(i+1:)
  ierr=0

#ifdef CVF
!  open(10,file=fname,form='binary',status='old',err=998)
!  read(10,end=998) hdr
!  read(10,end=998) iwave
  open(10,file=fname,form='binary',status='old')
  read(10) hdr
  npts=114*12000
  read(10) (iwave(i),i=1,npts)
#else
!  call rfile2(fname,hdr,44+2*NDMAX,nr)
#endif

  ndecdone=0                              !??? ### ???
!  decoding=.true.
  outfile=fname
  call startdec

998 ierr=1001
999 close(10)
  return
end subroutine getfile
