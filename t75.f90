program t75

! Tests experimental ISCAT decoder

  parameter (NMAX=30*3101)
  complex cdat(NMAX)                      !Raw signal, 30 s at 11025 sps
  character arg*12                        !Command-line argument
  character cfile6*6                      !File time
  character*40 infile
  integer dftolerance
  real psavg(450)         !Average spectrum of the whole file
  logical pick

  nargs=iargc()
  if(nargs.ne.4) then
     print*,'Usage: t75 infile nh npct nrec'
     go to 999
  endif
  call getarg(1,infile)
  call getarg(2,arg)
  read(arg,*) nh
  call getarg(3,arg)
  read(arg,*) npct
  call getarg(4,arg)
  read(arg,*) nrec
  open(74,file=infile,form='unformatted',status='old')

  MinSigdB=-20
  DFTolerance=400
  NFreeze=0
  MouseDF=0
  mousebutton=0
  mode4=2
  nafc=0
  nmore=0
  pick=.false.

  do irec=1,nrec
     read(74,end=999) npts,cfile6,cdat(1:npts)
     if(irec.ne.nrec .and. nrec.ne.999) cycle
     t2=0.
     call iscat(cdat,npts,nh,npct,t2,pick,cfile6,MinSigdB,DFTolerance,NFreeze, &
     MouseDF,mousebutton,mode4,nafc,nmore,psavg)
  enddo

999 end program t75
