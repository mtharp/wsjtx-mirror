program tstecho

  parameter (LENGTH=27*4096)
  integer*2 id2(260000)
  real blue(2000),red(2000)

  open(10,file='e:/141223_152106.eco',status='old',access='stream')

  nclearave=1
  nsum=0

  do iping=1,999
     read(10,end=100) ndop,nfrit,nsum0,nclearave0,nqual,f1,rms,   &
          snrdb,dfreq,width,id2
     call avecho(id2,ndop,nfrit,nsum,nclearave,nqual,                 &
          f1,rms,sigdb,snr,dfreq,width,blue,red)
     write(*,3001) nsum0,ndop,nfrit,nclearave0,f1,rms,sigdb,snr,width,nqual
3001 format(4i6,f8.1,4f7.1,i4)
  enddo

100 continue

!  call smo121(red,2000)
!  call smo121(red,2000)
  df=48000.0/131072.0
  do i=1,2000
     freq=(i-1000)*df
     write(15,1100) freq,red(i),blue(i)
1100 format(3f10.3)
  enddo

999 end program tstecho
