program rxtest

  character*22 message
  character*11 datetime
  real*8 freq
  real a(5)
  complex c3(45000),c4(45000)
  complex c(65536)


  dt=1.0/375
  jz=45000
  do ifile=1,9999
     read(71,end=999),datetime,nsnrx,dtx,freq,nf1,c3
     if(ifile.ne.2) go to 24

!     fac=1.0/65536.
!     c(:jz)=fac*c3
!     c(jz+1:)=0.
!     call four2a(c,65536,1,-1,1)
!     nn=512
!     do i=1,nn
!        fac=float(nn-i)/nn
!        c(i)=fac*c(i)
!        j=65537-i
!        c(j)=fac*c(j)
!     enddo
!     c(nn:65536-nn)=0.
!     call four2a(c,65536,1,1,1)
!     a=0.
!     a(1)=1.4648
!     ccf=-fchisq(c,jz,375.0,a,-200,200,ccfbest,dtbest)
!     print*,dtbest,dtx,dtbest-dtx-2.0
!     dtx=dtbest-2.0

     do idt=0,128
        ii=(idt+1)/2
        if(mod(idt,2).eq.1) ii=-ii
        i1=nint((dtx+2.0)/dt) + ii !Start index for synced symbols
        if(i1.ge.1) then
           i2=i1 + jz - 1
           c4(1:jz)=c3(i1:i2)
        else if(i1.eq.0) then
           c4(1)=0.
           c4(2:jz)=c3(jz-1)
        else
           c4(:-i1+1)=0
           i2=jz+i1
           c4(-i1:)=c3(:i2)
        endif
        call decode162(c4,jz,message,ncycles,metric,nerr)
        if(message(1:6).ne.'      ') then
           call rect(c4,message,dfx2,width,pmax)
           write(*,1012) ifile,nsnrx,dtx,freq,nf1,message,ii,width,pmax-44
1012       format(i4.4,i4,f5.1,f11.6,i3,2x,a22,i5,2f6.1)

           go to 24
        endif
     enddo
24   continue
  enddo
  
999 end program rxtest
