subroutine chenc(cmode,nbit,iu,gsym)

! Apply FEC and generate channel symbols

  character*5 cmode
  integer iu(3)
  integer iu6(13)
  integer*1 iu6a(96)
  integer*1 gsym1(180)
  integer gsym(180)
  character*96 line

  if(cmode.eq.'JTMS') then
     call enc213(iu,nbit,gsym1,nsym,kc2,nc2)
     do i=1,nsym
        gsym(i)=gsym1(i)
     enddo
  else
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
  endif

  return
end subroutine chenc
