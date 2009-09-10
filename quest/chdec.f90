subroutine chdec(cmode,nbit,gsym,iu)

! Decode channel symbols to recover source-encoded user message

  character*5 cmode
  integer gsym(63)
  integer iu(3)
  integer era(63)
  integer dat4(13)
  integer*1 dbits(96)

  nerase=0
  call rs_decode(gsym,era,nerase,dat4,ncount)
  dbits=0
  call unpackbits(dat4,13,6,dbits)
  call packbits(dbits,3,32,iu)

  return
end subroutine chdec

