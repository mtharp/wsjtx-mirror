program tstecho

  parameter (LENGTH=27*4096)
  integer*2 id2
  common/datcom/id2(LENGTH),ndop,ntc,necho,nfrit,ndither,nsave,nsum,    &
       nclearave,f1,snrdb,red(1000),blue(1000)

  open(10,file='echo.dat',status='old',access='stream')

  nclearave=1
  nsum=0

  do iping=1,999
     read(10,end=999) id2,ndop,ntc,necho,nfrit,ndither,nsave,nsum0,     &
          nclearave0,f1,snrdb,red,blue
!     write(*,1010) iping,ndop,f1,snrdb
!1010 format(2i8,2f10.2)
     nfrit=200
     call avecho(id2,ndop,nfrit,f1,nsum,nclearave)
  enddo

999 end program tstecho
