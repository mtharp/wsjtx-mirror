program acfs

  character*63 ctmp
  real acf1(0:50)
  real acf2(0:50)
  integer is1(207)
  integer is2(207)
  data is1/                                                       &
       0,0,0,0,1,1,0,0,0,1,1,0,1,1,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0, &
       0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,0,0, &
       1,0,0,1,0,0,1,1,1,1,1,0,0,0,1,0,1,0,0,0,1,1,1,1,0,1,1,0,0,1, &
       0,0,0,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,0,1,0,1, &
       0,1,1,1,0,0,1,0,1,1,0,1,1,1,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,1, &
       0,1,1,1,0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1, &
       1,0,0,1,1,0,0,0,0,1,1,0,0,0,1,0,1,1,0,1,1,1,1,0,1,0,1/
  data m1/z'4314f472'/,m2/z'5bb357e0'/

  write(ctmp,1000) m1,m2
1000 format(b31.31,b32.32)
  read(ctmp,1002) is2(1:63)
1002 format(63b1)

  j=0
  do i=64,207
     j=j+1
     if(j.gt.63) j=j-63
     is2(i)=is2(j)
  enddo

  sq1=0.
  sq2=0.
  do lag=0,50
     n1=0
     n2=0
     do i=1,207-lag
        j=i+lag
        if(is1(i).eq.is1(j)) n1=n1+1
        if(is2(i).eq.is2(j)) n2=n2+1
        if(is1(i).ne.is1(j)) n1=n1-1
        if(is2(i).ne.is2(j)) n2=n2-1
     enddo
     acf1(lag)=float(n1)/(207.0-lag)
     acf2(lag)=float(n2)/(207.0-lag)
     sq1=sq1 + acf1(lag)**2
     sq2=sq2 + acf2(lag)**2
     write(13,1010) lag,acf1(lag),acf2(lag)
1010 format(i2,2f10.4)
  enddo

  rms1=sqrt((sq1-1.0)/50.0)
  rms2=sqrt((sq2-1.0)/50.0)
  print*,sum(is1),rms1,maxval(acf1(2:))
  print*,sum(is2),rms2,maxval(acf2(2:))

end program acfs
