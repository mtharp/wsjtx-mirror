subroutine spec2d64(dat,jz,nsym,flip,istart,f0,ftrack,nafc,mode64,s2)

! Computes the spectrum for each of 87 symbols.
! NB: At this point, istart, f0, and ftrack are supposedly known.
! The data have been downsampled by 1/2, to 6000 Hz.
! The JT64 signal has 64 frequency bins. We add 5 extra bins at 
! top and bottom for drift, making 74 bins in all.

  parameter (NMAX=3240)                !Max length of FFTs
  real dat(jz)                         !Raw data
  real s2(74,87)                       !Spectra of all symbols
  real s(74)
  real ref(74)
  real ps(74)
  real x(NMAX)
  real ftrack(87)
  real*8 pha,dpha,twopi
  complex cx(NMAX)
!  include 'prcom.h'
  equivalence (x,cx)
  data twopi/6.28318530718d0/
  save

! Peak up in frequency and time, and compute ftrack.
!  call ftpeak65(dat,jz,istart,f0,flip,pr,nafc,ftrack)

  nfft=2048/mode64                     !Size of FFTs
  dt=2.0/12000.0
  df=0.5*12000.0/nfft
  ps=0.
  k=istart-nfft

! NB: this could be done starting with array c3, in ftpeak65, instead
! of the dat() array.  Would save some time this way ...

  do j=1,nsym
     s=0.
     do m=1,mode64
        k=k+nfft
        if(k.ge.1 .and. k.le.(jz-nfft)) then
! Mix tone 0 down to f=5*df (==> bin 6 of array cx, after FFT)
           dpha=twopi*dt*(f0 + ftrack(j) - 5.0*df)
           pha=0.0
           do i=1,nfft         
              pha=pha+dpha
              cx(i)=dat(k-1+i)*cmplx(cos(pha),-sin(pha))
           enddo

           call four2a(cx,nfft,1,-1,1)
           do i=1,74
              s(i)=s(i) + real(cx(i))**2 + aimag(cx(i))**2
           enddo

        else
           call zero(s,74)
        endif
     enddo
     call move(s,s2(1,j),74)
     call add(ps,s,ps,74)
  enddo

! Flatten the spectra by dividing through by the average of the 
! "sync on" spectra, with the sync tone explicitly deleted.
  nref=nsym/2
  do i=1,74
! First we sum all the sync-on spectra:
!### FIX THIS ###
     ref(i)=0.
     do j=1,nsym
        ref(i)=ref(i)+s2(i,j)
     enddo
     ref(i)=ref(i)/nref                 !Normalize
  enddo
! Remove the sync tone itself:
  base=0.25*(ref(1)+ref(2)+ref(10)+ref(11))
  do i=3,9
     ref(i)=base
  enddo

! Now flatten the spectra for all the data symbols:
  do i=1,74
     fac=1.0/ref(i)
     do j=1,nsym
        s2(i,j)=fac*s2(i,j)
        if(s2(i,j).eq.0.0) s2(i,j)=1.0   !### To fix problem in mfskprob
     enddo
  enddo

  return
end subroutine spec2d64
