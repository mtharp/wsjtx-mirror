program tstecho

! Process data recorded by EMEcho.

  parameter (LENGTH=27*4096)
  integer*2 id2(260000)                 !Raw data from soundcard
  complex cc(2,520000)                  !Raw data from MAP65
  real blue(2000),red(2000)
  character*40 infile
  character outline*60
  integer junk(9)
  real*8 uth8,AzSun8,ElSun8,AzMoon8,ElMoon8,AzMoonB8,ElMoonB8,     &
       dop8,dop008,RAMoon8,DecMoon8,Dgrd8,poloffset8,xnr8,techo8,width1

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
  dphi=-40.0                                        !Expected phase difference
  i00=0                                             !Expected i0
  nn=0
  map65=1
  nhdr=1

!###
  ih=00
  im=25
  is=-6
!###

  do iping=1,1
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
!###
!           read(10,end=100) dop,nfrit,nsum0,nclearave0,nqual0,f1,rms,        &
!                snrdb,dfreq,width,techo,fspread,fsample
           read(10,end=100) techo,fspread,fsample,junk

           nyear=2015
           month=1
           nday=2
           uth8=00 + 25.d0/60.d0 + (03.d0+(iping-1.d0)*6.d0)/3600.d0 
           nfreq=144
           call astrosub(nyear,month,nday,uth8,nfreq,'FN20qi','FN20qi',    &
                AzSun8,ElSun8,AzMoon8,ElMoon8,AzMoonB8,ElMoonB8,ntsky,     &
                dop8,dop008,RAMoon8,DecMoon8,Dgrd8,poloffset8,xnr8,techo8, &
                width1)
           dop=dop8
           naz=nint(azmoon8)
           nel=nint(elmoon8)
           is=is+6
           if(is.eq.60) then
              is=0
              im=im+1
           endif
           if(im.eq.60) then
              im=0
              ih=ih+1
           endif
           nutc=ih*10000 + im*100 + is
!           print*,nutc,azmoon8,elmoon8,dop
!###
        endif
        read(10) cc                               !Read MAP65 data
        if(mod(iping,10).eq.1) nn=0
        call avecho65(cc,nutc,naz,nel,dop,nn,techo,fspread,fsample,i00,dphi,  &
             t0,f1a,dl,dc,pol,delta,rms1,rms2,snr,sigdb,dfreq,width,red,blue, &
             outline)

        ndb=nint(sigdb)
        nsnr=nint(snr)
        npol=nint(pol)
        ndelta=nint(delta)

        if(nhdr.eq.1) write(*,1000)
1000    format(/'  UTC    N  Az  El  dB  S/N   DF    W  Pol   d    Lin  Circ Teme   Dop   Spread'/79('-'))
        nhdr=0
        write(*,1010) nutc,nn,naz,nel,ndb,nsnr,dfreq,width,npol,ndelta,dl,dc, &
             techo,dop,fspread
1010    format(i6.6,i4,4i4,2f6.1,i4,i5,2f6.2,f5.2,f8.1,f6.1)

     endif
  enddo

100 continue

999 end program tstecho
