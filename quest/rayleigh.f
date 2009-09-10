      function rayleigh()

      data idum/-1/,sqrt2/1.4142135/
      save

 1    u1=2.0*ran1(idum)-1.0
      u2=2.0*ran1(idum)-1.0
      s=u1*u1 + u2*u2
      if(s.ge.1.0) go to 1

      x1=u1*sqrt2*sqrt(-log(s)/s)
      x2=u2*sqrt2*sqrt(-log(s)/s)
      rayleigh=sqrt(x1*x1 + x2*x2)/sqrt2

      return
      end
