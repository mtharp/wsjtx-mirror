subroutine chenc(cmode,nbit,iu,gsym)

! Apply FEC and generate channel symbols

  character*5 cmode
  integer iu(3)
  integer iu6(13)
  integer*1 iu6a(96)
  integer*1 gsym1(180)
  integer*1 dat1(90)
  integer*1 i1a,i1b,i1c,i1d
  integer gsym(180)
  character*96 line
  common/acom1/i1a,i1b,i1c,i1d
  equivalence (i4,i1a)

  if(cmode.eq.'JTMS') then
     i4=iu(1)
     dat1(1)=i1d
     dat1(2)=i1c
     dat1(3)=i1b
     dat1(4)=i1a

     i4=iu(2)
     dat1(5)=i1d
     dat1(6)=i1c
     dat1(7)=i1b
     dat1(8)=i1a

     i4=iu(3)
     dat1(9)=i1d
     dat1(10)=i1c

     dat1(11:)=0
     call enc213(dat1,nbit,gsym1,nsym,kc2,nc2)
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
