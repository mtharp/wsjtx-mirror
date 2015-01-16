program testmoon3

  implicit real*8 (a-h,o-z)
  real*8 mjd,mjd0                !Modified Julian Date
  real*4 r4long,r4lat            !Longitude and geodetic latitude of obs
  real*8 y1(200),y2(200)
  character*12 arg
  character*6 grid
  logical compare

  twopi=8.d0*atan(1.d0)            !Define some constants
  rad=360.d0/twopi
  clight=2.99792458d5
  freq=1000.0d6

  nargs=iargc()
  if(nargs.lt.4 .or. nargs.gt.5) then
     print*,'Usage: testmoon3 mjd toffset west_long lat height'
     print*,'       testmoon3 mjd toffset grid height'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) mjd0
  call getarg(2,arg)
  read(arg,*) toffset

  if(nargs.eq.4) then
     call getarg(3,grid)
     call grid2deg(grid,r4long,r4lat) !Longitude and (geodetic) latitude, deg
     west_long=r4long/rad
     east_long=-west_long             !Change to East longitude
     geodetic_lat=r4lat/rad
     call getarg(4,arg)
     read(arg,*) height
  else
     call getarg(3,arg)
     read(arg,*) west_long
     call getarg(4,arg)
     read(arg,*) geodetic_lat
     r4long=real(west_long)
     r4lat=real(geodetic_lat)
     call deg2grid(r4long,r4lat,grid)
     east_long=-west_long/rad
     geodetic_lat=geodetic_lat/rad
     call getarg(5,arg)
     read(arg,*) height
  endif

  call sla_DJCL(mjd0,iy,im,id,fd,ierr)
  write(*,1000) mjd0,iy,im,id,fd*24.d0,toffset
1000 format(/'Start time: ',f13.6,i6,2i3,f10.6,f7.2)

  write(*,1002) grid,-rad*east_long,rad*geodetic_lat,height
1002 format('Location:'4x,a6,2f11.6,f8.1)

  open(10,file='ref_file',status='old',err=1)
  compare=.true.
  go to 2
1 compare=.false.
2 dt=10.d0/1440.d0
  thrs=-99
  y1=0
  y2=0
  nn=0

  do iter=1,9999
     mjd=mjd0 + (iter-1)*dt + toffset/86400.d0
     call ephem(mjd,east_long,geodetic_lat,height,RA,Dec,Az,El,techo,   &
          dop,fspread_1GHz)
     if(El.lt.0.d0 .and. thrs.gt.0.0d0) exit
     if(El.lt.0.d0) cycle
     if(thrs.lt.0.d0) thrs=(mjd-int(mjd)-dt)*24.d0
     thrs=thrs + dt*24.d0
     write(14,1050) thrs,RA*rad,Dec*rad,Az*rad,El*rad,techo,dop,fspread_1GHz
1050 format(f7.3,4f7.2,f7.3,f11.3,f9.3)

!###
! Compare with the present WSJT/MAP65/WSJT-X Doppler calcs
!     nyear=2015
!     month=1
!     nday=2
!     nfreq=144
!     grid='FN20qi'
!     call astrosub(nyear,month,nday,thrs,nfreq,grid,grid,                 &
!     AzSun,ElSun,AzMoon,ElMoon,AzMoonB,ElMoonB,ntsky,dop2,dop00,          &
!     RAMoon,DecMoon,Dgrd,poloffset,xnr,techo2,width1)
!     write(15,1050) thrs,RAMoon*15.d0,DecMoon,AzMoon,ElMoon,techo2,dop2,width1
!     write(16,1050) thrs,RA*rad-RAMoon*15.d0,Dec*rad-DecMoon,             &
!          Az*rad-AzMoon,El*rad-ElMoon,techo-techo2,0.144118d0*dop-dop2,   &
!          fspread_1GHz-width1
!###

     if(compare) then
! Compare with previously calculated results
        read(10,*) t0,RA0,Dec0,Az0,El0,techo0,dop0,fspread0
        nn=nn+1
        y1(nn)=dop-dop0
        y2(nn)=fspread_1GHz-fspread0
        write(13,1100) thrs,y1(nn),y2(nn)
1100    format(f7.3,2f10.3)
     endif
  enddo

  if(compare) then
     ave1=sum(y1(1:nn))/nn
     ave2=sum(y2(1:nn))/nn
     y1min=minval(y1(1:nn))
     y2min=minval(y2(1:nn))
     y1max=maxval(y1(1:nn))
     y2max=maxval(y2(1:nn))
     write(*,1110) ave1,y1min,y1max
1110 format('Doppler:',3f10.3)
!     write(*,1120) ave2,y2min,y2max
!1120 format('Fspread:',3f10.2)
  endif

999 end program testmoon3
