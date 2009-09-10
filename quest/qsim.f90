subroutine qsim(icos,dgen3,sig,nray,ns1,ns2,nsyms,nsymt,ntones,nblk,jsym,s)

  include 'qparams.f90'
  real s(NCH,NSZ)                  !Simulated spectra
  integer*1 dgen3(NZ4)             !Convolutionally encoded data
  real rr(NSZ)
  integer jsym(NSZ)
  integer icos(10)
  data idum/-1/
  save

  ms2=abs(ns2)
  js=0
  jsym=0
  do j=1,nsymt                            !By default, no Rayleigh fading
     rr(j)=1.0
     n=mod(j-1,nblk)+1
     if(ns2.gt.0 .and. n.le.ms2 .and. js.lt.nsyms) then
        js=js+1                           !This one is a sync symbol
        jsym(j)=1
     endif
  enddo

  if(ns2.lt.0) then
     do nb=1,ns1
        j0=(nb-1)*nblk + 1
        do i=1,ms2
           jsym(j0+icos(i))=1
        enddo
     enddo
  endif

! Generate and scale the Rayleigh fading array
  if(nRay.eq.1) then                 
     sq=0.
     do i=1,nsymt
        rr(i)=rayleigh()               !Q: **2 ??
        sq=sq+rr(i)**2
     enddo
     rms=sqrt(sq/nsymt)
     do i=1,nsymt
        rr(i)=rr(i)/rms
     enddo
  endif

! At beginning and end of received data we have only noise
  do j=1,10
     do i=1,ntones+20
        x=0.707*gasdev(idum)
        y=0.707*gasdev(idum)
        s(i,j)=x*x + y*y
     enddo
  enddo
  do j=nsymt+1,nsymt+10
     do i=1,ntones+20
        x=0.707*gasdev(idum)
        y=0.707*gasdev(idum)
        s(i,j)=x*x + y*y
     enddo
  enddo
  
! Simulate spectra for all channel symbols
  jd=0
  js=0
  do j=1,nsymt
     n=mod(j-1,nblk)+1
     if(jsym(j).eq.1) then
        js=js+1                                 !This is a sync symbol
        if(ns2.gt.0) then
           do i=1,ntones+20
              x=0.707*gasdev(idum)
              y=0.707*gasdev(idum)
              if(i.eq.icos(n)+10) x=x+sig*rr(j)
              s(i,j+10)=x*x + y*y
           enddo
        else
           do i=1,ntones+20
              x=0.707*gasdev(idum)
              y=0.707*gasdev(idum)
              if(i.eq.ntones+10) x=x+sig*rr(j)
              s(i,j+10)=x*x + y*y
           enddo
        endif
     else
        jd=jd+1                                !This is a data symbol
        i0=dgen3(jd)+11
        do i=1,ntones+20
           x=0.707*gasdev(idum)
           y=0.707*gasdev(idum)
           if(i.eq.i0) then
              x=x+sig*rr(j)
           endif
           s(i,j+10)=x*x + y*y
        enddo
     endif
  enddo

  return
end subroutine qsim
