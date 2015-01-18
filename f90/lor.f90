program lor

  implicit real*8 (a-h,o-z)
  parameter (NZ=100)
  real*8 x(NZ),y(NZ),sigmay(NZ),yfit(NZ)
  real*8 a(5),a0(5),deltaa(5),sigmaa(5)
  real*8 lambda
  real*4 gran

  open(10,file='lor.dat',status='old')
  read(10,*) nterms,mode,lambda,nverbose
  read(10,*) a0
  read(10,*) a
  read(10,*) deltaa

  write(*,1000)
1000 format("       Baseline   Amp     DF     width    exp"/50("-"))

  write(*,1002) "True: ",a0
  write(*,1002) "Guess:",a
  write(*,1002) "Dstep: ",deltaa
  write(*,1002) 
1002 format(a6,5f8.3)

  if(nverbose.ne.0) write(*,1004)
1004 format("  Iter  Baseline  Amp     DF     width    exp     chisq   lambda"&
          /66("-"))

  do i=1,NZ
     x(i)=i-50
     y(i)=functn(x,i,a0) + gran()
!     write(13,1010) x(i),y(i)
!1010 format(2f10.4)
  enddo

  sigmay=1.0
  chisqr0=1.e30
  do iter=1,20
     call curfit(x,y,sigmay,nz,nterms,mode,a,deltaa,sigmaa,lambda,yfit,chisqr)
     if(nverbose.ne.0) write(*,1020) iter,a,chisqr,lambda
1020    format(i6,5f8.3,f9.3,f10.6)
     if(chisqr/chisqr0.ge.0.999d0) exit
     chisqr0=chisqr
  enddo

     write(*,1030) 
     write(*,1030) "Fit:",a,chisqr
     write(*,1030) "Dev:",a-a0
     write(*,1030) "Err:",sigmaa
1030 format(a4,2x,5f8.3,f9.3)

  do i=1,NZ
     write(14,1040) x(i),y(i),yfit(i)
1040 format(3f10.4)
  enddo

end program lor
