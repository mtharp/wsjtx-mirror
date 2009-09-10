program quest

! Quest for optimum digital modes for EME, ionospheric scatter, etc.

  include 'qparams.f90'  
  real s(NCH,NSZ)                  !Simulated spectra
  integer dgen1(NZ1)               !Generated data
  integer*1 dgen3(NZ4)             !Convolutionally encoded data
  integer recv1(NZ1)               !Decoded user message
  integer jsym(NSZ)
  integer icos(10)                 !Costas array used for sync
  integer*1 t1(100)
  integer*1 t2(100)
  data idum/-1/
  data icos/10*0/

! Get user parameters from command line
  call qinit(nb1,ns1,ns2,m0,ncode,minmet,nray,txtime,   &
       snrdb,iters,icos)

  if(ncode.gt.3000) nb1=m0*mod(ncode,100)
  limit=minmet                   !Timeout limit for Fano decoder
  if(ncode.eq.232) minmet=0      !No metric test for Fano decoder
  nc=ncode/100                   !Code rate = 1/nc
  kc=mod(ncode,100)              !Constraint length
  ntones=2**m0                   !Number of tones (data)
  nttot=ntones
  if(ns2.lt.0) nttot=nttot+1     !Total number of tones (data plus sync)
  krs=(nb1+m0-1)/m0              !Number of m0-bit symbols for user's data
  nb2=nb1
  nb3=(nb2+kc-1)*nc              !Number of bits after convolutional coding
  if(ncode/100.ge.10) nb3=m0*ncode/100
  nsymd=(nb3+m0-1)/m0            !Number of data symbols
  nsyms=ns1*abs(ns2)             !Number of sync symbols
  nsymt=nsymd+nsyms              !Total channel symbols
  rate=float(nb1)/(m0*nsymt)     !Overall rate, user bits to channel bits
  if(txtime.gt.0.0) then
     baud=nsymt/txtime
  else
     baud=-12000.0/txtime
     txtime=nsymt/baud
  endif
  bw=nttot*baud                 !Bandwidth (Hz)
  sps=12000.0/baud
  open(10,file='nfft.dat',status='old')
  do i=1,9999999
     read(10,*) nfft
     if(float(nfft).ge.sps) go to 10
     nfft0=nfft
  enddo
10  close(10)

  write(*,1000) nb1,ns1,ns2,nttot
1000 format(/'User bits:',i3,7x,'Sync symbols:',i2,' x',i3,   &
          '     Modulation:',i3,'-FSK')
  if(ncode/100.lt.10) then
     write(*,1004) kc,nc,nb3,minmet
1004 format('Convolutional code: K=',i2,', r=1/',i1,5x,'nb3:',i4,   &
          '   MinMet:',i5)
  else
     write(*,1005) nc,kc,nb3
1005 format('Reed Solomon code: RS(',i2,',',i2,')   nb3:',i4)
  endif
  write(*,1006) nsymd,nsyms,nsymt,rate
1006 format('Channel Symbols:   Data:',i3,'   Sync:',i3,'   Total:',i4, &
          '    Rate:',f5.2)
  write(*,1008) txtime,baud,bw,nray
1008 format('TxTime:',f7.3,'   Baud:',f8.3,'    BW:',f6.1,          &
          3x,'Rayleigh:',i2)
  write(*,1009) sps,nfft0,sps/nfft0,nfft,nfft/sps
1009 format('Nsps:',f8.1,'   Suggested FFTs:',i6,' (',f6.4,')',      &
          i7,' (',f6.4,')')

  write(*,1010) 
1010 format(/'  EsNo  EbNo  db65  esync   sync    false     copy     time'/  &
             '------------------------------------------------------------')

  nblk=nsymt/ns1

! Generate and encode a random "message"
  call qdat(nsymd,krs,m0,kc,nc,dgen1,dgen3,nbits)
  call unpackbits(dgen1,krs,m0,t1)             !Unpack into bits

  idb1=12
  idb2=-3
  if(snrdb.ne.0.0) idb2=idb1
  do idb=idb1,idb2,-1
     EsNo=idb
     if(snrdb.ne.0.0) EsNo=snrdb
     EbNo=EsNo - 10.0*log10(m0*rate)
     db65=EsNo - 10.0*log10(2500.0/baud)
     sig=sqrt(10.0**(0.1*EsNo))                !Signal level

! Clear the statistical accumulators
     nsync=0
     ncopy=0
     nfalse=0
     esync=0.
     tdecode=0.

     do iter=1,iters

        ncount=-1
! Simulate a spectrum of received noise and symbols
        call qsim(icos,dgen3,sig,nray,ns1,ns2,nsyms,nsymt,ntones,nblk,jsym,s)

! Establish sync
        call qsync(s,icos,jsym,nblk,ns2,nsyms,nsymt,ntones,esync,nsync)

! Decode the (supposedly) synchronized signal
        t0=second()
        call qdecode(s,nbits,jsym,ns2,m0,nsyms,nsymd,nsymt,nblk,      &
             limit,krs,ncode,recv1,ntimeout,metric,ncount)
        tdecode=tdecode + second()-t0

! See if copy is correct
        ierr=0
        do i=1,krs
           if(recv1(i).ne.dgen1(i)) ierr=ierr+1
        enddo
        if(ncount.ge.0 .or. (ierr.eq.0 .and. metric.ge.minmet)) ncopy=ncopy+1
        if(ncode.eq.232) then
           if(ierr.gt.0 .and. ntimeout.eq.0) nfalse=nfalse+1
        else if(ncode/100.lt.10) then
           if(ierr.gt.0 .and. metric.ge.minmet) nfalse=nfalse+1
        else
           if(ierr.gt.0 .and. ncount.ge.0) nfalse=nfalse+1
        endif
     enddo

! Print statistics
     fsync=float(nsync)/iters
     ffalse=float(nfalse)/iters
     fcopy=float(ncopy)/iters
     tdecode=tdecode/iters
     write(*,1020)  EsNo,EbNo,db65,esync,fsync,ffalse,fcopy,tdecode
1020 format(3f6.1,f6.1,4f9.4)

!     if(fsync.lt.0.5) go to 999
     if(fcopy.eq.0.0) go to 999
  enddo

999 continue
end program quest
