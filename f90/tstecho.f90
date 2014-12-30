program tstecho

! Process data recorded by EMEcho.

  parameter (LENGTH=27*4096)
  integer*2 id2(260000)                 !Raw data from soundcard
  complex cc(2,520000)                  !Raw data from MAP65
  real blue(2000),red(2000)
  character*40 infile

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: tstecho <infile>'
     go to 999
  endif
  call getarg(1,infile)

  open(10,file=infile,status='old',access='stream',err=1)
  go to 10
1 print*,'Cannot open ',infile
  go to 999

10  nclearave=1
  nsum=0
  dphi=88.0                                       !Expected phase difference
  i00=4                                           !Expected i0

  do iping=1,999
     read(10,end=100) ndop,nfrit,nsum0,nclearave0,nqual0,f1,rms,        &
          snrdb,dfreq,width
     if(nqual0/1000.eq.0) then
        read(10) id2                              !Read soundcard data
        call avecho(id2,ndop,nfrit,nsum,nclearave,nqual,                   &
             f1,rms,sigdb,snr,dfreq,width,blue,red)
        write(*,3001) nsum0,ndop,nfrit,nclearave0,f1,rms,sigdb,snr,width,nqual
3001    format(4i6,f8.1,4f7.1,i4)
        df=48000.0/131072.0
     else
        read(10) cc                               !Read MAP65 data
        dop=ndop
        nn=iping-1
        call avecho65(cc,dop,nn,i00,dphi,t0,f1a,dl,dc,pol,delta,red,blue)
     write(*,3002) iping,ndop,nclearave0,t0,f1,f1a,dl,dc,pol,delta
3002 format(i3,i6,i2,f8.3,2f9.1,2f7.2,2f7.1)
!...,rms,sigdb,snr,width,nqual, ...?
     df=96000.0/(256*1024)
     endif
  enddo

100 continue

!  call smo121(red,2000)
!  call smo121(blue,2000)

  do i=1,2000
     freq=(i-1001)*df
     write(15,1100) freq,red(i),blue(i)
1100 format(3f10.3)
  enddo

999 end program tstecho
