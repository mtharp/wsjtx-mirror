subroutine bestdx(datetime,grid2)

  character*4 grid2
  character*6 mygrid,hisgrid
  character*11 datetime
  real*8 tsec
  logical hotabetter
  integer ndxkm(0:23)
  character*4 dxgrid(0:23)
  common/acom2/ ndxkm,dxgrid
  include 'acom1.f90'

  mygrid=grid//'mm'
  hisgrid=grid2//'mm'
  call azdist(mygrid,hisgrid,0.d0,az,ndmiles,ndkm,el,hota,hotb,hotabetter)
  read(datetime(8:9),*,err=10) ihr
  go to 20
10 ihr=0
20 continue
  next=mod(ihr+1,24)
  ndxkm(next)=0
  dxgrid(next)='    '
  if(ndkm.gt.ndxkm(ihr)) then
     ndxkm(ihr)=ndkm
     dxgrid(ihr)=grid2
  endif
!  write(*,3001) ihr,mygrid(1:4),dxgrid(ihr),ndxkm(ihr)
!3001 format(i2,2x,a4,2x,a4,i7)

  return
end subroutine bestdx

