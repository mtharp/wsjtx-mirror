program echodop

  implicit real*8 (a-h,o-z)
  character*6 mygrid,hisgrid

  nyear=2015
  month=1
  nday=2
  dt=1.d0/60.d0
  uth8=20.0d0-dt
  nfreq=144
  mygrid='FN20qi'
  hisgrid='FN20qi'

  do i=1,900
     uth8=uth8+dt
     call astrosub(nyear,month,nday,uth8,nfreq,mygrid,hisgrid,           &
     AzSun8,ElSun8,AzMoon8,ElMoon8,AzMoonB8,ElMoonB8,ntsky,dop8,dop008,  &
     RAMoon8,DecMoon8,Dgrd8,poloffset8,xnr8,techo8,width1)

     write(*,1000) i,uth8,15.d0*RAMoon8,DecMoon8,AzMoon8,ElMoon8,techo8,dop008
1000 format(i3,f7.3,4f7.2,f7.3,f9.3)
  enddo

end program echodop
