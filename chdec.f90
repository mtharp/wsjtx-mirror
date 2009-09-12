subroutine chdec(cmode,nbit,gsym,iu)

! Decode channel symbols to recover source-encoded user message

  character*5 cmode
  integer gsym(180)
  integer iu(3)
  integer era(63)
  integer dat4(13)
  integer*1 dbits(96)
  integer*1 symbols(180)
  integer*1 ddec(78)
  integer mettab(0:255,0:1)
  logical first
  data first/.true./
  save first

  if(cmode.eq.'JTMS') then

     if(first) then
! Get the metric table
        bias=0.0                        !Metric bias: viterbi=0, seq=rate
        scale=10                        !Optimize?
        open(19,file='met2.21',status='old')

        do i=0,255
           read(19,*) xjunk,d0,d1
           mettab(i,0)=nint(scale*(d0-bias))
           mettab(i,1)=nint(scale*(d1-bias))    !### Check range, etc.  ###
        enddo
        first=.false.
     endif

     nsym=2*(nbit+12)
     do i=1,nsym
        n=127
        if(gsym(i).eq.1) n=-127
        symbols(i)=n
     enddo
     call vit213(symbols,nbit,mettab,ddec,metric)
     print*,'C',ddec
  else
     nerase=0
     call rs_decode(gsym,era,nerase,dat4,ncount)
     dbits=0
     call unpackbits(dat4,13,6,dbits)
     call packbits(dbits,3,32,iu)
  endif

  return
end subroutine chdec

