subroutine genjt8(message,iwave,nwave,nbit,msgsent)

! Generate a JT8 wavefile.

  parameter (NMAX=60*12000)     !Max length of wave file
  character*24 message          !Message to be generated
  character*24 msgsent          !Message as it will be received
  character cmode*5
  real*8 t,dt,phi,f,f0,dfgen,dphi,twopi,tsymbol
  integer*2 iwave(NMAX)         !Generated wave file
  integer iu0(3),iu(3)
  integer gsym(372)             !372 is needed for JT8 mode
  integer gsym2(372)
  integer sent(140)
  integer ic8(8)
  integer igray1(0:7)
  data ic8/3,6,2,4,5,0,7,1/
!  data igray0/0,1,3,2,7,6,4,5/    !Use this to remove the gray code
  data igray1/0,1,3,2,6,7,5,4/
  data nsps/4200/
  data twopi/6.283185307d0/
  save

  cmode='JT8'                                   !### temp ? ###
  call srcenc(cmode,message,nbit,iu0)
! In JT8 mode, message length is always nbit=78
  if(nbit.ne.78) then
     print*,'genjt8, nbit=',nbit
     stop
  endif

! Apply FEC and do the channel encoding
  call chenc(cmode,nbit,iu0,gsym)

! Remove source encoding, recover the human-readable message.
  call srcdec(cmode,nbit,iu0,msgsent)

! Insert 8x8 Costas array at beginning and end of array sent().
  do i=1,8
     sent(i)=ic8(i)
     sent(i+132)=ic8(i)
  enddo

! Interleave the data using a 12x31 logical block
  do i1=0,30
     do i2=0,11
        i=31*i2+i1
        j=12*i1+i2
        gsym2(i+1)=gsym(j+1)        !Exchange i and j to remove interleaving
     enddo
  enddo

! Apply gray code and insert 3-bit data symbols
  nsym=140
  k=0
  do i=1,124
     n=4*gsym2(3*i-2) + 2*gsym2(3*i-1) + gsym2(3*i)
     sent(i+8)=igray1(n)            !Use igray0() to remove gray code
  enddo

! Set up necessary constants
  tsymbol=nsps/12000.d0
  dt=1.d0/12000.d0
  f0=1270.46d0
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
        k=k+1
        if(k.le.140) f=f0+(sent(k))*dfgen         !### Fix need for this ###
        dphi=twopi*dt*f
        j0=j
     endif
     phi=phi+dphi
     iwave(i)=32767.0*sin(phi)
  enddo

  iwave(ndata+1:)=0
  nwave=ndata+6000                          !0.5 s buffer before CW ID

  return
end subroutine genjt8
