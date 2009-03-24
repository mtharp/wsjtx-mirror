      program tbtest

      parameter (NBMAX=256)             !Max size of user message, bits
      parameter (NSMAX=(NBMAX+14)*8)    !Max number of one-bit encoded symbols
      character arg*8
      integer hist(NBMAX)
      integer*1 dgen(NBMAX)
      integer*1 ddec(NBMAX)
      integer*1 symbols(NSMAX)
      integer*1 symbols0(NSMAX)
      integer*1 dbits0(NBMAX)
      integer*1 dbits(NBMAX)
      integer*1 dberr(NBMAX)
      integer mettab(0:255,0:1)
      real rr(NSMAX)
      data idum/-1/,hist/NBMAX*0/
      save

      nargs=iargc()
      if(nargs.ne.7) then
         print*,'Usage: tbtest alpha scale ncrc minmet nRay EbNo iters'
         go to 999
      endif
      call getarg(1,arg)
      read(arg,*) alpha        !Relative noise voltage
      call getarg(2,arg)
      read(arg,*) nscale       !Scale factor
      call getarg(3,arg)
      read(arg,*) ncrc         !Number of CRC bits
      call getarg(4,arg)
      read(arg,*) minmet       !Minimum acceptable metric
      call getarg(5,arg)
      read(arg,*) nRay         !AWGN=0, Rayleigh=1
      call getarg(6,arg)
      read(arg,*) EbNo         !Eb/No
      call getarg(7,arg)
      read(arg,*) iters        !Iterations at each signal level

!      minmet=0
!      minmet=108       ! Poly409
!      minmet=100       ! Poly414
!      minmet=125       ! Poly615

C  Generate the metric table
      mode=64
      bias=0.0                        !Metric bias: viterbi=0, seq=rate
      call genmet(mode,bias,mettab)   !6=DBPSK, 7=2FSK
      do i=0,255
         write(18,5001) i,mettab(i,0),mettab(i,1)
 5001    format(i3,2i8)
      enddo

C  Generate random user data
      nuser=78
      nbits=nuser+ncrc
      x=ran1(idum)
      do i=1,nuser
         dbits(i)=0
         x=ran1(idum)
         if(x.gt.0.5) dbits(i)=1
         dbits0(i)=dbits(i)
      enddo
      call chksum(dbits0,nuser,ncrc,nchk)
      do i=1,ncrc
         n=iand(ishft(nchk,i-ncrc),1)
         dbits(nuser+i)=n
         dbits0(nuser+i)=n
      enddo

      call pack8(dbits,nbits,dgen,nbytes)

C  Encode user data into array of one-bit symbols.
      call encode(dgen,nbits,symbols0,nsymbols,kk,nn)
      rate=float(nbits)/nsymbols
      baud=(nsymbols/6.0)/47.0
      do i=1,nsymbols
         rr(i)=1.0
      enddo

      write(*,1001) kk,nn,nbits,nsymbols,rate,baud,minmet,ncrc,nRay
 1001 format('K=',i2,'   r=1/',i1,'   Nbits=',i2,'   Nsymbols=',i3,
     +  '   rate=',f4.2,'   baud=',f6.3/
     +  'MinMet=',i6,'   ncrc=',i1,'   nRay=',i1)
      write(*,1002)
 1002 format(/' Eb/No  Es/No  dB65  RawErrs    BER     FER  ',
     +  '  False    Copy'/60('-'))

      maxerr=-999999
      EbNo1=12.0
      EbNo2=-3.0
      if(EbNo.ne.0.0) then
         EbNo1=EbNo
         EbNo2=EbNo
      endif

C  Loop over specified S/N range.
      do EbNo=EbNo1,EbNo2,-1.0
         EsNo=EbNo + 10.0*log10(rate)
         db65=EsNo - 10.0*log10(2500.0/baud)
         snr0=sqrt(10.0**(0.1*EsNo))
         nbiterr=0
         nsymerr=0
         nferror=0
         nfalse=0
         ncopy=0
C  Do requested number of iterations
         do iter=1,iters

            if(nRay.eq.1) then
               sq=0.
               do i=1,nsymbols
                  rr(i)=rayleigh()
                  sq=sq+rr(i)**2
               enddo
               rms=sqrt(sq/nsymbols)
               do i=1,nsymbols
                  rr(i)=rr(i)/rms
               enddo
            endif

C  Count the number of errors in the raw (one-bit) symbols, as
C  demodulated using hard decisions:

            do i=1,nsymbols
!               x = snr0*(1.0 - 2.0*symbols0(i)) + gasdev(idum)
               x = rr(i)*snr0*(1.0 - 2.0*symbols0(i)) + gasdev(idum)
               n=nint(10.0*x)
               symbols(i)=max(min(n,127),-127)
               if(symbols0(i).eq.0 .and. symbols(i).lt.0)
     +               nsymerr=nsymerr+1
               if(symbols0(i).eq.1 .and. symbols(i).ge.0) 
     +               nsymerr=nsymerr+1
            enddo

C  Decode noisy symbols using Viterbi soft-decision decoder.
            call viterbi(symbols,nbits,mettab,ddec,metric)
            call unpack8(ddec,nbits,dbits)

C  Count errors in decoded bits and frames.
            nf=0
            do i=1,nbits
               dberr(i)=0
               if(dbits(i).ne.dbits0(i)) then
                  nbiterr=nbiterr+1
                  nf=1
                  dberr(i)=1
                  hist(i)=hist(i)+1
               endif
            enddo
            if(metric.lt.minmet) nf=1
            nferror=nferror+nf

            ncrcerr=0
            call chksum(dbits,nuser,ncrc,nchk)
            nchk1=0
            do i=1,ncrc
               nchk1=2*nchk1+dbits(nuser+i)
            enddo
            if(nchk.ne.nchk1) ncrcerr=1

            if(nf.eq.1 .and. metric.ge.minmet .and. ncrcerr.eq.0) then
               nfalse=nfalse+1
               maxerr=max(maxerr,metric)
            endif
            if(nf.eq.0 .and. metric.ge.minmet .and. ncrcerr.eq.0) 
     +            ncopy=ncopy+1
            write(15,3001) iter,nferror,nf,metric,ncrcerr,nfalse,ncopy
 3001       format(7i6)

!            write(14,1030) EbNo,nf,metric
! 1030       format(f8.1,i5,i8)
!            if(nf.eq.1) write(13,3003) EbNo,metric,(dberr(i),i=1,nbits)
! 3003       format(f6.1,i6,2x,60i1)
         enddo

C  Print summary statistics for each S/N value.
         symerrs=float(nsymerr)/(nsymbols*iters)
         biterrs=float(nbiterr)/(nbits*iters)
         fer=float(nferror)/iters
         falserate=float(nfalse)/iters
         copy=float(ncopy)/iters
         write(*,1010) EbNo,EsNo,db65,symerrs,biterrs,fer,
     +      falserate,copy
 1010    format(f6.1,2f7.1,5f8.4)

         write(13,3004) (i,hist(i),i=1,nbits)
 3004    format(i3,i10)
         if(copy.eq.0.0) go to 998
      enddo
 998  print*,'Maxerr:',maxerr

 999  end

      subroutine chksum(d,n,ncrc,nchk)
      integer*1 d(n)

      nchk=0
      do i=1,n
         j=3-mod(i-1,4)
         nchk=nchk + d(i)*2**j
      enddo
      nchk=iand(nchk,2**ncrc-1)

      return
      end
