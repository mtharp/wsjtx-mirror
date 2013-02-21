subroutine ex28(sym,c72,data1,qual)

  real sym(0:1,206)
  character*72 c72,c72a
  integer*1 data0(13),data1(13)
  integer*1 symbol(206)
  real s(0:16383)

  c72a=c72
  sumbest=0.
  do n2a=0,16383
     write(c72(1:14),1002) n2a
1002 format(b14.14)
     read(c72,1004) data0(1:9)
1004 format(9b8)
     data0(10:13)=0
     call encode232(data0,206,symbol)       !Convolutional encoding
     sum=0.
     do i=1,90
        if(symbol(i).eq.0) then
           sum=sum + sym(0,i)
        else 
           sum=sum + sym(1,i)
        endif
     enddo
     s(n2a)=sum
     if(sum.gt.sumbest) then
        sumbest=sum
        n2abest=n2a
     endif
  enddo
  s(n2abest)=0.
  s1a=sumbest
  s2a=maxval(s)
  qa=100.0*s1a/s2a - 106.0

  c72=c72a
  sumbest=0.
  do n2b=0,16383
     write(c72(59:72),1002) n2b
     read(c72,1004) data0(1:9)
     data0(10:13)=0
     call encode232(data0,206,symbol)       !Convolutional encoding
     sum=0.
     do i=117,206
        if(symbol(i).eq.0) then
           sum=sum + sym(0,i)
        else 
           sum=sum + sym(1,i)
        endif
     enddo
     s(n2b)=sum
     if(sum.gt.sumbest) then
        sumbest=sum
        n2bbest=n2b
     endif
  enddo
  s(n2bbest)=0.
  s1b=sumbest
  s2b=maxval(s)
  qb=100.0*s1b/s2b - 106.0
  qual=min(qa,qb)

  write(c72(1:14),1002) n2abest
  write(c72(59:72),1002) n2bbest
  read(c72,1004) data1(1:9)
  data1(10:13)=0

  write(72,3002) n2abest,qa,n2bbest,qb
3002 format(i8,f10.3,i10,f10.3)

  return
end subroutine ex28
