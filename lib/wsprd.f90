program wsprd

  parameter (NMAX=900*12000)                          !Max length of waveform
  integer*2 id(NMAX)
  real*8 f0,dialFreq
  real*4 ps(-256:256)
  character*80 arg,infile
  logical lc2
  character c2file*14,datetime*11
  complex c2(65536)
  data nbfo/1500/

  nargs=iargc()
  if(nargs.eq.0) then
     print*,'Usage: wsprd [options...] infile'
     print*,''
     print*,'Options:'
     print*,'       -f x   Transceiver dial frequency is x (MHz)'
     print*,'       -m n   Run in WSPR-n mode (default is WSPR-2)'
     print*,''
     print*,'Input file type may be *.wav or *.c2'
     go to 999
  endif

  call wsprd_init(ntrminutes,f0,infile)

  open(13,file='ALL_WSPR.TXT',status='unknown',position='append')
  open(14,file='wspr0.out',status='unknown')

  open(18,file=infile,access='stream',status='old')
  lc2=index(infile,'.c2').gt.0
  i1=index(infile,'.wav')
  if(i1.le.0)   i1=index(infile,'.c2')
  datetime=infile(i1-11:i1-1)
  datetime(7:7)=' '

  if(lc2) then
     read(18) c2file,ntrmin,dialFreq,c2(1:45000)
     f0=dialFreq
     ntrminutes=ntrmin
     npts=60*ntrminutes*12000
     call mix162a(c2,ps)
     c2=(2.94127/13.983112)*c2
     datetime=c2file
     datetime(7:7)=' '
  else
     npts=60*ntrminutes*12000
     read(18) id(1:22)
     read(18) id(1:npts)
     call getrms(id,npts,ave,rms)
! WSPR-2: mix from nbfo +/- 100 Hz to baseband, downsample by 1/32
! WSPR-15: mix from (nbfo+112.5) +/- 12.5 Hz to baseband, downsample by 1/256
     call mix162(id,npts,nbfo,c2,jz,ps)
  endif

  call mept162a(datetime,f0,c2,ps,lc2,npts,nbfo)
  write(*,1100)
1100 format('<DecodeFinished>')
    
999 end program wsprd
