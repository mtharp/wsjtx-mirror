program rsdtest0

  parameter (NMAX=10000)
  integer*1 mrsym1(0:62),mr2sym1(0:62),mrprob1(0:62),mr2prob1(0:62)
  integer mrsym(0:62),mr2sym(0:62),mrprob(0:62),mr2prob(0:62)
  integer dgen(12),sym(0:62),sym_rev(0:62)
  integer*1 sym1(0:62,NMAX)
  character arg*12,msg*22,ceme*3
  character*6 mycall,hiscall(NMAX)
  character*4 hisgrid(NMAX)
  character c1*1,c4*4,c6*6
  logical*1 eme(NMAX)

  nargs=iargc()
  if(nargs.ne.3) then
     print*,'Usage: rsdtest0 neme ntrials nfiles'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) neme
  call getarg(2,arg)
  read(arg,*) ntrials
  call getarg(3,arg)
  read(arg,*) nfiles

  open(10,file='known_calls.txt',status='old')
  mycall='VK7MO '
  j=0
  do i=1,9999
     read(10,1000,end=10) c6,c1,c4,ceme
1000 format(a6,a1,5x,a4,8x,a3)
     if(c1.ne.' ') cycle
     if(neme.eq.1 .and. ceme.ne.'EME') cycle
     j=j+1
     hiscall(j)=c6
     hisgrid(j)=c4
     eme(j)=(ceme.eq.'EME')
  enddo
10 ncalls=j

  j=0
  do i=1,ncalls
     if(neme.eq.1 .and. (.not.eme(i))) cycle
     j=j+1
     msg=mycall//' '//hiscall(i)//' '//hisgrid(i)
     call fmtmsg(msg,iz)
     call packmsg(msg,dgen)                  !Pack message into 72 bits
     call rs_encode(dgen,sym_rev)            !RS encode
     sym(0:62)=sym_rev(62:0:-1)
     sym1(0:62,j)=sym
!     if(msg.eq.'VK7MO K1JT FN20') write(*,1050) j,sym(0:20)
!1050 format(i5,2x,21i3)
  enddo
  nused=j

  open(12,file='mrsym-24.bin',access='stream', status='old')

  nadd=1
  ifile0=0
  if(nfiles.lt.0) then
     ifile0=-nfiles
     nfiles=99999
  endif

  do ifile=1,abs(nfiles)
     read(12,end=999) mrsym1,mrprob1,mr2sym1,mr2prob1
     if( ifile.lt.ifile0 ) cycle

     mrsym=mrsym1
     mrprob=mrprob1
     mr2sym=mr2sym1
     mr2prob=mr2prob1
     where(mrprob<0) mrprob=mrprob+256
     where(mr2prob<0) mr2prob=mr2prob+256

     call extr2(mrsym,mrprob,mr2sym,mr2prob,sym1,nused,ntrials)
     if(ifile.eq.ifile0) exit
  enddo

999 end program rsdtest0
