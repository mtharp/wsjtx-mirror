subroutine msksymbol(dat,jz,dfx,lagbest,isbest)

  parameter (MAXSAM=32768)
  real dat(jz)
  complex cy(MAXSAM)                 !Received data, complex
  complex c(MAXSAM)                  !Work array
  complex z0,z1
  real x0(8)                         !Waveform for bit=0
  real x1(8)                         !Waveform for bit=1
  integer symbol(MAXSAM)             !Soft-decision symbols
  integer id(MAXSAM)                 !Sync followed by data in one-bit format
  integer id2(MAXSAM)                !Hard-decision demodulated bits
  character*3 cerr
  logical first
  data first/.true./
  data isync32/Z'1acffc1d'/          !32-bit sync
  save

  if(first) then
! Generate the basic waveforms for symbols "0" and "1" 
     nbit=30
     if(isbest.eq.2) nbit=48
     if(isbest.eq.3) nbit=78
     nsync=32
     ndata=(nbit+12)*2                  !Number of data symbols (K=13, r=1/2)
     nsym=ndata+nsync                   !Total number of symbols
     nsps=8
     dt=1.0/12000.0
     twopi=8.0*atan(1.0)
     phi0=0.
     phi1=0.
     dphi0=twopi*dt*750.0
     dphi1=twopi*dt*1500.0
     do i=1,nsps
        phi0=phi0+dphi0
        phi1=phi1+dphi1
        x0(i)=sin(phi0)
        x1(i)=sin(phi1)
     enddo
  endif

! Move dat(i) to cy(i) and shift frequency to f=0
  phi=0.
  dphi=twopi*dt*dfx
  fac=0.001
  do i=1,jz
     phi=phi+dphi
     cy(i)=fac*dat(i)     !*cmplx(cos(phi),-sin(phi))
  enddo

! Unpack the sync bits into the first nsync positions of id()
  id=0
  n=isync32
  do j=1,nsync
     if(n.lt.0) id(j)=1
     n=ishft(n,1)
  enddo
  write(*,1001) (id(i),i=1,32)
1001 format(8(4i1,1x))


! Shift the received signal in frequency by small increments around
! fbest, looking for maximum sq.
! NB: might be better to use the "fchisq" method?  (However, beware
! the oscillatory nature of si and sq vs nn.)
  dsqpk=0.
  nn=0
  do idf=-12,12                            !Try freq offsets over +/- 12 Hz
     fshift=nint(fbest)+idf
     do iph=-4,4                           !Try phases over +/- 90 deg
        phi=(22.5*iph)/57.2957795
        dphi=twopi*dt*fshift
        do i=1,nsps*nsym
           phi=phi+dphi
           c(i)=cy(i)*cmplx(cos(phi),-sin(phi))
        enddo

! Decode the waveform using matched-filter, integrate-and-dump correlators.
        k=0
        is=1
        nerr=0
        si=0.
        sq=0.
        do j=1,nsym
           z0=0.
           z1=0.
           do i=1,nsps
              k=k+1
              z0=z0 + x0(i)*c(k)
              z1=z1 + x1(i)*c(k)
           enddo
           s0=real(z0)
           s1=real(z1)
           s0=2*s0/nsps
           s1=2*s1/nsps
           ssym=is*(s1-s0)
           si=si + ssym*ssym

           s0=aimag(z0)
           s1=aimag(z1)
           s0=2*s0/nsps
           s1=2*s1/nsps
           ssym=is*(s1-s0)
           sq=sq + ssym*ssym

           ibit=0
           if(ssym.gt.0.0) ibit=1
           if(ibit.ne.id(j)) nerr=nerr+1
           if(ssym.gt.0.0) is=-is
        enddo
        dsq=sq-si
!        dsq=sq/si
        if(dsq.gt.dsqpk) then
           dsqpk=dsq
           sqpk=sq
           fpk=fshift
           ierr=nerr
           iphpk=iph
        endif
        nn=nn+1
!        write(37,3001) nn,fshift,22.5*iph,si,sq,dsq,nerr
!3001    format(i5,2f8.1,3f10.1,i5)
     enddo
  enddo

!Do it once more, using best params
  fshift=fpk
  phi=-(22.5*iphpk)/57.2957795
  dphi=twopi*dt*fshift
  do i=1,nsps*nsym
     phi=phi+dphi
     c(i)=cy(i)*cmplx(cos(phi),-sin(phi))
  enddo

! Decode the waveform using matched-filter, integrate-and-dump correlators.
  k=0
  is=1
  nerr=0
  si=0.
  sq=0.
  do j=1,nsym
     z0=0.
     z1=0.
     do i=1,nsps
        k=k+1
        z0=z0 + x0(i)*c(k)
        z1=z1 + x1(i)*c(k)
     enddo
     s0=real(z0)
     s1=real(z1)
     s0=2*s0/nsps
     s1=2*s1/nsps
     ssym=is*(s1-s0)
     si=si + ssym*ssym
     
     s0=aimag(z0)
     s1=aimag(z1)
     s0=2*s0/nsps
     s1=2*s1/nsps
     ssym=is*(s1-s0)
     sq=sq + ssym*ssym
     symbol(j)=nint(10.0*ssym)

     ibit=0
     if(ssym.gt.0.0) ibit=1
     if(j.le.32 .and. ibit.ne.id(j)) nerr=nerr+1
     if(ssym.gt.0.0) is=-is
     id2(j)=ibit
  enddo

  do j=1,nsym
     idiff=id2(j)-id(j)
     write(32,1040) j,id(j),id2(j),idiff,symbol(j)
     if(id2(j).ne.id(j)) write(33,1040) j,id(j),id2(j),idiff,symbol(j)
1040 format(4i5,i10)
  enddo

  cerr='   '
  write(*,1022) fpk,22.5*iphpk,sqpk
1022 format('Refined   DF:',f8.1,'   Dpha:',f8.1,16x,'sqpk:',f8.2)
  if(nerr.gt.0) cerr='***'
  write(*,1024) nerr,cerr,100.0*float(ierr)/nsym
1024 format('Bit errors:',i4,1x,a3,f8.1,'%')

  call flushqqq(32)
  call flushqqq(33)
  call flushqqq(37)

  return
end subroutine msksymbol
