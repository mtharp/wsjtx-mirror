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
  call msleep(100)
  go to 1

2 ndecoding=1
  do i=len,1,-1
     if(fname(i:i).eq.'/' .or. fname(i:i).eq.'\\') go to 10
  enddo
  i=0
10 filename=fname(i+1:)
  ierr=0

#ifdef CVF
  open(10,file=fname,form='binary',status='old')
#else
  open(10,file=fname,access='stream',status='old')
#endif
  read(10) hdr
  npts=114*12000
  read(10) (iwave(i),i=1,npts)
  call getrms(iwave,npts,ave,rms)
  ndecdone=0                              !??? ### ???
  ndiskdat=1
  outfile=fname
  nrxdone=1

999 close(10)
  return
end subroutine getfile
