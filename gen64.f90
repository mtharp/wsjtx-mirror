subroutine gen64(message,mode64,ntxdf,iwave,nwave,  &
     sendingsh,nbit,msgsent,nmsg)

! Generate a JT64 wavefile.

  parameter (NMAX=60*12000)     !Max length of wave file
  character*24 message          !Message to be generated
  character*24 msgsent          !Message as it will be received
  character cmode*5
  real*8 t,dt,phi,f,f0,dfgen,dphi,twopi,tsymbol
  integer*2 iwave(NMAX)         !Generated wave file
  integer iu0(3),iu(3)
  integer gsym(372)             !372 is needed for JT8 mode
  integer sent(87)
  integer sendingsh
  integer ic6(6)
  integer isync(87)
  data ic6/0,1,4,3,5,2/,idum/-1/,nsps/6480/
  data twopi/6.283185307d0/
  save

  cmode='JT64'                                   !### temp ### (JT64A)
  call srcenc(cmode,message,nbit,iu0)
! Message length will be nbit=2, 30, 48, or 78

     if(nbit.eq.2) then
        iu=iu0
        msgsent=message
        go to 10
     else
! Apply FEC and do the channel encoding
        call chenc(cmode,nbit,iu0,gsym)
! Decode channel symbols to recover source-encoded message bits
!        call chdec(cmode,nbit,gsym,iu)
     endif
! Remove source encoding, recover the human-readable message.
     call srcdec(cmode,nbit,iu0,msgsent)

! Set up the JT64 sync pattern
! Insert the 6x6 Costas array 4 times at low-frequency edge.
  isync=-1
  do n=1,4
     i0=0
     if(n.eq.2) i0=27
     if(n.eq.3) i0=54
     if(n.eq.4) i0=81
     do i=1,6
        isync(i0+i)=ic6(i)
     enddo
  enddo

  nsym=87
  k=0
  do i=1,nsym
     if(isync(i).lt.0) then
        k=k+1
        sent(i)=gsym(k)
     else
        sent(i)=isync(i)
     endif
  enddo

  tsymbol=nsps/12000.d0
  nspecial=0
  sendingsh=0
10 if(nbit.eq.2) then
     nspecial=ishft(iu(1),-30)
     tsymbol=16384.d0/12000.d0
     nsym=32
     sendingsh=1                         !Flag for shorthand message
! ### go to xxx
  endif

! Set up necessary constants
  dt=1.d0/12000.d0
  f0=1270.46 + ntxdf
  dfgen=mode64*12000.d0/nsps
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
           if(k.le.87) f=f0+(sent(k))*dfgen         !### Fix need for this ###
        endif
        dphi=twopi*dt*f
        j0=j
     endif
     phi=phi+dphi
     iwave(i)=32767.0*sin(phi)
  enddo

  i=ndata
  do j=1,6000                !Put another 0.5 sec of silence at end
     i=i+1
     iwave(i)=0
  enddo
  nwave=i
  msgsent=message
  do i=22,1,-1
     if(msgsent(i:i).ne.' ') goto 20
  enddo
20 nmsg=i

  return
end subroutine gen64
