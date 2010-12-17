subroutine wspr0_rx(nargs,ntr)

!  Read Rx command-line args and the decode MEPT_JT signals from disk
!  or real-time data.

!  use dfport

  parameter (NMAX=120*12000)                          !Max length of waveform
  integer*2 iwave(NMAX)                               !Generated waveform
  integer*1 i1
  integer*1 hdr(44)
  integer npr3(162)
  integer soundin
  real*8 f0
  character*20 arg
  character*80 infile,appdir,thisfile
  character*6 cfile6,cdate*8,utctime*10
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

  data nsec0/999999/
  save

  call getarg(2,arg)
  read(arg,*) f0
  nfiles=0
  if(ntr.eq.0) nfiles=nargs-2
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
     is120=mod(isec,120)
     if(is120.eq.0) then
        call getutc(cdate,utctime,tsec)
        thisfile=cdate(3:8)//'_'//utctime(1:4)//'.'//'wav'
        ierr=soundin(-1,12000,iwave,114*12000,0)
        npts=114*12000
        call getrms(iwave,npts,ave,rms)
        call mept162(thisfile,appdir,nappdir,f0,1,iwave,NMAX,nbfo,ierr)
        if(ntr.ne.0) go to 999
     endif
30   call msleep(100)
     go to 20
  endif
      
999 return
end subroutine wspr0_rx

