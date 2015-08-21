subroutine syncmsk(cdat,npts,cb,ldebug,ipk,jpk,rmax,metric,decoded)

! Find the Barker codes within a JTMSK ping.

  use packjt
  complex cdat(npts)                    !Analytic signal
  complex cb(66)                        !Complex waveform for Barker 11
  complex c0(6)
  complex c1(6)
  real r(60000)
  real symbol(231)
  real rdata(231)
  complex z,z0,z1,cfac
  integer*1 e1(198)
  integer*1 d8(13)
  integer*1 i1hash(4)
  integer*1 i1
  integer*4 i4Msg6BitWords(12)            !72-bit message as 6-bit words
  integer mettab(0:255,0:1)               !Metric table for BPSK modulation
  character*22 decoded
  character*72 c72
  logical ldebug,first
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

  decoded="                      "
  ipk=0
  jpk=0
  metric=0
  r=0.
  jz=npts-65
  do j=1,jz                               !Find the sync vectors
     z=0.
     ss=0.
     do i=1,66
        ss=ss + abs(cdat(j+i-1))          !Total power
        z=z + cdat(j+i-1)*conjg(cb(i))    !Signal matching Barker 11
     enddo
     r(j)=abs(z)/ss                       !Goodness-of-fit to Barker 11
  enddo

  jz=npts-1386
  rmax=0.
  do j=1,jz                               !Find best full-message sync
     r1=r(j) + r(j+456) + r(j+918)        ! 6*76 6*(76+77)
     r2=r(j) + r(j+462) + r(j+930)        ! 6*77 6*(77+78)
     r3=r(j) + r(j+468) + r(j+924)        ! 6*78 6*(78+76)
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
  enddo
  if(rmax.lt.2.0) go to 900

  z=0.
  do i=1,66                               !Find carrier phase offset
     z=z + cdat(jpk+i-1)*conjg(cb(i))
  enddo
  phi=atan2(aimag(z),real(z))
  cfac=cmplx(cos(phi),-sin(phi))
  cdat=cfac*cdat

  if(ldebug) then
     z=0.
     do i=1,66
        z=z + cdat(jpk+i-1)*conjg(cb(i))
        phi=atan2(aimag(z),real(z))
        write(74,3002) i/6.0,conjg(cb(i)),cdat(jpk+i-1),z,abs(z),phi
3002    format(9f8.3)
     enddo
  endif

  do k=1,231                                !Compute soft symbols
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
     if(ipk.eq.2) n=k+76
     if(ipk.eq.3) n=k+153
     if(n.gt.231) n=n-231
     symbol(n)=sym
     if(ldebug) then
        write(75,3301) k,sym,phi
3301    format(i3,2f8.3)
     endif
  enddo

!####################################################################
! Extract the information symbols by removing the sync vectors
  if(ipk.eq.1) then
     rdata(1:65)=symbol(12:76)
     rdata(66:131)=symbol(88:153)
     rdata(132:198)=symbol(165:231)
  else if(ipk.eq.2) then
     rdata(1:66)=symbol(12:77)
     rdata(67:133)=symbol(89:155)
     rdata(134:198)=symbol(167:231)
  else if(ipk.eq.3) then
     rdata(1:67)=symbol(12:78)
     rdata(68:132)=symbol(90:154)
     rdata(133:198)=symbol(166:231)
  endif

! Re-order the symbols and make them i*1
  j=0
  do i=1,99
     i4=128+rdata(i)
     if(i4.gt.255)  i4=255
     if(i4.lt.0) i4=0
     j=j+1
     e1(j)=i1
     i4=128+rdata(i+99)
     if(i4.gt.255)  i4=255
     if(i4.lt.0) i4=0
     j=j+1
     e1(j)=i1
  enddo

! Decode the message
  nb1=87
  call vit213(e1,nb1,mettab,d8,metric)

  ihash=nhash(d8,9,146)
  ihash=2*iand(ihash,32767)
  if(d8(10).eq.i1hash(2) .and. d8(11).eq.i1hash(1)) then
     write(c72,1012) d8(1:9)
1012 format(9b8.8)
     read(c72,1014) i4Msg6BitWords
1014 format(12b6.6)
     call unpackmsg(i4Msg6BitWords,decoded)      !Unpack to get msgsent
  endif

900 return
end subroutine syncmsk
