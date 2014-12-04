program tstecho

  parameter (LENGTH=27*4096)
  integer*2 id2
  real blue(2000),red(2000)
  common/datcom/id2(LENGTH),ndop,ntc,necho,nfrit,ndither,nsave,nsum,    &
       nclearave,f1,snrdb,red0(2000),blue0(2000)

  open(10,file='echo_3.dat',status='old',access='stream')

  nclearave=1
  nsum=0

  do iping=1,999
     read(10,end=100) id2,ndop,ntc,necho,nfrit,ndither,nsave,nsum0,     &
          nclearave0,f1,snrdb,red0,blue0
     nfrit=200
     call avecho(id2,ndop,nfrit,f1,nsum,nclearave,rms,blue,red)
  write(*,3001) nsum,ndop,nfrit,nclearave,f1,rms
3001 format(4i6,2f8.1)
  enddo

100 continue
  call smo121(red,2000)
  call smo121(red,2000)
  df=48000.0/131072.0
  do i=1,2000
     freq=(i-1000)*df
     write(15,1100) freq,blue(i),red(i)
1100 format(3f10.3)
  enddo

999 end program tstecho
