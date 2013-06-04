subroutine downsam9(id2,npts8,nsps8,newdat,nspsd,fpk,c2,nz2)

!Downsample to nspsd samples per symbol, info centered at fpk

  parameter (NMAX=1024*1920)
  parameter (NTMAX=120)
  integer*2 id2(0:8*npts8-1)
  real*4 x1(0:NMAX-1)
  complex c1(0:NMAX/2)
  complex c2(0:4096-1)
  real s(1000)
  equivalence (c1,x1)
  save

!  nfft1=128*nsps8                          !Forward FFT length
!  nh1=nfft1/2
!  df1=1500.0/nfft1

  nfft1=1024*nsps8                          !Forward FFT length
  nh1=nfft1/2
  df1=12000.0/nfft1
  npts=8*npts8

  if(newdat.eq.1) then
!     write(69,*) npts,nsps8,nfft1,df1

     fac=1.e-6 * 6.963
     do i=0,npts-1,2
!        c1(i)=fac*conjg(c0(i))
!        c1(i+1)=-fac*conjg(c0(i+1))
        x1(i)=fac*id2(i)
        x1(i+1)=fac*id2(i+1)
     enddo
     c1(npts:)=0.                             !Zero the rest of c1
!     call four2a(c1,nfft1,1,-1,1)             !Forward FFT
     call four2a(x1,nfft1,1,-1,0)             !Forward FFT

     nadd=1.0/df1
!     j=250/df1
     j=1000.0/df1
     s=0.
     do i=1,1000
        do n=1,nadd
           j=j+1
           s(i)=s(i)+real(c1(j))**2 + aimag(c1(j))**2
        enddo
!        write(68,3001) i+1000,s(i),db(s(i)),nadd
!3001    format(i5,2f12.3,i8)
     enddo
     call pctile(s,1000,40,avenoise)
     newdat=0
  endif

!  ndown=nsps8/16                           !Downsample factor
  ndown=8*nsps8/16                           !Downsample factor
  nfft2=nfft1/ndown                        !Backward FFT length
  nh2=nfft2/2
   
!  fshift=fpk-1500.0
!  i0=nh1 + fshift/df1
  i0=fpk/df1

  fac=sqrt(1.0/avenoise)
  do i=0,nfft2-1
     j=i0+i
     if(i.gt.nh2) j=j-nfft2
     c2(i)=fac*c1(j)
  enddo

  call four2a(c2,nfft2,1,1,1)              !Backward FFT

  nspsd=8*nsps8/ndown
  nz2=8*npts8/ndown

!  call flush(68)
!  call flush(69)

  return
end subroutine downsam9
