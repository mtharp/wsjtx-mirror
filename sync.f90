subroutine sync(y1,y2,y3,y4,npts,jpk,baud,bauderr,isubmode)

! Input data are in the y# arrays: detected sigs in four tone-channels,
! before decimation by NSPD.

  include 'FSKParameters.f90'

  real y1(npts)
  real y2(npts)
  real y3(npts)
  real y4(npts)
  real zf(NSPD315)
  real tmp1
  real tmp2
  complex csum
  integer nsum(NSPD315)
  real z(65538)                            !Ready for FSK110
  complex cz(0:32768)
  equivalence (z,cz)
  data twopi/6.283185307/
  
  nspd = NSPD441
  if (isubmode.eq.1) then
    nspd = NSPD315
  endif

  do i=1,nspd
     zf(i)=0.0
     nsum(i)=0
  enddo

  do i=1,npts
     a1=max(y1(i),y2(i),y3(i),y4(i))       !Find the largest one

     if(a1.eq.y1(i)) then                  !Now find 2nd largest
        a2=max(y2(i),y3(i),y4(i))
     else if(a1.eq.y2(i)) then
        a2=max(y1(i),y3(i),y4(i))
     else if(a1.eq.y3(i)) then
        a2=max(y1(i),y2(i),y4(i))
     else 
        a2=max(y1(i),y2(i),y3(i))
     endif

     z(i)=1.e-6*(a1-a2)                     !Subtract 2nd from 1st
     j=mod(i-1,nspd)+1
     zf(j)=zf(j)+z(i)
     nsum(j)=nsum(j)+1
  enddo

  n=log(float(npts))/log(2.0)
  nfft=2**(n+1)
  call zero(z(npts+1),nfft-npts)
  call xfft(z,nfft)

! Now find the apparent baud rate.
  df=11025.0/nfft
  zmax=0.
  ia=391.0/df                                !Was 341/df
  ib=491.0/df                                !Was 541/df
  do i=ia,ib
     z(i)=real(cz(i))**2 + aimag(cz(i))**2
     if(z(i).gt.zmax) then
        zmax=z(i)
        baud=df*i
     endif
  enddo

! Find phase of signal at 441 Hz.
  csum=0.
  do j=1,nspd
     pha=j*twopi/nspd
     csum=csum+zf(j)*cmplx(cos(pha),-sin(pha))
  enddo
  tmp1=aimag(csum)
  tmp2=real(csum)
  pha=-atan2(tmp1,tmp2)
  jpk=nint(nspd*pha/twopi)
  if(jpk.lt.1) jpk=jpk+nspd

!The following is nearly equivalent to the above.  I don't know which
!(if either) is better.
!     zfmax=-1.e30
!     do j=1,NSPD
!        if(zf(j).gt.zfmax) then
!           zfmax=zf(j)
!           jpk2=j
!        endif
!     enddo

  bauderr=(baud-11025.0/nspd)/df   !Baud rate error, in bins

  return
end subroutine sync
