subroutine cencode(dat1,nbits,kk,nn,ntb,symbols,nsymbols,nstart,nend)

  integer*1 dat1(0:24)                 !User data, 8 bits per byte
  integer*1 symbols(0:2000)            !Encoded symbols, 1 bit per byte
  integer*1 i1
  equivalence (i1,i4)
  include 'vcom2.f90'
  data npar/                                        &
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, &
    1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, &
    1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, &
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, &
    1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, &
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, &
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, &
    1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, &
    1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, &
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, &
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, &
    1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, &
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, &
    1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, &
    1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, &
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0/

!  data npoly/O'0127757',O'0115143',O'0171665',O'0131351'/   !416
  data npoly/O'0126723', O'0152711',0,0/                     !216
!  data npoly/7,5,0,0/

  nbytes=(nbits+7)/8
  nsymbols=(nbits+kk)*nn
  nstate=nstart
  i4=0

  n=-1
  do k=0,nbytes-1
     do i=7,0,-1
        i1=dat1(k)
        nstate=nstate+nstate + iand(ishft(i4,-i),1)
        do j=0,nn-1
           n=n+1
           m=iand(nstate,npoly(j))
           m=ieor(m,ishft(m,-16))
           m=iand(ieor(m,ishft(m,-8)),255)
           symbols(n)=npar(m)
           if(n.eq.nbits*nn-1) go to 10
        enddo
     enddo
  enddo

10 if(ntb.eq.0) then
! Flush out with zero tail
     do i=0,kk-2
        nstate=ior(nstate+nstate,iand(ishft(nend,-i),1))
        do j=0,nn-1
           n=n+1
           m=iand(nstate,npoly(j))
           m=ieor(m,ishft(m,-16))
           m=iand(ieor(m,ishft(m,-8)),255)
           symbols(n)=npar(m)
        enddo
     enddo
  else
! Encode the whole string again, starting with encoder state as it is now.
     n=-1
     do k=0,nbytes-1
        do i=7,0,-1
           i1=dat1(k)
           nstate=nstate+nstate + iand(ishft(i4,-i),1)
           do j=0,nn-1
              n=n+1
              m=iand(nstate,npoly(j))
              m=ieor(m,ishft(m,-16))
              m=iand(ieor(m,ishft(m,-8)),255)
!              write(33,3001) n,symbols(n),npar(m),npar(m)-symbols(n)
!3001          format(4i5)
              symbols(n)=npar(m)
              if(n.eq.nbits*nn-1) go to 100
           enddo
        enddo
     enddo
  endif

100 nend=nstate
  return
end subroutine cencode
