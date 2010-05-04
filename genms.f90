subroutine genms(message,txsnrdb,iwave,nwave,nbit,msgsent)

! Generate a JTMS wavefile.

  parameter (NMAX=60*12000)     !Max length of wave file
  character*24 message          !Message to be generated
  character*24 msgsent          !Message as it will be received
  character cmode*5
  real*8 t,dt,phi,f,f0,dfgen,dphi,twopi,txsnrdb
  integer*2 iwave(NMAX)         !Generated wave file
  integer iu(3)
  integer gsym(372)             !(372 is needed for JT8 mode)
  integer sent(212)
  integer is32(32)
  data is32/0,0,0,1,1,0,1,0,1,1,0,0,1,1,1,1,1,1,1,1,      &
            1,1,0,0,0,0,0,1,1,1,0,1/ 
  data twopi/6.283185307d0/
  save

  cmode='JTMS'                                   !### temp ? ###
  call srcenc(cmode,message,nbit,iu)

! Apply FEC and do the channel encoding
  call chenc(cmode,nbit,iu,gsym)

! Remove source encoding, recover the human-readable message.
  call srcdec(cmode,nbit,iu,msgsent)

  if(nbit.eq.2) then
     f1=882.d0 + 441*iand(3,ishft(iu(1),-30))
     dphi=twopi*f1*dt
     do i=1,360000
        phi=phi+dphi
        iwave(i)=nint(32767.0*sin(phi))
     enddo
     k=360000-1
     go to 900
  endif

! Append the encoded data after the 32-bit sync vector
  ndata=2*(nbit+12)
  nsync=32
  nsym=ndata+nsync
  sent(1:nsync)=is32
  sent(nsync+1:nsym)=gsym(1:ndata)
 
! Set up necessary constants
  nsps=8
  dt=1.d0/12000.d0
  f0=1500.d0
  dfgen=750.d0
  t=0.d0
  k=0
  phi=0.d0
  nrpt=30.0*12000.0/(nsym*nsps)
  do irpt=1,nrpt
     do j=1,nsym
        if(sent(j).eq.1) then
           f=f0 + 0.5d0*dfgen
        else
           f=f0 - 0.5d0*dfgen
        endif
        dphi=twopi*f*dt
        do i=1,nsps
           k=k+1
           phi=phi+dphi
           iwave(k)=nint(32767.0*sin(phi))
        enddo
     enddo
  enddo

900 iwave(k+1:)=0
  nwave=k

  if(txsnrdb.lt.40.d0) then
! ###  Make some pings (for tests only) ###
     do i=1,nwave
        iping=i/(3*12000)
        if(iping.ne.iping0) then
           ip=mod(iping,3)
           w=0.05*(ip+1)
           ig=(iping-1)/3
           amp=sqrt((3.0-ig)/3.0)
           t0=dt*(iping+0.5)*(3*12000)
           iping0=iping
        endif
        t=(i*dt-t0)/w
        if(t.lt.0.d0 .and. t.lt.10.d0) then
           fac=0.
        else
           fac=2.718*t*dexp(-t)
        endif
        iwave(i)=nint(fac*amp*iwave(i))
     enddo
  endif

  return
end subroutine genms
