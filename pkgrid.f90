subroutine pkgrid(grid,ng,ntext)

  parameter (NGBASE=180*180)
  character*4 grid

  ntext=0
  if(grid.eq.'    ') then                     !Blank grid is OK
     ng=NGBASE + 1
     go to 100
  endif

!  Test for numerical signal report
  j=ichar(grid(1:1))
  if(j.ge.48 .and. j.le.51) grid='+'//grid
  j=ichar(grid(2:2))
  if(grid(1:1).eq.'R' .and. j.ge.48 .and. j.le.51) grid='R+'//grid(2:)
  if(grid(1:1).eq.'-' .or. grid(1:1).eq.'+') then
     n=10*(ichar(grid(2:2))-48) + ichar(grid(3:3)) - 48
     if(grid(3:3).eq.' ') n=ichar(grid(2:2))-48
     if(grid(1:1).eq.'-') n=-n
     if(n.lt.-30) n=-30
     if(n.gt.30) n=30
     ng=NGBASE+1+31+n
     go to 100
  else if(grid(1:2).eq.'R-' .or. grid(1:2).eq.'R+') then
     n=10*(ichar(grid(3:3))-48) + ichar(grid(4:4)) - 48
     if(grid(4:4).eq.' ') n=ichar(grid(3:3))-48
     if(grid(2:2).eq.'-') n=-n
     if(n.lt.-30) n=-30
     if(n.gt.30) n=30
     ng=NGBASE+1+92+n
     go to 100
  else if(grid(1:2).eq.'RO') then
     ng=NGBASE+1+123
     go to 100
  else if(grid(1:3).eq.'RRR') then
     ng=NGBASE+1+124
     go to 100
  else if(grid(1:2).eq.'73') then
     ng=NGBASE+1+125
     go to 100
  endif
  
  if(grid(1:1).lt.'A' .or. grid(1:1).gt.'R') ntext=1
  if(grid(2:2).lt.'A' .or. grid(2:2).gt.'R') ntext=1
  if(grid(3:3).lt.'0' .or. grid(3:3).gt.'9') ntext=1
  if(grid(4:4).lt.'0' .or. grid(4:4).gt.'9') ntext=1
  if(ntext.ne.0) go to 100

  call grid2deg(grid//'mm',dlong,dlat)
  long=dlong
  lat=dlat+ 90.0
  ng=((long+180)/2)*180 + lat
  go to 100

100 return
end subroutine pkgrid
