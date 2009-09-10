      program testrs

      integer dgen(23)                           !Generated data, i*4
      integer*1 dgen1(23)                        !Generated data, i*1
      integer dat(23)                            !Decoded data, i*4
      real s(64,79)                              !Simulated 64-FSK data
      real s2(64,79)                             !Simulated 64-FSK data
      character arg*8
      character decoded*22                       !Decoded message
      character abc*1
      integer*2 gsym2(63)                        !Encoded data, KV
      integer gsym(63)                           !Encoded data, Karn
      logical first
      data idum/-1/,first/.true./

      nargs=iargc()
      if(nargs.ne.12) then
        print*,'Usage: testrs nkv Lambda MaxE nAddS ',
     +    ' ABC nave QSB  N  K sync dB iters'
        print*,'               1    15     8   200',
     +    '    B    1   0  63 12   8   0  1000'
        go to 999
      endif
      call getarg(1,arg)
      read(arg,*) nkv
      call getarg(2,arg)
      read(arg,*) xlambda
      call getarg(3,arg)
      read(arg,*) MaxE
      call getarg(4,arg)
      read(arg,*) naddsynd
      call getarg(5,abc)
      mode65=1
      if(abc.eq.'B' .or. abc.eq.'b') mode65=2
      if(abc.eq.'C' .or. abc.eq.'c') mode65=4
      call getarg(6,arg)
      read(arg,*) nave
      call getarg(7,arg)
      read(arg,*) nqsb
      call getarg(8,arg)
      read(arg,*) nn
      call getarg(9,arg)
      read(arg,*) kk
      call getarg(10,arg)
      read(arg,*) sync0
      call getarg(11,arg)
      read(arg,*) db0
      call getarg(12,arg)
      read(arg,*) iters
      nadd=nave*mode65

C  Initialize ASD codec
      mm=6
      nq=2**mm
      nfz=3
      nqbits=8
      print*,mm,nq,nn,kk,nfz,xlambda,maxe,naddsynd,nqbits
      call asdinit(mm,nq,nn,kk,nfz,xlambda,maxe,naddsynd,nqbits)
C  Generate and encode random data
      do i=1,kk
         dgen1(i)=63.9999*ran1(idum)
         dgen(i)=dgen1(i)
      enddo
      call rsencode(dgen1,gsym2)                       !Encode with KV
      print*,(dgen1(i),i=1,12)
      print*,(gsym2(i),i=1,63)

C  Initialize Karn codec
      call rs_init(mm,nq,nn,kk,nfz)
      call rs_encode(dgen,gsym)                        !Encode with Karn
      do i=1,nn                 !Copy i*2 to i*4
         if(gsym(i).ne.gsym2(i)) stop 'KV and Karn encoding differ.'
         gsym(i)=gsym2(i)
      enddo

      idb1=10 - int(2.0*log(float(nave))/log(2.0))
      if(abs(db0).ge.99.0) idb1=20
      idb2=-10
      if(db0.ne.0.0 .and. abs(db0).lt.90.0) then
         idb1=db0
         idb2=db0
      endif

      write(*,1000) nn,kk,mm
 1000 format(/'Code: RS(',i2,',',i2,') over GF(2^',i1,')')
      write(*,1001) abc,nqsb,nave
 1001 format('JT65',a1,'   Rayleigh:',i2,'   nave:',i2)

      if(nkv.eq.1) then
         write(*,1002) xlambda,maxe,naddsynd
 1002    format('Lambda:',f5.1,'   MaxE:',i3,'   NAddSynd:',i4)
         if(maxe.ge.kk-1) write(*,1003)
 1003    format('*** Warning *** MaxE > K-2 ***')
      else
         write(*,1004)
 1004    format('Karn RS decoder.')
      endif

      write(*,1005) 
 1005 format(/
     +  '  dB   Sig  Errs   False     Good     Time'/
     +  '------------------------------------------')

      if(db0.eq.20.0) then
         idb1=20
         idb2=-20
      endif
      do idb=idb1,idb2,-1
         db=idb
         if(db0.eq.30.0) db=db-0.32
         if(idb1.eq.idb2) db=db0
         sig=sqrt(2.0*63.0/(nn*mode65)) * 10.0**(0.05*db)
         nsync=0
         sumsync=0.
         syncmin=1.e30
         badsync=0.
         ngood=0
         nfalse=0
         ngc=0
         t0=second()
         do iter=1,iters
            call zero(dat,kk)
C  Generate 2d mfsk data
            call gendat2(gsym,sig,nadd,nqsb,mode65,nn,s,s2) 
            call chksync(s2,nn,nsyncok,snrsync)
            if(snrsync.lt.sync0) nsyncok=0
            if(nsyncok.eq.1) then
               nsync=nsync + 1
               sumsync=sumsync + snrsync
               syncmin=min(syncmin,snrsync)
            else
               if(snrsync.ge.sync0) badsync=max(badsync,snrsync)
            endif
            call extracta(s,nadd,nn,kk,nqbits,nkv,ncount,decoded,dat)

C  See if there are any errors
            nok=1
            do i=1,kk
               if(dat(i).ne.dgen(i)) then
                  nok=0
               endif
            enddo

C  If no errors, increment ngood and update  ncount.
            if(nok.eq.1) then
               ngood=ngood+1
               ngc=ngc+ncount
            endif

C  If there were errors and ncount was not negative, it's a false decode:
            if(nok.eq.0 .and. ncount.ge.0) nfalse=nfalse+1
         enddo
         t1=second()

         fsync=float(nsync)/iters
         gc=0.
         if(ngood.gt.0) gc=float(ngc)/ngood
         write(*,1100) db,db-29.68,gc,float(nfalse)/iters,
     +      float(ngood)/iters,(t1-t0)/iters
 1100    format(f5.1,f6.1,f5.1,2f9.5,f8.3,f9.5,3f7.2)
         if(db.le.-3.0 .or. (ngood.eq.0 .and. fsync.lt.0.5)) go to 999
      enddo

 999  end
