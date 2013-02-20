real*8 FUNCTION factrl(n)
  implicit real*8 (a-h,o-z)
  real*8 a(33)
  SAVE ntop,a
  DATA ntop,a(1)/0,1./
  if (n.lt.0) then
     stop 'negative factorial in factrl'
  else if (n.le.ntop) then
     factrl=a(n+1)
  else if (n.le.32) then
     do j=ntop+1,n
        a(j+1)=j*a(j)
     enddo
     ntop=n
     factrl=a(n+1)
  else
     factrl=exp(gammln(n+1.0d0))
  endif

  return
END FUNCTION factrl
