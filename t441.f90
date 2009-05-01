program t441

! Run decoding tests on the "TNX QSO TNX QSO ..." ping in W8WN sample file.

  parameter (NPTS=9283)
  character*28 tmsg
  character*12 arg
  real ps(128)                              !Spectrum computed in WSJT
  real dat(NPTS)                            !Raw data, 11025 S/s

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: t441 "Test message"'
     go to 999
  endif
  call getarg(1,tmsg)

  open(88,file='dat.88',form='unformatted',status='old')
  read(88) jjz,ps,f0,(dat(j),j=1,jjz)       !Read raw data saved by WSJT
  df1=11025.0/256.0                         !df for the ps() spectrum

  jz=NPTS
  freezedf=0.
  dftol=441.0/2.0
  call dfdt441(dat,jz,freezedf,dftol,tmsg,nmsg,xdfpk,idtpk,sbest,ppk)

  write(*,1020) tmsg(1:8),nmsg,nint(xdfpk),idtpk,nint(sbest),ppk
1020 format(a8,'  Nmsg:',i3,'  DF:',i4,'  DT:',i5,'  S:'i6,'  P:',f7.2)

999 end program t441
