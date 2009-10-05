subroutine geniscat(message,iwave,nwave,sendingsh,nbit,msgsent)

! Generate a wavefile for the ISCAT mode.

  parameter (NMAX=30*12000)     !Max length of wave file
  character*24 message          !Message to be generated
  character*24 msgsent          !Message as it will be received
  character cmode*5
  real*8 t,dt,phi,f,f0,dfgen,dphi,twopi,tsymbol
  integer*2 iwave(NMAX)         !Generated wave file
  integer iu0(3),iu(3)
  integer gsym(372)             !372 is needed for JT8 mode
  integer sent(71)
  integer sendingsh
  integer ic10(10)
  data ic10/0,1,3,7,4,9,8,6,2,5/     !10x10 Costas array
  data idum/-1/,nsps/512/
  data twopi/6.283185307d0/
  save

  cmode='ISCAT'                                   !### temp ? ###
  call srcenc(cmode,message,nbit,iu0)
! Message length will be nbit=2, 30, 48, or 78

  if(nbit.eq.2) then
     iu=iu0
     msgsent=message
     go to 10
  else
! Apply FEC and do the channel encoding
     call chenc(cmode,nbit,iu0,gsym)
  endif
! Remove source encoding, recover the human-readable message.
  call srcdec(cmode,nbit,iu0,msgsent)

! Insert an 8x8 Costas array at the low-frequency edge.  Use different
! Costas arrays for nbit=30, 48, and 78.
  do i=1,10
     if(nbit.eq.30) sent(i)=ic10(i)
     if(nbit.eq.48) sent(i)=ic10(11-i)
     if(nbit.eq.78) sent(i)=9-ic10(i)
  enddo

! Append the encoded data after the sync pattern
  nsym=63+10
  sent(11:nsym)=gsym(1:63)
  tsymbol=nsps/12000.d0
  nspecial=0
  sendingsh=0

10 if(nbit.eq.2) then
     nspecial=ishft(iu(1),-30)
     sendingsh=1                         !Flag for shorthand message
! ### go to xxx
  endif

! Set up necessary constants
  dt=1.d0/12000.d0
  f0=700.d0
  dfgen=12000.d0/nsps
  t=0.d0
  phi=0.d0
  k=0
  j0=0
  ndata=(nsym*12000.d0*tsymbol)/2
  ndata=2*ndata
  do i=1,ndata
     t=t+dt
     j=int(t/tsymbol) + 1                    !Symbol number, 1-nsym
     if(j.ne.j0) then
        f=f0
        if(nspecial.ne.0 .and. mod(j,2).eq.0) f=f0+21*nspecial*dfgen
        if(nspecial.eq.0) then
           k=k+1
           if(k.le.71) f=f0+(sent(k))*dfgen         !### Fix need for this ? ###
        endif
        dphi=twopi*dt*f
        j0=j
     endif
     phi=phi+dphi
     iwave(i)=32767.0*sin(phi)
  enddo

  do nrpt=2,9
     i0=(nrpt-1)*ndata
     do i=1,ndata
        iwave(i0+i)=iwave(i)
     enddo
  enddo
  nwave=9*ndata

  return
end subroutine geniscat
