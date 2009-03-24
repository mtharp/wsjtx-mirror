program findfac

  implicit real*8 (a-h,o-z)
  integer na(10)
  integer nb(200)
  integer nc(200)
  character*12 arg
  data na/684,686,690,693,696,700,702,704,714,715/

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: findfac <f_low> <err>'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) f0
  call getarg(2,arg)
  read(arg,*) err


  open(10,file='nfft.1',status='old')
  do i=1,200
     read(10,*,end=10) nb(i)
  enddo
10 nbz=i-1

  open(10,file='nfft.2',status='old')
  do i=1,200
     read(10,*,end=20) nc(i)
  enddo
20 ncz=i-1

  fsiq=66666666.67
  do i=1,10
     fs=fsiq/na(i)
     do j=1,nbz
        do k=1,ncz
           flow=nb(j)*fs/nc(k)
           if(abs(flow-f0).lt.err) then
              trec=nc(k)/fs
              if(trec.gt.53.0 .and. trec.lt.57.0) then
                 write(*,1100) na(i),nb(j),nc(k),fs,trec,flow
                 write(13,1100) na(i),nb(j),nc(k),fs,trec,flow
1100             format(i3,i8,i10,f10.1,f6.1,f10.3)
                 write(14,*) nb(j)
                 write(14,*) nc(k)
              endif
           endif
        enddo
     enddo
  enddo

999 end program findfac
