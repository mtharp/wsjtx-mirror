subroutine genms(message,txsnrdb,iwave,nwave,msgsent)

! Generate a JT8 wavefile.

  parameter (NMAX=60*12000)     !Max length of wave file
  character*24 message          !Message to be generated
  character*24 msgsent          !Message as it will be received
  character cmode*5
  real*8 t,dt,phi,f,f0,dfgen,dphi,twopi,tsymbol,txsnrdb
  integer*2 iwave(NMAX)         !Generated wave file
  integer iu0(3),iu(3)
  integer gsym(372)             !372 is needed for JT8 mode
  integer sent(193)
  data twopi/6.283185307d0/
  save

  cmode='JTMS'                                   !### temp ? ###
  call srcenc(cmode,message,nbit,iu0)

! Apply FEC and do the channel encoding
  call chenc(cmode,nbit,iu0,gsym)
! Decode channel symbols to recover source-encoded message bits

!        call chdec(cmode,nbit,gsym,iu)
! Remove source encoding, recover the human-readable message.
  call srcdec(cmode,nbit,iu0,msgsent)

  ndata=2*(nbit+12)
  nsync=0
  nsym=ndata+nsync
  sent(1:ndata)=gsym(1:ndata)
  nsps=8

! Set up necessary constants
  tsymbol=nsps/12000.d0
  dt=1.d0/12000.d0
  f0=1500.d0
  dfgen=750.d0
  t=0.d0
  k=0
  phi=0.d0
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
        iwave(k)=32767.0*sin(phi)
     enddo
  enddo

  nrpt=29.5*12000.0/k
  do irpt=2,nrpt
     do i=1,nsps*nsym
        k=k+1
        iwave(k)=iwave(i)
     enddo
  enddo

  iwave(k+1:)=0
  nwave=k

  if(txsnrdb.lt.40.d0) then
! ###  Make some pings ###
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
        iwave(i)=fac*amp*iwave(i)
     enddo
  endif

  return
end subroutine genms
