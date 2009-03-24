program tstfano

  include 'qparams.f90'
  integer   dgen1(NZ1)             !Generated data
  integer*1 t1(NZ4)             !Encoded data as 8-bit bytes
  integer t4(NZ4)
  integer mettab(0:255,0:1)
  integer*1 symbols(NZ4)
  integer*1 symbols0
  integer*1 ddec (NSZ)
  common/tmpcom/symbols0(NZ4)
  data idum/-1/
  save

! Get the metric table
  bias=0.5                        !Metric bias: viterbi=0, seq=rate
  scale=10                        !Optimize?
  open(19,file='met64.21',status='old')
  do i=0,255
     read(19,*) xjunk,d0,d1
     mettab(i,0)=nint(scale*(d0-bias))
     mettab(i,1)=nint(scale*(d1-bias))    !### Check range, etc.  ###
  enddo


  m0=6
  ntones=2**m0
  krs=13
  do i=1,krs
     dgen1(i)=ntones*ran1(idum)         
  enddo
  call unpackbits(dgen1,krs,m0,t1)             !Unpack into bits
  nbits=m0*krs
  nb8=(nbits+31+7)/8
  nb8=8*nb8
  do i=nbits+1,nb8
     t1(i)=0
  enddo
  call packbits(t1,nbits,8,t4)                !Pack into 8-bit bytes
  nbytes=(nbits+7)/8
  do i=1,nbytes
     if(t4(i).lt.128) t1(i)=t4(i)
     if(t4(i).ge.128) t1(i)=t4(i)-256
  enddo
  call encode232(t1,nbytes,symbols)      !K=32 code
  nsymbols=(nbits+31)*2
  do i=1,nsymbols
     symbols0(i)=symbols(i)
  enddo
!  call packbits(symbols,nsymbols,m0,t4)
!  do i=1,nsymbols
!     if(t4(i).lt.128) dgen3(i)=t4(i)
!     if(t4(i).ge.128) dgen3(i)=t4(i)-256
!  enddo

  do i=1,nsymbols
     if(symbols0(i).eq.0) symbols(i)=10
     if(symbols0(i).eq.1) symbols(i)=-10
  enddo

  nbits=78+31
  ndelta=50
  limit=1000
  call fano232(symbols,nbits,mettab,ndelta,limit,ddec,ncycles,metric,ierr)
!  do i=1,krs
  print*,nbits,nsymbols,ncycles/nbits,metric,ierr

end program tstfano
