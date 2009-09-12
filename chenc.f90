subroutine chenc(cmode,nbit,iu,gsym)

! Apply FEC and generate channel symbols

  character*5 cmode
  integer iu(3)
  integer iu6(13)
  integer*1 iu6a(96)
  integer gsym(63)
  character*96 line

  mm=6
  nq=64
  nn=63
  nfz=3
  kk=13
  if(nbit.eq.30) kk=5
  if(nbit.eq.48) kk=8
  call rs_init(mm,nq,nn,kk,nfz)                 !Initialize Karn codec
  call unpackbits(iu,3,32,iu6a)
  call packbits(iu6a,13,6,iu6)
  call rs_encode(iu6,gsym)                      !Encode 

  return
end subroutine chenc
