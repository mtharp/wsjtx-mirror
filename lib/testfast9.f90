program testfast9

  parameter (NMAX=15*12000)
  integer*2 id2(NMAX)
  integer narg(0:9)
  character*80 line(100)
  

!  open(10,file='150730_191115.wav',access='stream',status='old')   !E
  open(10,file='150730_191345.wav',access='stream',status='old')   !H
  read(10) id2(1:22)                     !Skip 44 header bytes
  npts=NMAX
  read(10) id2(1:npts)                   !Read the raw data

  narg(0)=191345
  narg(1)=npts
  narg(2)=1
  narg(3)=1
  narg(4)=0
  narg(5)=0
  narg(6)=0
  narg(7)=14975
  narg(8)=1
  narg(9)=1

  call fast9(id2,narg,line)
  print*,line(1)

end program testfast9
