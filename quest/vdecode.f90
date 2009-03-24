subroutine vdecode(symbols,nbits,mettab,dat1,metric,startstate,endstate)

  parameter (LONGBITS=32)
  parameter (LOGLONGBITS=5)
  parameter (MAXNBITS=200)         !Max frame size (user bits)
  parameter (KMAX=16)
  parameter (NMAX=10)
  parameter (NZ=2**NMAX)
  parameter (NDMAX=2**(KMAX-LOGLONGBITS-1)*(MAXNBITS+KMAX-1))
  parameter (N2K=2**KMAX)
  parameter (N2KM1=2**(KMAX-1))

  integer*1 symbols(0:2000)        !Soft symbols
  integer nbits                    !Number of user information bits
  integer*1 dat1(0:24)             !Decoded output data, 8 bits per byte
  integer mettab(0:255,0:1)        !Metric table (RxSym,TxSym)
  integer startstate               !Encoder start state
  integer endstate                 !Encoder end state

  integer bitcnt
  integer sym
  integer mets(0:NZ-1)
  integer paths(0:NDMAX)
  integer syms(0:N2K)
  integer cmetric(0:N2KM1)
  integer nmetric(0:N2KM1)
  logical first
  integer b1,b2
  integer*1 i1

  integer kk                       !K, constraint length
  integer nn                       !N, code rate=1/N
  integer dd
  include 'vcom2.f90' 
  equivalence (i1,i4)
  data first/.true./
  save

  kk=16
  nn=2
  i4=0
  dd=2**max(0,kk-LOGLONGBITS-1)
! Initialize syms() on first time through
  if(first) then
     iz=2**kk - 1
     do i=0,iz
        sym=0
        do j=0,nn-1
           m=iand(i,npoly(j))
           m=ieor(m,ishft(m,-16))
           m=iand(ieor(m,ishft(m,-8)),255)
           sym=sym+sym + npar(m)
        enddo
        syms(i)=sym
     enddo
     first=.false.
  endif
  
  bitcnt=-(kk-1)
  paths=0

! Keep only lower K-1 bits of specified starting and ending states
  izm=2**(kk-1)-1
!  mask=-izm-1                             !??? as was ???
  mask=izm
  startstate=iand(startstate,mask)
  endstate=iand(endstate,mask)

! Initialize starting metrics
  cmetric(0:izm)=-999999
  cmetric(startstate)=0;

  ipp=0
  j0=0
  iz=2**(kk-1) - 1

  do nb=0,nbits+kk-2
! Read soft symbols and compute branch metrics
     do i=0,(2**nn)-1
        mets(i)=0
        do j=0,nn-1
           m=iand(ishft(i,-(nn-j-1)),1)
           i1=symbols(j0+j)
           mets(i)=mets(i) + mettab(i4,m)
        enddo
     enddo
     j0=j0+nn

! Run the add-compare-select operations
     mask=1
     n2kkm2=2**(kk-2)
     j=-1
     do i=0,iz,2
        j=j+1
        b1=mets(syms(i))
        m0=cmetric(j) + b1
        nmetric(i)=m0
        b2=mets(syms(i+1))
        b1=b1-b2
        m1=cmetric(j + n2kkm2) + b2
        if(m1.gt.m0) then
           nmetric(i)=m1
           paths(ipp)=ior(paths(ipp),mask)
        endif

        m0=m0-b1
        nmetric(i+1)=m0
        m1=m1+b1
        if(m1.gt.m0) then
           nmetric(i+1)=m1
           paths(ipp)=ior(paths(ipp),mask+mask)
        endif

        mask=ishft(mask,2)
        if(mask.eq.0) then
           mask=1
           ipp=ipp+1
        endif
     enddo
     if(mask.ne.1) ipp=ipp+1

     bitcnt=bitcnt+1
     if(bitcnt.eq.nbits) then
        metric=nmetric(endstate)
        go to 10
     endif

     cmetric(0:izm)=nmetric(0:izm)

  enddo

! Chain back from terminal state to produce decoded data
10  dat1=0
  do i=nbits-1,0,-1
     ipp=ipp-dd
     m0=ishft(endstate,-LOGLONGBITS)
     m1=2**(iand(endstate,LONGBITS-1))
     if(iand(paths(ipp+m0),m1).ne.0) then
        endstate=ior(endstate,2**(kk-1))
        i1=dat1(ishft(i,-3))
        dat1(ishft(i,-3))=ior(i4,ishft(128,-iand(i,7)))
     endif
     endstate=ishft(endstate,-1)
  enddo

  return
end subroutine vdecode
