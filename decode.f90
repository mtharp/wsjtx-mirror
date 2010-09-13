subroutine decode

!  Decode WSPR signals for one 2-minute sequence.

  character*80 savefile
  integer*2 jwave(114*12000)
  real*8 df,fpeak
  real x(65536)
  complex c(0:32768)
  equivalence (x,c)
  include 'acom1.f90'

  f0b=f0a
  if(ncal.eq.2) then
     fac=1.e-6
     do i=1,65536
        x(i)=fac*iwave(i)
     enddo
     call xfft(x,65536)
     df=12000.d0/65536.d0
     smax=0.
     do i=1,16384
        s=real(c(i))**2 + aimag(c(i))**2
        if(s.gt.smax) then
           smax=s
           fpeak=i*df
        endif
     enddo

     call cs_lock('decode')
     write(*,1002) fpeak
1002 format('Measured audio frequency:',f10.2,' Hz')
     ncal=0
     ndecoding=0
     call cs_unlock

     go to 900
  else
     minsync=1
     if(nsave.gt.0 .and. ndiskdat.eq.0) jwave=iwave(1:114*12000)
     call mept162(thisfile,appdir,nappdir,f0,minsync,iwave,NMAX,nbfo,ierr)
     if(nsave.gt.0 .and. ndiskdat.eq.0 .and. ierr.eq.0) then
        savefile=appdir(:nappdir)//'/save/'//thisfile
        npts=114*12000
        call wfile5(jwave,npts,12000,savefile)
     endif
  endif

  call cs_lock('decode')
  write(14,1100)
1100 format('$EOF')
  call flush(14)
  rewind 14
  ndecdone=1
  ndiskdat=0
  ndecoding=0
  call cs_unlock

900  return
end subroutine decode
