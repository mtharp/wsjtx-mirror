      subroutine decode162(c2,npts,dtx,dfx,message,ncycles,metric,nerr)

C  Decode MEPT_JT data, assuming that DT and DF have already been determined.

      complex c2(npts)                        !Downsampled baseband data
      real s2(77,126)
      real s3(64,63)
      character*22 message
      character*12 callsign
      character*4 grid
      character*3 cdbm
      real*8 dt,df,phi,f0,dphi,twopi,phi1,dphi1
      complex*16 cz,cz1,c0,c1
      integer*1 i1,symbol(162)
      integer*1 data1(11)                   !Decoded data (8-bit bytes)
      integer   data4a(7)                   !Decoded data (8-bit bytes)
      integer   data4(12)                   !Decoded data (6-bit bytes)
      integer amp
      integer mettab(0:255,0:1)             !Metric table
      logical first
      integer*1 sym0
      common/tst99/ sym0(162)
      equivalence (i1,i4)
      data first/.true./
      integer npr3(162)
      data npr3/
     + 1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,
     + 0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,
     + 0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,
     + 1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,
     + 0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,
     + 0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,
     + 0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,
     + 0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,
     + 0,0/
      data mettab/
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   4,
     +   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,
     +   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,
     +   3,   3,   3,   3,   3,   3,   3,   3,   3,   2,
     +   2,   2,   2,   2,   1,   1,   1,   1,   0,   0,
     +  -1,  -1,  -1,  -2,  -2,  -3,  -4,  -4,  -5,  -6,
     +  -7,  -7,  -8,  -9, -10, -11, -12, -12, -13, -14,
     + -15, -16, -17, -17, -18, -19, -20, -21, -22, -22,
     + -23, -24, -25, -26, -26, -27, -28, -29, -30, -30,
     + -31, -32, -33, -33, -34, -35, -36, -36, -37, -38,
     + -38, -39, -40, -41, -41, -42, -43, -43, -44, -45,
     + -45, -46, -47, -47, -48, -49, -49, -50, -51, -51,
     + -52, -53, -53, -54, -54, -55, -56, -56, -57, -57,
     + -58, -59, -59, -60, -60, -61, -62, -62, -62, -63,
     + -64, -64, -65, -65, -66, -67, -67, -67, -68, -69,
     + -69, -70, -70, -71, -72, -72, -72, -72, -73, -74,
     + -75, -75, -75, -77, -76, -76, -78, -78, -80, -81,
     + -80, -79, -83, -82, -81, -82, -82, -83, -84, -84,
     + -84, -87, -86, -87, -88,-105, -94,-105, -88, -87,
     + -86, -87, -84, -84, -84, -83, -82, -82, -81, -82,
     + -83, -79, -80, -81, -80, -78, -78, -76, -76, -77,
     + -75, -75, -75, -74, -73, -72, -72, -72, -72, -71,
     + -70, -70, -69, -69, -68, -67, -67, -67, -66, -65,
     + -65, -64, -64, -63, -62, -62, -62, -61, -60, -60,
     + -59, -59, -58, -57, -57, -56, -56, -55, -54, -54,
     + -53, -53, -52, -51, -51, -50, -49, -49, -48, -47,
     + -47, -46, -45, -45, -44, -43, -43, -42, -41, -41,
     + -40, -39, -38, -38, -37, -36, -36, -35, -34, -33,
     + -33, -32, -31, -30, -30, -29, -28, -27, -26, -26,
     + -25, -24, -23, -22, -22, -21, -20, -19, -18, -17,
     + -17, -16, -15, -14, -13, -12, -12, -11, -10,  -9,
     +  -8,  -7,  -7,  -6,  -5,  -4,  -4,  -3,  -2,  -2,
     +  -1,  -1,  -1,   0,   0,   1,   1,   1,   1,   2,
     +   2,   2,   2,   2,   3,   3,   3,   3,   3,   3,
     +   3,   3,   3,   4,   4,   4,   4,   4,   4,   4,
     +   4,   4,   4,   4,   4,   4,   4,   4,   4,   4,
     +   4,   4,   4,   4,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5,   5,   5,   5,   5,   5,   5,   5,   5,
     +   5,   5/
      save

      rewind 41

      if(first) then
         twopi=8*atan(1.d0)
         dt=1.d0/375.d0                        !Sample interval
         df=375.d0/256.d0
         nsym=162
         amp=32                                !### ??? ###
         first=.false.
      endif

      istart=nint((dtx+2.0)/dt)              !Start index for synced FFTs
      if(istart.lt.0) istart=0

C  Should amp be adjusted according to signal strength?
C  Compute soft symbols using differential BPSK demodulation
      c0=0.
      k=istart
      fac=1.e-4
      phi=0.d0
      phi1=0.d0
      nspchip=256
      nchips=1
      fac2=0.001
      do j=1,nsym
         f0=dfx + (npr3(j)-1.5)*df
         f1=dfx + (2+npr3(j)-1.5)*df
         dphi=twopi*dt*f0
         dphi1=twopi*dt*f1
         sq0=0.
         sq1=0.
         do nc=1,nchips
            phi=0.d0
            phi1=0.d0
            c0=0.
            c1=0.
            do i=1,nspchip
               k=k+1
               phi=phi+dphi
               phi1=phi1+dphi1
               cz=dcmplx(cos(phi),-sin(phi))
               cz1=dcmplx(cos(phi1),-sin(phi1))
               if(k.le.npts) then
                  c0=c0 + c2(k)*cz                      !c2 was dat
                  c1=c1 + c2(k)*cz1                     !c2 was dat
               endif
            enddo
            sq0=sq0 + real(c0)**2 + aimag(c0)**2
            sq1=sq1 + real(c1)**2 + aimag(c1)**2
         enddo
         sq0=fac2*sq0
         sq1=fac2*sq1
         rsym=amp*(sq1-sq0)
         r=rsym+128.
         if(r.gt.255.0) r=255.0
         if(r.lt.0.0) r=0.0
         i4=nint(r)
         symbol(j)=i1
         i4a=i4
      enddo

      ndelta=100
      limit=100000
      nbits=50+31
      call inter_mept(symbol,-1)                      !Remove interleaving
      call fano232(symbol,nbits,mettab,ndelta,limit,
     +     data1,ncycles,metric,nerr)
      message='                      '
      cdbm='   '
      if(nerr.ge.0) then
         call unpack50(data1,n1,n2)
         if(n1+n2.eq.0) go to 900
         call unpackcall(n1,callsign)
         call unpackgrid(n2/128,grid)
         ndbm=iand(n2,127) - 64
         i1=index(callsign,' ')
         write(cdbm,'(i3)'),ndbm
         if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
         if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
         message=callsign(1:i1)//grid//' '//cdbm
      endif

C  Save symbol spectra for possible decoding of average?

 900  return
      end
