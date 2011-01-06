program hftoa

! Record soundcard data for the HF Time-of-Arrival project.

  parameter (NMAX=300*48000)                 !Max length of data
  integer*2 idat(NMAX)                       !Sampled data
  character arg*12                           !Command-line arg
  character label*7                         !Label for filename
  character cdate*8                          !CCYYMMDD
  character ctime*10                         !HHMMSS.SSS
  character start_time*4                     !Requested start time (HHMM)
  character outfile*40                       !Output filename
  character cmnd*120                         !Command to set rig frequency
  integer soundin

  nargs=iargc()
  if(nargs.ne.4) then
     print*,'Usage:   hftoa  <label> <fs> <nsec> <tstart>'
     print*,'Example: hftoa    K1JT  22050   300    2145'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) label                   !Callsign (or other label for filename)
  call getarg(2,arg)
  read(arg,*) nfsample                 !Sample rate (Hz)
  call getarg(3,arg)
  read(arg,*) nsec                     !Duration of recording (s)
  call getarg(4,arg)
  read(arg,*) start_time               !Start time (HHMM)

  open(10,file='fmt.ini',status='old',err=910)
  read(10,'(a120)') cmnd              !Get rigctl command to set frequency
  read(10,*) ndevin
  close(10)

  call date_and_time(date=cdate,time=ctime)
  label(7:7)=' '
  i1=index(label,' ')
  outfile=label(1:i1-1)//'_'//cdate(3:8)//'_'//start_time//'00.wav'
  open(12,file=outfile,access='stream',status='unknown')

  call soundinit                             !Initialize Portaudio

  do while (ctime(1:4).ne.start_time)
     call date_and_time(date=cdate,time=ctime)
     call msleep(100)
  enddo

  npts=nfsample*nsec
  nchan=1
  ierr=soundin(ndevin,nfsample,idat,npts,nchan-1)   !Get audio data
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif

  call write_wav(12,idat,npts,nfsample,nchan)       !Write wav file to disk

  sq=0.
  sum=0.
  xmax=0.
  do i=1,npts
     x=idat(i)
     sum=sum + x
     sq=sq + x*x
     xmax=max(xmax,abs(x))
  enddo
  ave=sum/npts
  rms=sqrt(sq/npts)
  write(*,1100) ave,rms,xmax
1100 format('Ave:',f8.1,'   Rms:',f8.1,'   Max:',f8.1)
  go to 999

910 print*,'Cannot open file: fmt.ini'

999 end program hftoa

