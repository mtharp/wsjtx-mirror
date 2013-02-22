subroutine exhaust(itype,sym,c72,data1,nqual)

  real sym(0:1,206)
  character*72 c72,c72a
  integer*1 data0(13),data1(13)
  integer*1 symbol(206)
  real s(0:16383)

  if(itype.eq.1) go to 100      !###
  if(itype.eq.2) go to 100
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
  qa=100.0*(s1a/s2a - 1.0)

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
  qb=100.0*(s1b/s2b - 1.0)
  q=min(qa,qb)
  nqual=1.5*(q-4.0)
  if(nqual.lt.0) nqual=0
  if(nqual.gt.10) nqual=10

  write(c72(1:14),1002) n2abest
  write(c72(59:72),1002) n2bbest
  read(c72,1004) data1(1:9)
  data1(10:13)=0
  return

!  write(72,3002) n2abest,qa,n2bbest,qb
!3002 format(i8,f10.3,i10,f10.3)

100 continue
! Exhaustive search for xrpt
  c72a=c72
  sumbest=0.
  do ng=32402,32464
     write(c72(57:72),1003) ng
1003 format(b16.16)
     read(c72,1004) data0(1:9)
     data0(10:13)=0
     call encode232(data0,206,symbol)       !Convolutional encoding
     sum=0.
     do i=113,206
        if(symbol(i).eq.0) then
           sum=sum + sym(0,i)
        else 
           sum=sum + sym(1,i)
        endif
     enddo
     s(ng-32401)=sum
     if(sum.gt.sumbest) then
        sumbest=sum
        ngbest=ng
     endif
  enddo
  s(ngbest-32401)=0.
  s1a=sumbest
  s2a=maxval(s(1:63))
  q=100.0*(s1a/s2a - 1.0)
  nqual=q-8.0
  if(ngbest.ne.32425) write(72,3002) sum,q,nqual
3002 format(2f10.3,i6)
  if(nqual.lt.0) nqual=0
  if(nqual.gt.10) nqual=10

  write(c72(57:72),1003) ngbest
  read(c72,1004) data1(1:9)
  data1(10:13)=0

  return
end subroutine exhaust
