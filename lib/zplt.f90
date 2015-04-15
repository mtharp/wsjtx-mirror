subroutine zplt(z)
  real z(458,65)
  integer ij(2)
  character*4 lab

  call imopen("testjt4.ps")
  call imfont("Helvetica",16)
  call impalette("BlueRed.pal")

  zmin=minval(z)
  zmax=maxval(z)
  flip=1.0
  if(abs(zmin).gt.abs(zmax)) flip=-1.0

  ij=maxloc(z)
  if(flip.lt.0.0) ij=minloc(z)

  write(*,1010) irec,sync,snrx,dtx,nfreq,nint(flip),zmin,zmax,ij
1010 format(i2,2f6.1,f6.2,i6,i3,2f7.2,2i5)

  zmax=max(abs(zmin),abs(zmax))
  zmin=-zmax

  dtq=0.114286
  do j=1,65
     write(61,1100) j*dtq-0.8,z(ij(1),j)
1100 format(2f10.3)
  enddo

  df=11025.0/(2.0*2520.0)
  do i=1,458
     write(62,1100) (i+273)*df,flip*z(i,ij(2))
  enddo

  xx=1.5
  yy=6.0
  width=6.0
  height=2.0
  IP=458
  JP=65
  imax=IP
  jmax=JP

  zmin=-1.4
  zmax=1.4

  call imr4mat_color(z,IP,JP,imax,jmax,zmin,zmax,xx,yy,   &
       width,height,1)
  call imstring("Frequency (Hz)",xx+0.5*width,yy-0.5,2,0)
  dy=0.1
  do i=1,9
     x=xx + 0.1*i*width
     call imyline(x,yy,dy)
     call imyline(x,yy+height,-dy)
  enddo
  do i=1,6
     nf=(i-1)*200 + 600
     write(lab,1020) nf
1020  format(i4)
     x=xx + (i-1)*0.2*width
     call imstring(lab,x,yy-0.25,2,0)
  enddo

  dx=0.1
  do i=0,6
     y=yy + height*(0.8+i)/(65.0*0.114286)
     call imxline(xx,y,dx)
     call imxline(xx+width,y,-dx)
  enddo

  do i=0,6,2
     y=yy + height*(0.8+i)/(65.0*0.114286)
     write(lab,1020) i
     call imstring(lab(4:4),xx-0.15,y-0.08,2,0)
  enddo

  y=yy + height*(3.8)/(65.0*0.114286)
  call imstring("DT", xx-0.5,y     ,2,0)
  call imstring("(s)",xx-0.5,y-0.25,2,0)

  call imclose

  return
end subroutine zplt
