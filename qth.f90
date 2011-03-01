program qth

  parameter (NMAX=20)
  real xlon(NMAX)
  real xlat(NMAX)
  character*6 callsign(NMAX)
  character*6 grid(NMAX)
  character*6 unknown

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: qth <call>'
     go to 999
  endif
  call getarg(1,unknown)

  open(10,file='qth.dat',status='old')
  do i=1,NMAX
     read(10,1010,end=10) callsign(i),grid(i),xlon(i),xlat(i)
1010 format(a6,2x,a6,1x,2f10.4)
  enddo
  i=NMAX+1

10 iz=i-1

  do i=1,iz
     do j=i+1,iz
        call geodist(xlat(i),-xlon(i),xlat(j),-xlon(j),az,baz,dist)
        write(*,1020) callsign(i),callsign(j),az,dist,dist/300.0
1020    format(a6,2x,a6,2x,2f8.0,f8.2)
     enddo
  enddo

999 end program qth
