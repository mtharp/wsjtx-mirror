subroutine vit416(symbols,nbits,mettab,ddec,metric)

! Viterbi decoder for K=16, r=1/4 convolutional code.
! Translated from the C routine written by Phil Karn, KA9Q.

  parameter (LONGBITS=32,LOGLONGBITS=5)
  parameter (NN=4,KK=16,NDD=2**(KK-LOGLONGBITS-1))
  parameter (MAXNBITS=80)             !Max frame size, user information bits
  parameter (N2K=2**KK)
  parameter (N2KM1=2**(KK-1))
  parameter (N2KM2=2**(KK-2))
  parameter (N2N=2**NN)
  parameter (MAXSYM=NN*(MAXNBITS+KK-1))
  integer*1 symbols(0:MAXSYM-1)
  integer*1 ddec(0:(MAXNBITS+7)/8-1)
  integer*1 i1,i128
  integer mettab(0:255,0:1)
  integer paths(0:NDD*(MAXNBITS+KK-1)-1)
  integer cmetric(0:N2KM1-1)
  integer nmetric(0:N2KM1-1)
  integer mets(0:N2N-1)
  integer syms(0:N2K-1)
  integer bitcnt,sym,b1,b2
  integer startstate,endstate
  integer polys(0:3)
  logical first
  data first/.true./
  data polys/O'0127757',O'0115143',O'0171665',O'0131351'/
  include 'partab.f90'
  save first,syms
  
  startstate=0
  endstate=0
  bitcnt=-(KK-1)
  mets=ishft(1,NN)
  paths=0
  if(first) then
     do i=0,N2K-1
        sym=0
        do j=0,3
           n=iand(i,polys(j))
           n=ieor(n,ishft(n,-16))
           sym=sym+sym+partab(iand(ieor(n,ishft(n,-8)),255))
        enddo
        syms(i)=sym
     enddo
     first=.false.
  endif

!  startstate=iand(startstate,N2KM1-1)
!  endstate=iand(endstate,N2KM1-1)
  cmetric=-999999
  cmetric(startstate)=0

  j0=0
  jpp=0
  ipp=0
10 do i=0,N2N-1
     mets(i)=0
     do j=0,NN-1
        k=symbols(j+j0)
        if(k.lt.0) k=k+256
        mets(i)=mets(i) + mettab(k,iand(ishft(i,1+j-NN),1))
     enddo
  enddo

  j0=j0+NN
  mask=1
  do i=0,N2KM1-1,2
     b1=mets(syms(i))
     m0=cmetric(i/2) + b1
     nmetric(i)=m0
     b2=mets(syms(i+1))
     b1=b1-b2
     m1=cmetric(i/2 + N2KM2) + b2

!     write(61,3001) i,b1,b2
!3001 format(3i10)

     if(m1.gt.m0) then
        nmetric(i)=m1
        paths(jpp)=ior(paths(jpp),mask)
     endif

     m0=m0-b1
     nmetric(i+1)=m0
     m1=m1+b1

     if(m1.gt.m0) then
        nmetric(i+1)=m1
        paths(jpp)=ior(paths(jpp),mask+mask)
     endif

     mask=ishft(mask,2)
     if(mask.eq.0) then
        mask=1
        jpp=jpp+1
        ipp=ipp+1
     endif
  enddo

  if(mask.ne.1) then
     jpp=jpp+1
     ipp=ipp+1
  endif

  bitcnt=bitcnt+1
  if(bitcnt.eq.nbits) then
     metric=nmetric(endstate)
     go to 100
  endif
  cmetric=nmetric
  go to 10

! Chain back from terminal state to produce decoded data

100 ddec=0
  i128=-128
  do i=nbits-1,0,-1
     jpp=jpp-NDD
     ipp=ipp-NDD
     m0=ishft(endstate,-LOGLONGBITS)
     m1=ishft(1,iand(endstate,LONGBITS-1))
     if(iand(paths(jpp+m0),m1).ne.0) then
        endstate=ior(endstate,N2KM1)
        i1=ishft(i128,-iand(i,7))
        k=i/8
        ddec(k)=ior(ddec(k),i1)
     endif
     endstate=ishft(endstate,-1)
  enddo
end subroutine vit416
