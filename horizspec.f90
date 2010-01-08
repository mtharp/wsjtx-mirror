subroutine horizspec(x,brightness,contrast,a)

  real x(4096)
  integer brightness,contrast
  integer*2 a(750,300)
  real y(512),ss(128)
  complex c(0:256)
  equivalence (y,c)
  include 'gcom1.f90'
  include 'gcom2.f90'
  save

  nfft=512
  nq=nfft/4
  gain=50.0 * 3.0**(0.36+0.01*contrast)
  offset=0.5*(brightness+30.0)
  df=12000.0/512.0
  if(ntr.ne.ntr0) then
     if(lauto.eq.0 .or. ntr.eq.TxFirst) then
        call hscroll(a,nx)
        nx=0
     endif
     ntr0=ntr
  endif

  i0=0
  do irpt=1,5
     if(nx.lt.750) nx=nx+1
     do i=1,nfft
        y(i)=1.4*x(i+i0)
     enddo
     call xfft(y,nfft)
     nq=nfft/4
     do i=1,nq
        ss(i)=real(c(i))**2 + aimag(c(i))**2
     enddo

     p=0.
     do i=13,112
        p=p+ss(i)
        n=0
        if(ss(i).gt.0.) n=gain*log10(0.05*ss(i)) + offset
        n=min(252,max(0,n))
        j=113-i
        a(nx,j)=n
     enddo

     ng=140 - 30*log10(0.00033*p+0.001)
     ng=min(ng,150)
     if(nx.eq.1) ng0=ng
     if(abs(ng-ng0).le.1) then
        a(nx,ng)=255
     else
        ist=1
        if(ng.lt.ng0) ist=-1
        jmid=(ng+ng0)/2
        i=max(1,nx-1)
        do j=ng0+ist,ng,ist
           a(i,j)=255
           if(j.eq.jmid) i=i+1
        enddo
        ng0=ng
     endif
     i0=i0+480
  enddo

  return
end subroutine horizspec
