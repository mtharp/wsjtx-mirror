subroutine syncmsk(cdat,npts,cb,ldebug,jpk,ipk,idf,rmax1,rmax,metric,decoded)

! Find the Barker codes within a JTMSK ping, then decode.

  use packjt
  complex cdat(npts)                    !Analytic signal
!  complex cdat2(24000)
  complex cb(66)                        !Complex waveform for Barker 11
  complex c0(6)
  complex c1(6)
  complex c(0:1404-1)
  complex c2(0:1404-1)
  complex cb3(1:1404,3)
  real r(60000)
  real symbol(234)
  real rdata(198)
  real rd2(198)
  complex z,z0,z1,cfac
  integer*1 e1(198)
  integer*1 e0(198)
  integer*1 d8(13)
  integer*1 i1hash(4)
  integer*1 i1
  integer ib(234)
  integer*4 i4Msg6BitWords(12)            !72-bit message as 6-bit words
  integer mettab(0:255,0:1)               !Metric table for BPSK modulation
  integer ipksave(1000)
  integer jpksave(1000)
  integer indx(1000)
  real rsave(1000)
  character*22 decoded
  character*72 c72
  logical ldebug,first
  integer*8 count0,count1,clkfreq,count2
  common/mskcom/tmskdf,tsync,tsoft,tvit,ttotal
  equivalence (i1,i4)
  equivalence (ihash,i1hash)
  data first/.true./
  save first,mettab,c0,c1

  if(first) then
! Get the metric table
     open(10,file='bpskmetrics.dat',status='old')
     bias=0.0
     scale=20.0
     do i=0,255
        read(10,*) xjunk,x0,x1
        mettab(i,0)=nint(scale*(x0-bias))
        mettab(i,1)=nint(scale*(x1-bias))
     enddo
     close(10)
     c0=cb(19:24)
     c1=cb(1:6)
     first=.false.
  endif
  nfft=1404

  open(10,file='JTMSKcode.out',status='unknown')
  do i=1,234
     read(10,*) junk,ib(i)
  enddo
  close(10)

  call system_clock(count0,clkfreq)
  decoded="                      "
  ipk=0
  jpk=0
  metric=0

  r=0.
  rmax1=0.
  jz=npts-65
  do j=1,jz                               !Find the Barker-11 sync vectors
     z=0.
     ss=0.
     do i=1,66
        ss=ss + abs(cdat(j+i-1))          !Total power
        z=z + cdat(j+i-1)*conjg(cb(i))    !Signal matching Barker 11
     enddo
     r(j)=abs(z)/ss                       !Goodness-of-fit to Barker 11
     rmax1=max(rmax1,r(j))
     if(ldebug) write(76,3001) j,r(j)
3001 format(i6,f12.3)
  enddo
  call system_clock(count2,clkfreq)

  jz=npts-nfft
  rmax=0.
  n1=35
  n2=69
  n3=94
  k=0
  do j=1,jz                               !Find best full-message sync
     r1=r(j) + r(j+282) + r(j+768)        ! 6*(12+n1) 6*(24+n1+n2)
     r2=r(j) + r(j+486) + r(j+1122)       ! 6*(12+n2) 6*(24+n2+n3)
     r3=r(j) + r(j+636) + r(j+918)        ! 6*(12+n3) 6*(24+n3+n1)
     if(r1.gt.rmax) then
        rmax=r1
        jpk=j
        ipk=1
     endif
     if(r2.gt.rmax) then
        rmax=r2
        jpk=j
        ipk=2
     endif
     if(r3.gt.rmax) then
        rmax=r3
        jpk=j
        ipk=3
     endif
     if(ldebug) then
        write(77,3003) j,r1,r2,r3,max(r1,r2,r3)
3003    format(i6,4f12.3)
     endif
     rrmax=max(r1,r2,r3)
     if(rrmax.gt.2.0) then
        k=k+1
        if(r1.eq.rrmax) ipksave(k)=1
        if(r2.eq.rrmax) ipksave(k)=2
        if(r3.eq.rrmax) ipksave(k)=3
        jpksave(k)=j
        rsave(k)=rrmax
     endif
  enddo
  kmax=k
  call system_clock(count1,clkfreq)
  tsync=tsync + (count1-count0)/float(clkfreq)
!  print*,(count2-count0)/float(clkfreq),(count1-count2)/float(clkfreq),tsync

  call indexx(rsave,kmax,indx)
  do kk=1,kmax
     k=indx(kmax+1-kk)
     ipk=ipksave(k)
     jpk=jpksave(k)
     rmax=rsave(k)
!     print*,'A',ipk,jpk,rmax,npts

     n1=35
     n2=69
     n3=94
!     r1=r(j) + r(j+282) + r(j+768)        ! 6*(12+n1) 6*(24+n1+n2)
!     r2=r(j) + r(j+486) + r(j+1122)       ! 6*(12+n2) 6*(24+n2+n3)
!     r3=r(j) + r(j+636) + r(j+918)        ! 6*(12+n3) 6*(24+n3+n1)
     cb3=0.
     cb3(1:66,1)=cb
     cb3(283:348,1)=cb
     cb3(769:834,1)=cb

     cb3(1:66,2)=cb
     cb3(487:552,2)=cb
     cb3(1123:1188,2)=cb

     cb3(1:66,3)=cb
     cb3(637:702,3)=cb
     cb3(919:984,3)=cb

     c=conjg(cb3(1:1404,ipk))*cdat(jpk:jpk+nfft-1)
     smax=0.
     dfx=0.
     idfbest=0
     do idf=-100,100,1
        twk=idf
        call tweak1(c,1404,-twk,c2)
        z=sum(c2)
        if(abs(z).gt.smax) then
           dfx=twk
           smax=abs(z)
           phi=atan2(aimag(z),real(z))            !Carrier phase offset
           idfbest=idf
        endif
        write(73,3005) idf,abs(z)
3005    format(i5,f12.3)
     enddo
     idf=idfbest
!  print*,'B',dfx,smax,phi

     call tweak1(cdat,npts,-dfx,cdat)
!     phi=atan2(aimag(z),real(z))
     cfac=cmplx(cos(phi),-sin(phi))
     cdat=cfac*cdat

!  call four2a(c,nfft,1,-1,1)                  !c2c FFT
!  if(ldebug) then
!     df=12000.0/nfft
!     do i=0,nfft-1
!        sq=real(c(i))**2 + aimag(c(i))**2
!        f=i*df
!        if(i.gt.nfft/2) f=f-12000.0
!        write(72,3004) f,sq
!3004    format(f12.3,e12.3)
!     enddo
!  endif


!     idf=itry/2
!     if(mod(itry,2).eq.0) idf=-idf
!     idf=idf-7
!     twk=idf*0.5 + 6.0
!     call tweak1(cdat2,npts,twk,cdat)
!     z=0.
!     do i=1,66                               !Find carrier phase offset
!        z=z + cdat(jpk+i-1)*conjg(cb(i))
!     enddo


     cdat=-cdat
     if(ldebug) then
        z=0.
        do i=1,66
           z=z + cdat(jpk+i-1)*conjg(cb(i))
           phi=atan2(aimag(z),real(z))
           write(74,3002) i/6.0,conjg(cb(i)),cdat(jpk+i-1),z,abs(z),phi
3002       format(9f8.3)
        enddo
     endif

!$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
     nerr=0
     do k=1,234                                !Compute soft symbols
        z0=0.
        z1=0.
        j=jpk+6*(k-1)
        do i=1,6
           z0=z0 + cdat(j+i-1)*conjg(c0(i))    !Signal matching 0
           z1=z1 + cdat(j+i-1)*conjg(c1(i))    !Signal matching 1
        enddo
        sym=abs(real(z1))-abs(real(z0))
        if(sym.lt.0.0) phi=atan2(aimag(z0),real(z0))
        if(sym.ge.0.0) phi=atan2(aimag(z1),real(z1))
        n=k
        if(ipk.eq.2) n=k+47
        if(ipk.eq.3) n=k+128
        if(n.gt.234) n=n-234
        ibit=0
        if(sym.ge.0) ibit=1
        if(ibit.ne.ib(n)) nerr=nerr+1
        symbol(n)=sym
!        symbol(n)=2*ib(n)-1
        if(ldebug) then
           write(75,3301) k,n,symbol(n),phi,ibit,ib(n),-abs(ibit-ib(n))
3301       format(i3,i5,2f8.3,3i5)
        endif
     enddo
!     print*,'C  nerr  (of 234):',nerr

!####################################################################
! Extract the information symbols by removing the sync vectors
!     if(ipk.eq.1) then
!        rdata(1:35)=symbol(12:46)
!        rdata(36:104)=symbol(59:127)
!        rdata(105:198)=symbol(140:233)
!     else if(ipk.eq.2) then
!        rdata(1:35)=symbol(12:80)
!        rdata(36:104)=symbol(93:186)
!        rdata(105:198)=symbol(199:233)
!     else if(ipk.eq.3) then
        rdata(1:35)=symbol(12:46)
        rdata(36:104)=symbol(59:127)
        rdata(105:198)=symbol(140:233)
!     endif

! Re-order the symbols and make them i*1
     nerr2=0
     j=0
     do i=1,99
        i4=128+rdata(i)
        if(i4.gt.255)  i4=255
        if(i4.lt.0) i4=0
        j=j+1
        e1(j)=i1
        rd2(j)=rdata(i)
        i4=128+rdata(i+99)
        if(i4.gt.255)  i4=255
        if(i4.lt.0) i4=0
        j=j+1
        e1(j)=i1
        rd2(j)=rdata(i+99)
     enddo
     call system_clock(count0,clkfreq)
     tsoft=tsoft + (count0-count1)/float(clkfreq)

     rewind 41
     do i=1,198
        read(41,*) junk,e0(i)
        n=0
        if(e1(i).lt.0) n=1
        if(n.ne.e0(i)) nerr2=nerr2+1
        write(42,4001) i,e0(i),n,n-e0(i),rd2(i)
4001    format(4i6,f7.1)
     enddo
!     print*,'D  nerr2 (of 198):',nerr2
!$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

! Decode the message
     nb1=87
     call vit213(e1,nb1,mettab,d8,metric)
     call system_clock(count1,clkfreq)
     tvit=tvit + (count1-count0)/float(clkfreq)
     ihash=nhash(d8,9,146)
     ihash=2*iand(ihash,32767)
     decoded='                      '
     if(d8(10).eq.i1hash(2) .and. d8(11).eq.i1hash(1)) then
        write(c72,1012) d8(1:9)
1012    format(9b8.8)
        read(c72,1014) i4Msg6BitWords
1014    format(12b6.6)
        call unpackmsg(i4Msg6BitWords,decoded)      !Unpack to get msgsent
!        exit
     endif
!     write(*,6001) kk,ipk,jpk,rmax,nerr,nerr2,decoded
     write(91,6001) kk,ipk,jpk,rmax,nerr,nerr2,decoded
6001 format(3i6,f7.2,2i6,2x,a22)
     if(decoded.ne.'                      ') exit
  enddo

  return
end subroutine syncmsk
