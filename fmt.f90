program fmt

! Program for ARRL Frequency Measuring Test, etc.

  parameter (NZ1=65536+9)                          !Max length of waveform
  parameter (NZ4=4*NZ1)
  integer*2 iwave(NZ1),kwave(NZ4)
  character arg*12,cmnd*120
  real x(65536)
  complex c(0:32768)
  real s1(16384)
  real*8 s,sq
  integer time
  integer soundin
  equivalence (x,c)

  nargs=iargc()
  if(nargs.lt.2) then
     print*,'Usage: fmt <kHz> <offset> <nrpt>'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) nkhz
  call getarg(2,arg)
  read(arg,*) noffset
  nrpt=9999999
  if(nargs.ge.3) then
     call getarg(3,arg)
     read(arg,*) nrpt
  endif

!  cmnd='rigctl -m 214 -r COM1 -s 4800 -C data_bits=8 -C stop_bits=2 -C serial_handshake=Hardware F 3592607'
  open(10,file='fmt.ini',status='old',err=910)
  read(10,*) cmnd
  close(10)

  nHz=1000*nkhz - noffset
  write(cmnd(92:),*) nHz
  iret=system(cmnd)
  if(iret.ne.0) then
     print*,'Error executing rigctl command to set frequency:'
     print*,cmnd
     go to 999
  endif

  open(13,file='fmt.out',status='unknown',position='append')
  open(14,file='fmt.spec',status='unknown',position='append')
  open(15,file='fmt.raw',status='unknown',position='append',    &
       form='unformatted')

  call soundinit
  ndevin=0
  npts=NZ1
  iqmode=0
  do iter=1,nrpt
     nsec=time()
     ierr=soundin(ndevin,kwave,4*npts,iqmode)
     if(ierr.ne.0) then
        print*,'Error in soundin',ierr
        stop
     endif
     call fil1(kwave,4*npts,iwave,n2)

     s=0.
     do i=1,n2
        s=s + iwave(i)
     enddo
     ave=s/n2
     sq=0.
     do i=1,n2
        x(i)=iwave(i)-ave
        sq=sq + x(i)**2
     enddo
     rms=sqrt(sq/n2)

     nfft=65536
     call four2a(x,nfft,1,-1,0)

     df=12000.d0/nfft
     smax=0.
     nq=nfft/4
     fac=1.0/float(nfft)**2
     do i=10,nq
        s=fac * (real(c(i))**2 + aimag(c(i))**2)
        if(s.gt.smax) then
           smax=s
           ipk=i
        endif
        s1(i)=s
     enddo

     fpeak=ipk*df
     n=mod(nsec,86400)
     nhr=n/3600
     nmin=mod(n/60,60)
     nsec=mod(n,60)
     smax=100.0*smax/(rms*rms)
     write(*,1100)  nhr,nmin,nsec,nkhz,noffset,fpeak,smax,ave,rms
     write(13,1100) nhr,nmin,nsec,nkhz,noffset,fpeak,smax,ave,rms
1100 format(i2.2,':',i2.2,':',i2.2,i7,i6,4f10.2)
     write(14,1100) nhr,nmin,nsec,nkhz,noffset,fpeak,smax,ave,rms
     do i=1,nq
        write(14,1102) i*df,s1(i)
1102    format(2f10.2)
     enddo
     write(15) nhr,nmin,nsec,nkhz,noffset,fpeak,smax,ave,rms,iwave
     call flush(13)
     call flush(14)
     call flush(15)
  enddo
  go to 999

910 print*,'Cannot open file: fmt.ini'

999 end program fmt

