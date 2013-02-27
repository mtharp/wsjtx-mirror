subroutine spread(iwave0,npts,fspread,iwave)

  parameter (NMAX=48*11025)
  integer*2 iwave0(npts)
  integer*2 iwave(npts)
  complex z,zf

  twopi=8.0*atan(1.0)
  tspread=1.0/fspread
  iz=11025.0*tspread
  nblks=npts/iz + 1
  j=0
  phi=0.
  do n=1,nblks
     call random_number(r)
     df=fspread*(2.0*(r-0.5))**2
     if(r.lt.0.5) df=-df
     dphi=twopi*df/11025.0
     do i=1,iz
        j=j+1
        x=iwave0(j)/32767.0
        y=0.
        y=sqrt(1.0-x*x)
        if(j.ge.2 .and. iwave0(j).lt.iwave0(j-1)) y=-y
        phi=phi+dphi
        zf=cmplx(cos(phi),sin(phi))
        z=zf*cmplx(x,y)
        iwave(j)=32767.0*real(z)
        if(j.ge.npts) exit
     enddo
  enddo

  return
end subroutine spread
