subroutine afc2(c4)

  complex c4(45000)
  complex c5(45000)
  complex c6(45000)
  complex c(0:4095)
  complex*16 w,ws
  real fpk(162),spk(162)
  real f2(162),s2(162)
  real ww(-5:5)
  real*8 dt,f,dphi,twopi
  integer npr3(162)
  data npr3/                                   &
      1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0, &
      0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1, &
      0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1, &
      1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1, &
      0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0, &
      0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1, &
      0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1, &
      0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0, &
      0,0/

  dt=1.0/375
  nsps=256
  nsym=162
  twopi=8.d0*atan(1.d0)
  dftone=12000.d0/8192.d0                     !1.46484375 Hz

! At this point we have established pretty good time and frequency 
! synchronization.  Now remove the sync modulation.
  k=0
  w=1.0
  do j=1,nsym
!     f=dftone*(npr3(j)+2*symbol(j)-1.5)
     f=dftone*(npr3(j)-1.5)
     dphi=twopi*dt*f
     ws=dcmplx(cos(dphi),-sin(dphi))
     do i=1,nsps
        w=w*ws
        k=k+1
        c5(k)=w*c4(k)
     enddo
  enddo
  kz=k
! Now c5 has only the data modulation, with 2-FSK frequency steps of
! 2*dftone = 2.9296875 Hz.

! Do coherent FFTs over several symbols.  Find peak freq and subtract 
! 2*dftone if it was the upper one of two.  Save fpk and smax centered 
! on each symbol.  (May want to play with nd and nfft.)

  nd=3
  ndat=nd*nsps
  nfft=1024
  nh=nfft/2
  df=375.0/nfft
  ia=2*dftone/df
  noff=nint(0.5*nd*nsps)
  c6(1:noff)=0.
  c6(noff+1:noff+kz)=c5(1:kz)
  k=1-nsps

  do j=1,nsym
     k=k+nsps
     c(0:ndat-1)=c6(k:k+ndat)
     c(ndat:nfft-1)=0.
     call four2a(c,nfft,1,-1,1)
     smax=0.
     do i=-ia,ia
        k1=i
        if(k1.lt.0) k1=k1+nfft
        s=real(c(k1))**2 + aimag(c(k1))**2 
        if(s.gt.smax) then
           ipk=i
           if(ipk.gt.ia/2) ipk=ipk-ia
           if(ipk.lt.-ia/2) ipk=ipk+ia
           smax=s
        endif
     enddo
     fpk(j)=ipk*df
     spk(j)=smax
  enddo

  ww(0)=1.0
  do i=1,5
     x=(i/3.0)**2
     ww(i)=exp(-x)
     ww(-i)=exp(-x)
  enddo

  do j=1,nsym
     sum=0.
     sumw=0.
     do i=-5,5
        if(j+i.ge.1 .and. j+i.le.162) then
           wgt=ww(i)*spk(j+i)
           sumw=sumw + wgt
           sum=sum + wgt*fpk(j+i)
        endif
     enddo
     f2(j)=sum/sumw
  enddo

  do j=1,nsym
     write(54,3201) j,fpk(j),0.000015*spk(j),f2(j)
3201 format(i3,3f10.3)
  enddo
  write(54,3201) 163,-4.0,0.0,0.0
  write(54,3201)   0,-4.0,0.0,0.0

  k=0
  w=1.0
  do j=1,nsym
     dphi=twopi*dt*f2(j)
     ws=dcmplx(cos(dphi),-sin(dphi))
     do i=1,nsps
        w=w*ws
        k=k+1
        c4(k)=w*c4(k)
     enddo
  enddo

  return
end subroutine afc2
