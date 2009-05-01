program t441

! Run decoding tests on the "TNX QSO TNX QSO ..." ping in W8WN sample file.

  character*28 tmsg
  character*12 arg
  real ps(128)                              !Spectrum computed in WSJT
  real dat(50000)                           !Raw data, 11025 S/s

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: t441 <nrec> "Test message"'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) nrec
  call getarg(2,tmsg)

  open(88,file='dat2.88',form='unformatted',status='old')
  do i=1,9999
     read(88,end=999) irec,jz,(dat(j),j=1,jz)   !Read data saved by WSJT
     if(irec.eq.nrec) go to 10
  enddo
  go to 999

10  continue
  freezedf=0.
  dftol=441.0/2.0
  call dfdt441(dat,jz,freezedf,dftol,tmsg,nmsg,xdfpk,idtpk,sbest,ppk)

  write(*,1020) tmsg(1:8),nmsg,nint(xdfpk),idtpk,nint(sbest),ppk
1020 format(a8,'  Nmsg:',i3,'  DF:',i4,'  DT:',i5,'  S:'i6,'  P:',f7.2)

999 end program t441
