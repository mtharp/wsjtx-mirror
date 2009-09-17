subroutine genms(message,iwave,nwave,msgsent)

! Generate a JTMS wavefile.

  parameter (NMAX=30*12000)     !Max length of wave file
  character*24 message          !Message to be generated
  character*24 msgsent          !Message as it will be received
  character*5 cmode
  real*8 t,dt,phi,f,f0,dfgen,dphi,twopi,tsymbol
  integer*2 iwave(NMAX)         !Generated wave file
  integer iu0(3),iu(3)          !Source-encoded message
  integer gsym(372)             !372 is needed for JT8 mode
  integer sent(193)
  integer ibark(13)
  data ibark/1,1,1,1,1,0,0,1,1,0,1,0,1/
! MPS28 =1000111100010001000100101101
  data twopi/6.283185307d0/
  save

  cmode='JTMS'                                   !### temp? ###
  nsync=13
  call srcenc(cmode,message,nbit,iu0)
! Message length will be nbit=2, 30, 48, or 78

  if(nbit.eq.2) then
     iu=iu0
  else
! Apply FEC and do the channel encoding
     call chenc(cmode,nbit,iu0,gsym)
     ndata=2*(nbit+12)
     nsym=nsync+ndata
! Insert the Barker sequence
     sent(:13)=ibark
     sent(14:13+ndata)=gsym(1:ndata)

! Decode channel symbols to recover source-encoded message bits
     call chdec(cmode,nbit,gsym,iu)
  endif
! Remove source encoding, recover the human-readable message.
  call srcdec(cmode,nbit,iu,msgsent)

! Set up necessary constants
  nsps=8
  dt=1.d0/12000.d0
  tsymbol=nsps*dt
  f0=1500.d0 
  dfgen=750.d0
  t=0.d0
  phi=0.d0
  k=0
  j0=0
  nwave=30*12000
  do i=1,nwave
     j=mod((i-1)/nsps,nsym)+1                !Symbol number, 1 to nsym
     if(j.ne.j0) then
        if(sent(j).eq.1) then
           f=f0 + 0.5d0*dfgen
        else
           f=f0 - 0.5d0*dfgen
        endif
        dphi=twopi*f*dt
        j0=j
     endif
     phi=phi+dphi
     iwave(i)=32767.d0*sin(phi)
  enddo

!  tmsg=nsym*nsps*dt
!  write(*,3000) iu0,nbit,nsync,ndata,nsym,tmsg,msgsent
!3000 format(3z9,2i3,2i4,f6.3,1x,a24)

! Make some pings
  do i=1,nwave
     iping=i/(3*12000)
     w=0.05*(iping+1)
     t0=dt*(iping+0.5)*(3*12000)
     t=(i*dt-t0)/w
     if(t.lt.0) then
        fac=0.
     else
        fac=2.718*t*exp(-t)
     endif
     iwave(i)=fac*iwave(i)
  enddo

  return
end subroutine genms
