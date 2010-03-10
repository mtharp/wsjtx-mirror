subroutine echogen(dither,iwave,nwave,f1)

  parameter (NMAX=3*12000)          !Length of wave file
  real dither                       !Amount to dither f1
  integer*2 iwave(NMAX)             !Wave file to be generated
  integer nwave                     !Length of wave file
  real f1                           !Generated audio frequency
  data twopi/6.283185307/,idummy/-1/
  save

  call random_number(r)
  f1=1270.46 + dither*(r-0.5)       !Define the TX frequency
  
  dt=1.0/12000.0
  t=0.
  do i=1,NMAX
     t=t+dt
     iwave(i)=nint(32767.0*sin(twopi*f1*t))
  enddo
  print*,'f1:',f1
  nwave=NMAX

  return
end subroutine echogen
