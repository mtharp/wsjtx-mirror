! subtract a jt65 signal
!
! measured signal: dd(t)=A(t)cos(2*pi*fo*t+theta(t))
! reference signal:   cref(t)=exp( j*phi(t) )
! complex amp: cfilt(t)=LPF[dd(t)*cref(t)]
! Form: dd(t)-Re{cref*cfilt}
!
subroutine subtract65(dd,npts,f0,dt,decoded)
  use packjt
  character*22 decoded
  integer correct(63)

  parameter (NMAX=60*12000) !Samples per 60 s
  parameter (NFILT=600)
  real*4  dd(NMAX), window(-NFILT/2:NFILT/2)
  complex cref(NMAX),camp(NMAX),cfilt(NMAX),csum
  integer*2 id2(NMAX)
  integer nprc(126)
  real*8 dphi
  data nprc/                                   &
    1,0,0,1,1,0,0,0,1,1,1,1,1,1,0,1,0,1,0,0, &
    0,1,0,1,1,0,0,1,0,0,0,1,1,1,0,0,1,1,1,1, &
    0,1,1,0,1,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1, &
    0,0,1,1,0,1,0,1,0,1,0,0,1,0,0,0,0,0,0,1, &
    1,0,0,0,0,0,0,0,1,1,0,1,0,0,1,0,1,1,0,1, &
    0,1,0,1,0,0,1,1,0,0,1,0,0,1,0,0,0,0,1,1, &
    1,1,1,1,1,1/
  common/chansyms65/correct
  pi=4.0*atan(1.0)

! Symbol duration is 4096/11025 s.
! Sample rate is 12000/s, so 12000*(4096/11025)=4458.23 samples/symbol.
! For now, call it 4458 samples/symbol. Over the message duration, we'll be off
! by about (4458.23-4458)*126=28.98 samples; 29 samples, or 0.7% of 1 symbol.
! Could eliminate accumulated error by injecting one extra sample every
! 5 or so symbols... Maybe try this later.

  nstart=(dt+1)*12000;  !??? Why do I have to add 1 second here?
  nsym=126
  ns=4458 
  nref=nsym*ns
  nend=nstart+nref-1
  phi=0.0
  iref=1
  ind=1
  isym=1
!  f0=1270
  do k=1,nsym
    if( nprc(k) .eq. 1 ) then
        omega=2*pi*f0
    else
        omega=2*pi*(f0+2.6917*(correct(isym)+2))
        isym=isym+1
    endif
    dphi=omega/12000.0
    do i=1,ns
        cref(ind)=cexp(cmplx(0.0,phi))
        phi=modulo(phi+dphi,2*pi)
        id=nstart-1+ind
        camp(ind)=dd(id)*conjg(cref(ind))
        ind=ind+1
     enddo
  enddo

  ! create and normalize the filter
  sum=0.0
  do j=-NFILT/2,NFILT/2
    window(j)=cos(pi*j/NFILT)**2
    sum=sum+window(j)
  enddo
  do j=-NFILT/2,NFILT/2
    window(j)=window(j)/sum
  enddo

  ! apply smoothing filter - ignore end effects for now
  do i=1, nref
    csum=cmplx(0.0,0.0)
    do j=-NFILT/2,NFILT/2
      k=i+j
      if( k.gt.1 .and. k.le.nref) then
        csum=csum+window(j)*camp(k)
      endif
    enddo
    cfilt(i)=csum
  enddo

  ! subtract the reconstructed signal
  do i=1,nref
    dd(nstart+i-1)=dd(nstart+i-1)-2*REAL(cfilt(i)*cref(i))
  enddo
!  id2(1:npts)=dd(1:npts)
!  write(56) id2(1:npts)

  return
end subroutine subtract65 
