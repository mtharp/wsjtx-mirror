subroutine enc416(dat1,nbits,symbols,nsymbols,kk0,nn0)

! Convolutional encoder for a K=16, r=1/4 code.

  parameter (KK=16)                  !Constraint length, K = 16
  parameter (NN=4)                   !Rate = r = 1/N = 1/4
  parameter (MAXNBITS=80)            !Max number of information bits in frame
  parameter (MAXSYM=NN*(MAXNBITS+KK-1)) !Max number of one-bit channel symbols
  integer*1 dat1(0:(MAXNBITS+7)/8-1) !User information, 8 bits per byte
  integer nbits                      !Number of user information bits
  integer*1 symbols(0:MAXSYM-1)      !Encoded one-bit symbols
  integer nsymbols                   !Number of encoded one-bit symbols
  integer*1 i1
  integer startstate,endstate,encstate !Encoder state variables
  integer polys(0:3)                 !Generator polynomials
  data polys/O'0127757',O'0115143',O'0171665',O'0131351'/
  include 'partab.f90'               !Parity table

  startstate=0
  endstate=0
  encstate=startstate
  nbytes=(nbits+7)/8           !Always encode a multiple of 8 information bits
  i1=1
  n=-1

! Do the encoding
  do k=0,nbytes-1
     do i=7,0,-1
        encstate=encstate + encstate + iand(ishft(dat1(k),-i),i1)
        do j=0,NN-1
           n=n+1
           m=iand(encstate,polys(j))
           m=ieor(m,ishft(m,-16))
           symbols(n)=partab(iand(ieor(m,ishft(m,-8)),255))
        enddo
     enddo
  enddo

! Flush out with zero tail
  do i=0,KK-2
     encstate=ior(ishft(encstate,1),iand(ishft(endstate,-i),1))
     do j=0,NN-1
        n=n+1
        m=iand(encstate,polys(j))
        m=ieor(m,ishft(m,-16))
        symbols(n)=partab(iand(ieor(m,ishft(m,-8)),255))
     enddo
  enddo

  nsymbols=(nbits+KK-1)*NN
  kk0=KK
  nn0=NN

  return
end subroutine enc416
