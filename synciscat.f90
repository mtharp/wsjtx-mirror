subroutine synciscat(dat,jz,DFTolerance,NFreeze,MouseDF,dtx,dfx,      &
     snrx,nsync,isbest,ccfblue,ccfred,s2,ps0,nsteps,short,kshort)

! Synchronizes ISCAT data, finding the best-fit DT and DF.  

  parameter (NFFTMAX=1024)         !Max length of FFTs
  parameter (NHMAX=NFFTMAX/2)      !Max length of power spectra
  parameter (NSMAX=300)            !Max number of quarter-symbol steps
  integer DFTolerance              !Range of DF search
  real dat(jz)                     !Raw data, downsampled to 6 kHz
  real xs1(NHMAX)
  real xsave(NHMAX)
  real s1(NHMAX,NSMAX)             !2d spectrum, stepped by half-symbols
  real s2(64,63)                   !2d spectrum, synced data symbols only
  real x(NFFTMAX)                  !Temp array for computing FFTs
  real ccfblue(-5:540)             !CCF with pseudorandom sequence
  real ccfred(-224:224)            !Peak of ccfblue, as function of freq
  real tmp1(NSMAX),tmp2(NSMAX)
  real s3(256,8)
  real ps0(431)
  integer ns(300)
  integer ic10(10)
  data ic10/0,1,3,7,4,9,8,6,2,5/     !10x10 Costas array

! Set up the ISCAT sync patterns
  nsync=10
  nsym=63+10+2

! Do FFTs of twice symbol length, stepped by quarter symbols.  
  nfft=1024
  nh=nfft/2
  nq=nfft/4
  nsteps=4*(jz-NH)/nh
  kstep=nh/4
  df=12000.0/nfft

! Keep only an integer number of repetitions
  nsteps=nsteps/300
  nsteps=nsteps*300

! Compute power spectrum for each quarter-symbol step
  s1=0.
  s3=0.
  xsave=0.
  ns=0
  do j=1,nsteps
     k=(j-1)*kstep + 1
     jj=mod(j-1,300)+1
     do i=1,nh
        x(i)=dat(k+i-1)
        x(i+nh)=0.
     enddo
     call ps(x,nfft,xs1)
     s1(1:nq,jj)=s1(1:nq,jj)+xs1(1:nq)
     ns(jj)=ns(jj)+1
     jj=mod(j-1,8)+1
     s3(1:nq,jj)=s3(1:nq,jj)+xs1(1:nq)
  enddo

! Flatten the s1 spectrum
  do i=1,nq
     do j=1,300
        tmp1(j)=s1(i,j)/ns(j)
     enddo
     call pctile(tmp1,tmp2,300,45,xsave(i))
     fac=1.0
     if(xsave(i).gt.0.0) fac=1.0/xsave(i)
     do j=1,300
        s1(i,j)=fac*s1(i,j)
     enddo
  enddo

! Determine the search range in frequency
  famin=300.
  fbmax=1100.
  f0=700.0
  ia=famin/df
  ib=fbmax/df
  i0=nint(f0/df)
  if(NFreeze.eq.1) then
     fa=max(famin,f0+MouseDF-DFTolerance)
     fb=min(fbmax,f0+MouseDF+DFTolerance)
  else
     fa=max(famin,f0+MouseDF-400)
     fb=min(fbmax,f0+MouseDF+400)
  endif

! Save the passband spectrum, for display
  do i=1,nq
     ps0(i)=db(xsave(i))
  enddo

! Test for shorthand message
  do i=ia,ib+3*42
     smin=1.e30
     do j=1,8
        smin=min(smin,s3(i,j))
     enddo
     do j=1,8
        s3(i,j)=s3(i,j)/smin
     enddo
  enddo

  kshort=0
  ipk=0
  short=-1.e30
  do k=1,3
     do j=1,8
        jj=j+4
        if(jj.gt.8) jj=jj-8
        do i=ia,ib
           sum=s3(i,j) - s3(i,jj)+ s3(i+42*k,jj) - s3(i+42*k,j)
           if(sum.gt.short) then
              short=sum
              ishort=i
              kshort=k
           endif
        enddo
     enddo
  enddo

! Find best frequency bin and best sync pattern
  syncbest=-1.e30
  ss=0.
  nss=0
  do i=ia,ib
     smax=-1.e30
     do lag=0,299
        sum1=0.
        sum2=0.
        sum3=0.
        b1=0.
        b2=0.
        b3=0.
        do j=1,nsync
           j0=4*j - 3 + lag
           jj0=mod(j0-1,300)+1
           sum1=sum1 + s1(i+2*ic10(j),jj0)
           do k=0,9
              if(k.ne.ic10(j)) b1=b1+s1(i+2*k,jj0)
           enddo
        enddo
        ccf1=500.0*sum1/(b1*nsync)
        if(ccf1.gt.smax) then
           smax=ccf1
           ispk=1
        endif
     enddo

     j=i-i0
     if(abs(j).le.224) then
        ccfred(j)=smax
        ss=ss+smax
        nss=nss+1
     endif
     f=i*df
     if(f.ge.fa .and. f.le.fb .and. smax.gt.syncbest) then
        syncbest=smax
        ipk=i
        isbest=ispk
     endif
  enddo

  avered=ss/nss

! Once more, using best frequency and best sync pattern:
  ccfblue=0.
  syncbest=-1.e30
  do lag=0,299
     sum=0.
     do j=1,nsync
        j0=4*j - 3 + lag
        jj0=mod(j0-1,300)+1
        sum=sum + s1(ipk+2*ic10(j),jj0)
     enddo
     ccfblue(lag)=sum/nsync
     if(ccfblue(lag).gt.syncbest) then
        lagpk=lag
        syncbest=ccfblue(lag)
     endif
  enddo

! Remove baseline from ccfblue
  sum=0.
  nsum=0
  do j=0,299
     if(abs(j-lagpk).gt.2) then
        sum=sum + ccfblue(j)
        nsum=nsum + 1
     endif
  enddo
  ave=sum/nsum
  ccfblue(0:299)=ccfblue(0:299)-ave
  tmp1=ccfblue(0:299)
  ccfblue=0
  do i=0,299
     j=i+lagpk-146
     if(j.gt.300) j=j-300
     if(j.lt.1) j=j+300
     ccfblue(i+98)=tmp1(j)                      !The 98 is empirical
  enddo

!### Should compute snrave, snrpeak...
  snrsync=syncbest/ave - 1.0
  snrx=-30.
  if(snrsync.gt.0.0) snrx=db(snrsync) - 19.5
  dtstep=kstep/12000.d0
  dtx=dtstep*lagpk
  dfx=ipk*df - f0

  ja=ia-i0
  jb=ib-i0
  ccfred(ja:jb)=0.25*(ccfred(ja:jb)-avered)
  ccfred(-224:ja)=0.
  ccfred(jb:224)=0.

! Copy synchronized data symbols from s1 into s2
  do j=1,63
     j0=4*j + lagpk + 45
     jj0=mod(j0-1,300)+1
     do i=1,64
        s2(i,j)=s1(ipk+2*(i-1),jj0)
     enddo
  enddo

! Determine the message type
  s16=0.
  s18=0.
  s20=0.
  do j=-1,0
     j0=4*j + lagpk + 45
     jj0=mod(j0-1,300)+1
     s16=s16 + s1(ipk+2*16,jj0)
     s18=s18 + s1(ipk+2*18,jj0)
     s20=s20 + s1(ipk+2*20,jj0)
  enddo
  if(max(s16,s18,s20).eq.s16) isbest=1
  if(max(s16,s18,s20).eq.s18) isbest=2
  if(max(s16,s18,s20).eq.s20) isbest=3

  nsync=max(snrsync-1.0,0.0)
  f=ishort*df
  if(f.ge.fa .and. f.le.fb .and. nsync.eq.0 .and.         &
       short.gt.2.0) dfx=ishort*df-f0

  return
end subroutine synciscat
