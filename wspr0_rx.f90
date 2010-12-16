subroutine wspr0_rx(nargs,ntr)

!  Read Rx command-line args and the decode MEPT_JT signals from disk
!  or real-time data.

!  use dfport

  parameter (NMAX=120*12000)                          !Max length of waveform
  integer*2 iwave(NMAX)                               !Generated waveform
  
  parameter (MAXSYM=176)
  integer*1 symbol(MAXSYM)
  integer*1 i1
  integer*1 hdr(44)
  integer npr3(162)
  integer getsound
  logical first
  real*8 f0,pi
  character*20 arg
  character*80 infile,outfile,appdir
  character*6 cfile6
  equivalence(i1,i4)
  data appdir/'.'/,nappdir/1/,minsync/1/,nbfo/1500/
  data npr3/                                          &
      1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,        &
      0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,        &
      0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,        &
      1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,        &
      0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,        &
      0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,        &
      0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,        &
      0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,        &
      0,0/

  data first/.true./,nsec0/999999/
  save

  call getarg(2,arg)
  read(arg,*) f0
  nfiles=0
  if(ntr.eq.0) nfiles=nargs-2

  nsym=162                  !Symbols per transmission
  if(first) then
     pi=4.d0*atan(1.d0)
     open(13,file='ALL_WSPR0.TXT',status='unknown',access='append')
     first=.false.
  endif

  npts=114*12000
  if(nfiles.ge.1) then
     do ifile=1,nfiles
        call getarg(2+ifile,infile)
        open(10,file=infile,access='stream',status='old')
        read(10) hdr
        read(10) (iwave(i),i=1,npts)
        close(10)
        cfile6=infile
        i1=index(infile,'.')
        if(i1.ge.2) then
           i0=max(1,i1-4)
           cfile6=infile(i0:i1-1)
        endif
        call getrms(iwave,npts,ave,rms)
        call mept162(infile,appdir,nappdir,f0,1,iwave,NMAX,nbfo,ierr)
     enddo
  else
20   nsec=time()
     isec=mod(nsec,86400)
     ih=isec/3600
     im=(isec-ih*3600)/60
     is=mod(isec,60)
     if(mod(im,2).ne.0) go to 30
     if(is.eq.0) then
        write(cfile6,1030) ih,im,is
1030    format(3i2.2)
        ierr=getsound(iwave)
        npts=114*12000
        call getrms(iwave,npts,ave,rms)
        call mept162(cfile6,f0,iwave,npts,rms)
        if(ntr.ne.0) go to 999
     endif
30   call msleep(100)
     go to 20
  endif
      
999 return
end subroutine wspr0_rx

