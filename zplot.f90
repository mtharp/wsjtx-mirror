subroutine zplot(amp,nz,jj,ave,rms)

  real amp(nz)
  character*1 line(128),mark(0:6)
  data mark/' ',' ','-','+','#','X','$'/

  sum=0.
  smax=0.
  do i=1,nz
     sum=sum+amp(i)
     if(amp(i).gt.smax) then
        smax=amp(i)
        ipk=i
     endif
  enddo
  ave=(sum-smax)/(nz-1)
  sq=0.
  do i=1,nz
     if(i.ne.ipk) sq=sq+(amp(i)-ave)**2
  enddo
  rms=sqrt(sq/(nz-2))

  do i=1,nz
!     n=(amp(i)-ave)/rms
     n=(amp(i)-ave)/0.33
     if(n.lt.0) n=0
     if(n.gt.6) n=6
     line(i)=mark(n)
  enddo
  write(89,1010) jj,ave,rms,(line(i),i=1,nz)
1010 format(i3,2f6.2,1x,64a1)
  
  return
end subroutine zplot
