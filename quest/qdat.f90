subroutine qdat(nsymd,krs,m0,kc,nc,dgen1,dgen3,nbits)

! Generate and encode user data

  include 'qparams.f90'
  integer   dgen1(NZ1)             !Generated data
  integer*1 dgen3(NZ4)             !Convolutionally encoded data
  integer*1 t1(NZ4)                !Encoded data
  integer*1 t1a(NZ4)               !Encoded data as 8-bit bytes
  integer t4(NZ4)
  integer*1 symbols(NZ4)
  integer*1 symbols0
  common/tmpcom/symbols0(NZ4)
  data idum/-1/
  save

  ntones=2**m0
  do i=1,krs
     dgen1(i)=ntones*ran1(idum)         
  enddo

  t1=0
  call unpackbits(dgen1,krs,m0,t1)             !Unpack into bits
  nbits=m0*krs

!### For tail-biting
!  t1(nbits+1:2*nbits)=t1(1:nbits)
!  nbits=2*nbits
!###

  call packbits(t1,nbits,8,t4)                !Pack into 8-bit bytes
  nbytes=(nbits+7)/8
  do i=1,nbytes
     if(t4(i).lt.128) t1a(i)=t4(i)
     if(t4(i).ge.128) t1a(i)=t4(i)-256
  enddo
  if(kc.eq.32 .and. nc.eq.32) then
     call encode232(t1a,nbytes,symbols)      !K=32 code
     nsymbols=(nbits+31)*2
     do i=1,218
        symbols0(i)=symbols(i)
     enddo
  else
     if(kc.eq.16 .and. nc.eq.2) then
        call enc216(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
     else if(kc.eq.18 .and. nc.eq.2) then
        call enc218(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
     else if(kc.eq.16 .and. nc.eq.3) then
        call enc316(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
     else if(kc.eq.16 .and. nc.eq.4) then
        call enc416(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
     else if(kc.eq.18 .and. nc.eq.4) then
        call enc418(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
     endif

     if(kc2.ne.kc .or. nc2.ne.nc) then
        print*,'*** Re-compile viterbi.c with K =',kc,', N =',nc,' ***'
        stop
     endif
  endif

!###
!  nbits=nbits/2
!  nsymbols=nc*nbits
!  symbols(1:nsymbols)=symbols(nsymbols+1:2*nsymbols)
!###

!  do i=1,nsymbols
!     write(16,3002) i,t1(i),symbols(i)
!3002 format(3i5)
!  enddo

  call packbits(symbols,nsymbols,m0,t4)
  do i=1,nsymbols
     if(t4(i).lt.128) dgen3(i)=t4(i)
     if(t4(i).ge.128) dgen3(i)=t4(i)-256
  enddo

  return
end subroutine qdat
