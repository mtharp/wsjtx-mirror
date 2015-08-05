subroutine gen441(itone,ndits,cfrag,isubmode)
  integer itone(84)
  complex cfrag(2100)
  include 'FSKParameters.f90'
  
 nspd = NSPD441
 LTone = LTONE441
 if (isubmode.eq.1) then
    nspd = NSPD315
    LTone = LTONE315
 endif

! Generate iwave
  twopi=8*atan(1.0)
  dt=1.0/11025.0
  k=0
  df=11025.0/nspd
  pha=0.
  do m=1,ndits
     freq=(LTone-1+itone(m))*df
     dpha=twopi*freq*dt
     do i=1,nspd
        k=k+1
        pha=pha+dpha
        cfrag(k)=cmplx(sin(pha),-cos(pha))
     enddo
  enddo

  return
end subroutine gen441
