subroutine tx

!  Make one transmission in the MEPT_JT mode.

#ifdef CVF
  use dfport
#else
  integer time
#endif

  parameter (NMAX2=120*12000)
  character message*22,call1*12,cdbm*3
  integer*2 jwave(NMAX2)
  integer soundout,ptt
  include 'acom1.f90'

  ndevout=0
  call1=callsign
  if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
  write(cdbm,'(i3)'),ndbm
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  do i=6,1,-1
     if(call1(i:i).ne.' ') go to 10
  enddo

10 iz=i
  message=call1(1:iz)//' '//grid//' '//cdbm
  do i=22,1,-1
     if(message(i:i).ne.' ') go to 20
  enddo

20 iz=i
  ftx=f0 + 0.001500d0
!  open(13,file='ALL_MEPT.TXT',status='unknown',access='append')
!  write(13,1010) ih,im,ftx,message(1:iz)
!1010 format(2i2.2,14x,f11.6,'  Transmitting "',a,'"')
!  close(13)

  call genmept(call1,grid,ndbm,ntxdf,99.0,jwave)
  if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
  npts=114*12000
  ierr=soundout(jwave,npts)
  if(nport.gt.0) ierr=ptt(nport,junk,0,iptt)
  ntxdone=1

  return
end subroutine tx
