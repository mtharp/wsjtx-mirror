program fcal

  parameter(NZ=1000)
  implicit real*8 (a-h,o-z)
  real*8 fd(NZ),deltaf(NZ),r(NZ)
  character infile*50

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: fcal <infile>'
     go to 999
  endif
  call getarg(1,infile)

  open(10,file=infile,status='old',err=997)

  i=0
  do j=1,9999
     read(10,*,err=5,end=10) f,df
     i=i+1
     fd(i)=f
     deltaf(i)=df
     r(i)=0.d0
5    continue
  enddo

10 iz=i
  if(iz.lt.2) go to 998
  call fit(fd,deltaf,r,iz,a,b,sigmaa,sigmab,rms)

  write(*,1002) 
1002 format('    Freq     DF     Meas Freq    Resid'/        &
            '   (MHz)    (Hz)      (MHz)       (Hz)'/        &
            '--------------------------------------')       
  do i=1,iz
     fm=fd(i) + 1.d-6*deltaf(i)
     calfac=1.d0 + 1.d-6*deltaf(i)/fd(i)
     write(*,1010) fd(i),deltaf(i),fm,r(i)
1010 format(f8.3,f8.2,f14.9,f8.2)
  enddo
  calfac=1.d0 + 1.d-6*b
  err=1.d-6*sigmab

  if(iz.ge.3) then
     write(*,1100) a,b,rms
1100 format(/'A:',f8.2,' Hz    B:',f9.6,' ppm    StdDev:',f6.2,' Hz')
  if(iz.gt.2) write(*,1110) sigmaa,sigmab
1110 format('err:',f6.2,9x,f9.6,23x,f13.9)
  else
     write(*,1120) a,b
1120 format(/'A:',f8.2,' Hz    B:',f9.6)
  endif

  go to 999

997 print*,'Cannot open input file: ',infile
  go to 999
998 print*,'Input file must contain at least 2 valid measurement pairs'

999 end program fcal

subroutine fit(x,y,r,iz,a,b,sigmaa,sigmab,rms)
  implicit real*8 (a-h,o-z)
  real*8 x(iz),y(iz),r(iz)

  sx=0.d0
  sy=0.d0
  sxy=0.d0
  sx2=0.d0
  do i=1,iz
     sx=sx + x(i)
     sy=sy + y(i)
     sxy=sxy + x(i)*y(i)
     sx2=sx2 + x(i)*x(i)
  enddo
  delta=iz*sx2 - sx*sx
  a=(sx2*sy - sx*sxy)/delta
  b=(iz*sxy - sx*sy)/delta

  sq=0.d0
  do i=1,iz
     r(i)=y(i) - (a + b*x(i))
     sq=sq + r(i)**2
  enddo
  rms=sqrt(sq/(iz-2))
  sigmaa=sqrt(rms*rms*sx2/delta)
  sigmab=iz*rms*rms/delta

  return
end subroutine fit
