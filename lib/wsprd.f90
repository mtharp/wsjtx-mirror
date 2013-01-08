program wsprd

  parameter (NMAX=900*12000)                          !Max length of waveform
  integer*2 id(NMAX)
  real*8 f0,dialFreq
  real*4 ps(-256:256)
  character*80 infile
  logical lc2
  character c2file*14,datetime*11
  complex c2(65536)
  data nbfo/1500/

  call getarg(1,infile)
  open(18,file=infile,access='stream',status='old')
  lc2=index(infile,'.c2').gt.0

  open(13,file='ALL_WSPR.TXT',status='unknown',position='append')
  open(14,file='wspr0.out',status='unknown')

  ntrminutes=2

  if(lc2) then
     read(18) c2file,ntrmin,dialFreq,c2(1:45000)
     f0=dialFreq
     ntrminutes=ntrmin
     npts=60*ntrminutes*12000
     call mix162a(c2,ps)
     c2=(2.94127/13.983112)*c2
  else
     f0=10.1387
     ntrminutes=2
     npts=60*ntrminutes*12000
     read(18) id(1:22)
     read(18) id(1:npts)
     call getrms(id,npts,ave,rms)
! WSPR-2: mix from nbfo +/- 100 Hz to baseband, downsample by 1/32
! WSPR-15: mix from (nbfo+112.5) +/- 12.5 Hz to baseband, downsample by 1/256
     call mix162(id,npts,nbfo,c2,jz,ps)
  endif

  i1=index(infile,'.wav')
  if(i1.le.0)   i1=index(infile,'.c2')
  datetime=infile(i1-11:i1-1)
  datetime(7:7)=' '
  call mept162a(datetime,f0,c2,ps,lc2,npts,nbfo)
  write(*,1100)
1100 format('<DecodeFinished>')
    
end program wsprd
