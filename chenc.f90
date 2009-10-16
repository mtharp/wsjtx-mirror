subroutine chenc(cmode,nbit,iu,gsym)

! Apply FEC and generate channel symbols

  parameter (MAXSYM=380)
  character*5 cmode
  integer iu(3)
  integer iu6(13)
  integer*1 iu6a(96)
  integer*1 gsym1(MAXSYM)
  integer*1 dat1(10)
  integer*1 i1a,i1b,i1c,i1d
  integer gsym(MAXSYM)
  integer gsym2(MAXSYM)
  integer igray1(0:7)
!  data igray0/0,1,3,2,7,6,4,5/    !Use this to remove the gray code
  data igray1/0,1,3,2,6,7,5,4/
  common/acom1/i1a,i1b,i1c,i1d
  equivalence (i4,i1a)

  if(cmode.eq.'JTMS' .or. cmode.eq.'JT8') then
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

     if(cmode.eq.'JTMS') then
        call enc213(dat1,nbit,gsym1,nsym,kc2,nc2)
        nhdata=nbit+12
        do i=1,nhdata                          !Interleave the data
           gsym(i)=gsym1(2*i-1)
           gsym(nhdata+i)=gsym1(2*i)
        enddo

     else if(cmode.eq.'JT8') then
        call enc416(dat1,nbit,gsym1,nsym,kc2,nc2)
        do i1=0,30                    !Interleave using a 12x31 logical block
           do i2=0,11
              i=31*i2+i1
              j=12*i1+i2
              gsym2(i+1)=gsym1(j+1)    !Exchange i and j to remove interleaving
           enddo
        enddo

! Insert bits into 3-bit data symbols and apply gray code.
        do i=1,124
           n=4*gsym2(3*i-2) + 2*gsym2(3*i-1) + gsym2(3*i)
           gsym(i)=igray1(n)              !Use igray0() to remove the gray code
        enddo
     endif

  else if(cmode.eq.'JT64' .or. cmode.eq.'ISCAT') then
     kk=13
     if(nbit.eq.30) kk=5
     if(nbit.eq.48) kk=8
     call unpackbits(iu,3,32,iu6a)
     iu6a(nbit+1:)=0
     call packbits(iu6a,kk,6,iu6)
     call krsencode(iu6,kk,gsym)                      !Encode 
  endif

  return
end subroutine chenc
