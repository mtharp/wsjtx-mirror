subroutine setupms(f0,f1,csync,c0,c1)

  complex csync(256)                   !Complex sync waveform
  complex c0(8)                        !Complex waveform for bit=0
  complex c1(8)                        !Complex waveform for bit=1
  real*8 twopi,fs,dt,f0,f1
  integer is32(32)                     !Sync vector in one-bit format
  data is32/0,0,0,1,1,0,1,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,0,1/ 

  nsps=8
  nsync=32
  twopi=8*atan(1.d0)
  dt=1.d0/12000.d0                     !Sample interval

! Generate sync waveform
  k=0
  phi=0.
  dphi0=twopi*dt*f0
  dphi1=twopi*dt*f1
  do j=1,nsync
     if(is32(j).eq.0) then
        dphi=dphi0
     else
        dphi=dphi1
     endif
     do i=1,nsps
        k=k+1
        phi=phi+dphi
        csync(k)=cmplx(cos(phi),sin(phi))
     enddo
  enddo

  phi0=0.d0
  phi1=0.d0
  do i=1,8                        !Generate signal templates for 0 and 1
     phi0=phi0+dphi0
     phi1=phi1+dphi1
     c0(i)=cmplx(cos(phi0),sin(phi0))
     c1(i)=cmplx(cos(phi1),sin(phi1))
  enddo

end subroutine setupms
