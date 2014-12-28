subroutine polfit(csx,csy,iping,i0,ss)

  complex csx(-1000:1000),csy(-1000:1000)
  complex w,z
  real ss(18,18)
  data nwh/1/

  if(iping.eq.1) ss=0.
  smax=0.
  jpk=1
  kpk=1
  do j=1,18
     pol=(j-1)*10.0
     th=pol/57.2957795
     a=cos(th)
     b=sin(th)
     do k=1,18
        dphi=(k-1)*20.0
        w=cmplx(cos(dphi/57.2957795),sin(dphi/57.2957795))
        s=0.
        do i=0,nwh
           z=a*csx(i0+i) + b*w*csy(i0+i)
           s=s + abs(z)**2
           if(i.eq.0) cycle
           z=a*csx(i0-i) + b*w*csy(i0-i)
           s=s + abs(z)**2
        enddo
        ss(j,k)=ss(j,k) + s
        if(k.le.9 .and. ss(j,k).gt.smax) then
           jpk=j
           kpk=k
           smax=ss(j,k)
        endif
     enddo
  enddo

  fac=1000.0/iping
  rewind 27
  write(27,1000) ((k-1)*22.5,k=1,12)
1000 format(4x,12f6.1/76('-'))
  do j=1,18
     write(27,1010) (j-1)*10,nint(fac*ss(j,1:12))
1010 format(i3,12i6)
  enddo
  write(27,1010) 180,nint(fac*ss(1,1:12))
  flush(27)

  fac=100.0/iping
  s=0.
  a=0.
  b=0.
  do j=1,18
     th=(j-1)*20.0/57.2957795
     s=s + ss(j,kpk)
     a=a + ss(j,kpk)*cos(th)
     b=b + ss(j,kpk)*sin(th)
  enddo
  s=fac*s
  a=fac*a
  b=fac*b
  a0=s/18.0
  a1=sqrt(a*a + b*b)/9.0
  a2=0.5*atan2(b,a)
  pol=57.2957795*a2
  if(pol.lt.0.0) pol=pol+180.0
  print*,'A',iping,jpk,kpk,s,a,b,a0,a1,nint(pol)

  s=0.
  a=0.
  b=0.
  do k=1,18
     th=(k-1)*20.0/57.2957795
     s=s + ss(jpk,k)
     a=a + ss(jpk,k)*cos(th)
     b=b + ss(jpk,k)*sin(th)
  enddo
  s=fac*s
  a=fac*a
  b=fac*b
  b0=s/18.0
  b1=sqrt(a*a + b*b)/9.0
  b2=atan2(b,a)
  phi=57.2957795*b2

  print*,'B',s,a,b,b0,b1,nint(phi)

  write(28,1020) a0,a1,nint(pol),b0,b1,nint(phi)
1020 format('a0:',f7.2,'   a1:',f7.2,'   pol:',i4,'   b0:',f7.2,     &
          '   b1:',f7.2,'   dphi:',i5)

  return
end subroutine polfit
