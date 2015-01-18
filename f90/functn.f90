real*8 function functn(x,i,a)

  implicit real*8 (a-h,o-z)
  real*8 x(100)
  real*8 a(5)

  z=abs((x(i)-a(3))/a(4))
  functn=a(1) + a(2)/(1.d0 + z**a(5))

  return
end function functn
