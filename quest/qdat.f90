subroutine qdat(nsymd,krs,m0,kc,nc,dgen1,dgen3,nbits)

! Generate and encode user data

  include 'qparams.f90'
  integer   dgen1(NZ1)             !Generated data
  integer*1 d1(NZ1)
  integer*1 dgen3(NZ4)             !Encoded data
  integer*1 t1(NZ4)                !Encoded data
  integer*1 t1a(NZ4)               !Encoded data as 8-bit bytes
  integer t4(NZ4)
  integer*2 sym2(63)
  integer*1 symbols(NZ4)
  integer*1 symbols0
  common/tmpcom/symbols0(NZ4)
  data idum/-1/
  save

  ntones=2**m0
  do i=1,krs                                  !Generate random data
     dgen1(i)=ntones*ran1(idum)
  enddo

  t1=0
  call unpackbits(dgen1,krs,m0,t1)            !Unpack into bits
  nbits=m0*krs

  call packbits(t1,nbits,8,t4)                !Pack into 8-bit bytes
  nbytes=(nbits+7)/8
  do i=1,nbytes
     if(t4(i).lt.128) t1a(i)=t4(i)
     if(t4(i).ge.128) t1a(i)=t4(i)-256
  enddo
  if(kc.eq.32) then
     call encode232(t1a,nbytes,symbols)       !K=32 code
     nsymbols=(nbits+31)*2
     do i=1,218
        symbols0(i)=symbols(i)
     enddo
  else if(kc.eq.7 .and. nc.eq.2) then
     call enc207(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.9 .and. nc.eq.2) then
     call enc209(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.11 .and. nc.eq.2) then
     call enc211(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.13 .and. nc.eq.2) then
     call enc213(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.15 .and. nc.eq.2) then
     call enc215(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.16 .and. nc.eq.2) then
     call enc216(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.17 .and. nc.eq.2) then
     call enc217(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.18 .and. nc.eq.2) then
     call enc218(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.16 .and. nc.eq.3) then
     call enc316(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(kc.eq.16 .and. nc.eq.4) then
     call enc416(t1a,nbits,symbols,nsymbols,kc2,nc2)   !Short-K codes
  else if(nc.ge.10) then
     nfz=3
     if(kc.eq.5) then
        xlambda=10.
        maxe=2
        naddsynd=100
     else if(kc.eq.8) then
        xlambda=13.
        maxe=6
        naddsynd=150
     else
        xlambda=15.
        maxe=8
        naddsynd=200
     endif
     nqbits=8
     call asdinit(m0,ntones,nc,kc,nfz,xlambda,maxe,naddsynd,nqbits)

     d1(1:kc)=dgen1(1:kc)
     call rsencode(d1,sym2)
     do j=1,nc
        dgen3(j)=sym2(j)
     enddo
     go to 900
  else
     print*,'*** Unsupported code: K =',kc,', N =',nc,' ***'
     stop
  endif

  call packbits(symbols,nsymbols,m0,t4)
  do i=1,nsymbols
     if(t4(i).lt.128) dgen3(i)=t4(i)
     if(t4(i).ge.128) dgen3(i)=t4(i)-256
  enddo

900 return
end subroutine qdat
