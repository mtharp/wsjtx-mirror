subroutine echogen(iwave,nwave)

! Generate a 2-second radar pulse based on an N=27 Costas array.

  parameter (NMAX=24000)          !Length of wave file
  integer*2 iwave(NMAX)           !Wave file to be generated
  integer nwave                   !Length of wave file
  integer icos27(27)
  real*8 f0,f1,pha,dpha,dt,twopi,tsym,df
  data twopi/6.28318530718d0/,nsamrate/12000/
  data icos27/1,3,7,15,2,5,11,23,18,8,17,6,13,27,26,24,20,12,      &
       25,22,16,4,9,19,10,21,14/
  save

  nwave=2*nsamrate
  dt=1.d0/nsamrate
  f0=1270.46d0
  pha=0.d0
  tsym=2.d0/27.d0
  df=1.d0/tsym
  j0=999
      
  do i=1,nwave
     t=i*dt                              !Time from start of wave file
     j=t/tsym
     if(j.ne.j0) then
        f1=f0 + df*icos27(j+1)
        dpha=twopi*dt*f1
        j0=j
     endif
     pha=pha+dpha
     iwave(i)=nint(32767.0*sin(pha))
  enddo

  return
end subroutine echogen
