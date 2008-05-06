      subroutine genmept(message,ntxdf,snrdb,nreply,
     +      nsectx,iwave)

C  Encode an MEPT_JT message and generate the corresponding wavefile.

      character*12 call1,call2
      character*4 grid,grid2
      parameter (NMAX=120*12000)     !Max length of wave file
      character*22 message           !Message to be generated
!      character*22 msg2,msg0
      integer*2 iwave(NMAX)          !Generated wave file

      parameter (MAXSYM=176)
      integer*1 symbol(MAXSYM)
      integer*1 data0(11),i1
      integer npr3(162)
      real pr3(162)
      logical first,lbad1,lbad2
      real*8 t,dt,phi,f,f0,dfgen,dphi,pi,twopi,tsymbol
      character*22 msgsent           !Message sent

      integer ndxkm(0:23)
      character*4 dxgrid(0:23)
      common/acom2/ ndxkm,dxgrid

      equivalence(i1,i4)
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

      data first/.true./,idum/0/,ihrtx0/99/
      save

      nsym=162                               !Symbols per transmission
      if(first) then
         do i=1,nsym
            pr3(i)=2*npr3(i)-1
         enddo
         pi=4.d0*atan(1.d0)
         twopi=2.d0*pi
         first=.false.
      endif

      call wqencode(message,ntype,data0)
!      call packcall(call1,n1,lbad1)
!      call packgrid(grid,ng,lbad2)

      ihrtx=nsectx/3600
      if(ihrtx.lt.ihrtx0 .and. ihrtx0.ne.99 .and. nreply.eq.1) then
         i=ihrtx-1
         if(i.lt.0) i=i+24
         call packgrid(dxgrid(i),ng,lbad2)
         ndbm=0
         ihrtx0=ihrtx
         print*,'Sending reply message:',dxgrid(i),' DE ',call1
      endif

!      n2=128*ng + ndbm + 64
!      call pack50(n1,n2,data0)             !Pack 8 bits per byte, add tail
      nbytes=(50+31+7)/8
      call encode232(data0,nbytes,symbol,MAXSYM)  !Convolutional encoding
      call inter_mept(symbol,1)                   !Apply interleaving
      do i=1,162
         i4=0
         i1=symbol(i)
      enddo

!      call unpackcall(n1,call2)
!      call unpackgrid(n2/128,grid2)
!      ndbm2=iand(n2,127) - 64
!      if(lbad1 .or. lbad2 .or. (call1.ne.call2) .or. 
!     +   (grid.ne.grid2) .or. (ndbm.ne.ndbm2)) then
!         print*,'Error in structure of Tx message, cannot transmit'
!         go to 999
!      endif

!      call wqdecode(data0,msg2,ntype2,msg0)
!      print*,message,msg2,ntype2

C  Set up necessary constants
      tsymbol=8192.d0/12000.d0
      dt=1.d0/12000.d0
      f0=1500 + ntxdf
      dfgen=12000.d0/8192.d0                     !1.4649 Hz
      nsigs=1
      if(snrdb.eq.10.0) nsigs=10
      do isig=1,nsigs
         if(nsigs.eq.1) snr=10.0**(0.05*(snrdb-1))   !Bandwidth correction?
         fac=3000.0
         if(snr.gt.1.0) fac=3000.0/snr
         if(nsigs.eq.10) then
            snr=10.0**(0.05*(-20-isig-1))
            f0=1390 + 20*isig
         endif
         t=-2.d0 - 0.1*(isig-1)
         phi=0.d0
         j0=0

         do i=1,NMAX
            t=t+dt
            j=int(t/tsymbol) + 1                          !Symbol number
            sig=0.
            if(j.ge.1 .and. j.le.162) then
               if(j.ne.j0) then
                  f=f0 + dfgen*(npr3(j)+2*symbol(j)-1.5)
                  j0=j
                  dphi=twopi*dt*f
               endif
               sig=0.9999
            endif
            phi=phi+dphi
            if(snrdb.gt.50.0) then
               n=32767.0*sin(phi)           !Normal transmission, signal only
            else
               if(isig.eq.1) then
                  n=fac*(gran(idum) + sig*snr*sin(phi))
               else
                  n=iwave(i) + fac*sig*snr*sin(phi)
               endif
               if(n.gt.32767) n=32767
               if(n.lt.-32767) n=-32767
            endif
            iwave(i)=n
 10         continue
         enddo
      enddo

 100  continue

 999  return
      end

