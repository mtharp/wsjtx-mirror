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
  nn=0
  map65=1

  do iping=1,999
     if(map65.eq.0) then
        read(10,end=100) ndop,nfrit,nsum0,nclearave0,nqual0,f1,rms,        &
          snrdb,dfreq,width
        read(10) id2                              !Read soundcard data
        call avecho(id2,ndop,nfrit,nsum,nclearave,nqual,                   &
             f1,rms,sigdb,snr,dfreq,width,blue,red)
        write(*,3001) nsum0,ndop,nfrit,nclearave0,f1,rms,sigdb,snr,width,nqual
3001    format(4i6,f8.1,4f7.1,i4)
        df=48000.0/131072.0
     else
        if(index(infile,'141223_200836.eco').ge.1) then
           read(10,end=100) ndop,nfrit,nsum0,nclearave0,nqual0,f1,rms,        &
                snrdb,dfreq,width
           techo=2.44
           fspread=2.0
           fsample=96000.0
           dop=ndop
           ndop0=ndop
        else
           read(10,end=100) dop,nfrit,nsum0,nclearave0,nqual0,f1,rms,        &
                snrdb,dfreq,width,techo,fspread,fsample
        endif
        read(10) cc                               !Read MAP65 data
!        if(mod(iping,10).eq.1) nn=0
        call avecho65(cc,dop,nn,techo,fspread,fsample,i00,dphi,t0,f1a,    &
             dl,dc,pol,delta,rms1,rms2,snr,sigdb,dfreq,width,red,blue)
     write(*,3002) nn,dop,t0,f1,f1a,dl,dc,pol,delta,sigdb,snr
3002 format(i3,f8.1,f8.3,2f9.1,2f7.2,4f7.1)
!...,rms,sigdb,snr,width,nqual, ...?
     df=96000.0/(256*1024)
     endif
  enddo

100 continue

!  call smo121(red,2000)
!  call smo121(blue,2000)

!  do i=1,2000
!     freq=(i-1001)*df
!     write(15,1100) freq,red(i),blue(i)
!1100 format(3f10.3)
!  enddo

999 end program tstecho
