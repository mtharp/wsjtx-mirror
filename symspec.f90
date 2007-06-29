subroutine symspec(id,kbuf,kk,kkdone,rxnoise,newspec,newdat,ndecoding)

!  Compute spectra at four polarizations, using half-symbol steps.

  parameter (NSMAX=60*96000)
  integer*2 id(4,NSMAX)
  complex z
  real*8 ts,hsym
  include 'spcom.f90'
  complex cx(NFFT),cy(NFFT)               !  pad to 32k with zeros

  fac=0.0002 * 10.0**(0.05*(-rxnoise))
  hsym=2048.d0*96000.d0/11025.d0          !Samples per half symbol
  npts=hsym                               !Integral samples per half symbol
  ntot=322                               !Half symbols per transmission
!  ntot=279                                !Half symbols in 51.8 sec

  if(kkdone.eq.0) then
     do ip=1,4
        do i=1,NFFT
           szavg(ip,i)=0.
        enddo
     enddo
     ts=1.d0 - hsym
     n=0
  endif

  do nn=1,ntot
     i0=ts+hsym                           !Starting sample pointer
     if((i0+npts-1).gt.kk) go to 999      !See if we have enough points
     i1=ts+2*hsym                         !Next starting sample pointer
     ts=ts+hsym                         !OK, update the exact sample pointer
     do i=1,npts                        !Copy data to FFT arrays
        xr=fac*id(1,i0+i)
        xi=fac*id(2,i0+i)
        cx(i)=cmplx(xr,xi)
        yr=fac*id(3,i0+i)
        yi=fac*id(4,i0+i)
        cy(i)=cmplx(yr,yi)
     enddo

     do i=npts+1,NFFT                   !Pad to 32k with zeros
        cx(i)=0.
        cy(i)=0.
     enddo

     call four2a(cx,NFFT,1,1,1)         !Do the FFTs
     call four2a(cy,NFFT,1,1,1)
            
     n=n+1
     do i=1,NFFT                        !Save and accumulate power spectra
        sx=real(cx(i))**2 + aimag(cx(i))**2
        ssz(1,n,i)=sx                    ! Pol = 0
        szavg(1,i)=szavg(1,i) + sx
        
        z=cx(i) + cy(i)
        s45=0.5*(real(z)**2 + aimag(z)**2)
        ssz(2,n,i)=s45                   ! Pol = 45
        szavg(2,i)=szavg(2,i) + s45

        sy=real(cy(i))**2 + aimag(cy(i))**2
        ssz(3,n,i)=sy                    ! Pol = 90
        szavg(3,i)=szavg(3,i) + sy

        z=cx(i) - cy(i)
        s135=0.5*(real(z)**2 + aimag(z)**2)
        ssz(4,n,i)=s135                  ! Pol = 135
        szavg(4,i)=szavg(4,i) + s135

        z=cx(i)*conjg(cy(i))

! Leif's formula:
!            ss5(n,i)=0.5*(sx+sy) + (real(z)**2 + aimag(z)**2 -
!     +          sx*sy)/(sx+sy)

! Leif's suggestion:
!            ss5(n,i)=max(sx,s45,sy,s135)

! Linearly polarized component, from the Stokes parameters:
        q=sx - sy
        u=2.0*real(z)
!            v=2.0*aimag(z)
        ssz5(n,i)=0.707*sqrt(q*q + u*u)

     enddo
!         if(n.eq.ntot) then
     if(n.ge.279) then
        call move(ssz5,ss5,322*NFFT)
        newspec=1
        call move(ssz,ss,4*322*NFFT)
        call move(szavg,savg,4*NFFT)
        newdat=1
        ndecoding=1
        go to 999
     endif
     kkdone=i1-1
     nhsym=n
     call sleep_msec(0)
     write(81,3001) n,kbuf,kk,kkdone
3001 format(4i10)
  enddo

999 kkdone=i1-1
  return
end subroutine symspec
