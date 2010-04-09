subroutine decodems(nbit,gsym,metric,iu)

! Decode soft channel symbols to recover source-encoded user message

  integer gsym(372)
  integer gsym2(372)
  integer iu(3)
  integer era(63)
  integer dat4(13)
  integer*1 dbits(96)
  integer*1 symbols(372)
  integer*1 ddec(10)
  integer mettab(0:255,0:1)
  logical first
  data first/.true./
  save first,mettab

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

  nhdata=nbit+12
  nsym=2*nhdata                          !Number of binary symbols
  gsym2(1:2*nhdata)=gsym(1:2*nhdata)
  do i=1,nhdata                          !Remove the interleaving
     gsym(2*i-1)=gsym2(i)
     gsym(2*i)=gsym2(nhdata+i)
  enddo

  do i=1,nsym
     n=gsym(i)
     if(gsym(i).lt.-127) n=-127
     if(gsym(i).gt. 127) n=127
     symbols(i)=n
  enddo

  call vit213(symbols,nbit,mettab,ddec,metric)
  print*,metric,ddec

  iz=(nbit+7)/8
  ddec(iz+1:)=0
  n1=ddec(1)
  n2=ddec(2)
  n3=ddec(3)
  n4=ddec(4)
  iu(1)=ishft(iand(n1,255),24) + ishft(iand(n2,255),16) +         &
       ishft(iand(n3,255),8) + iand(n4,255)
  n1=ddec(5)
  n2=ddec(6)
  n3=ddec(7)
  n4=ddec(8)
  iu(2)=ishft(iand(n1,255),24) + ishft(iand(n2,255),16) +         &
       ishft(iand(n3,255),8) + iand(n4,255)
  n1=ddec(9)
  n2=ddec(10)
  iu(3)=ishft(iand(n1,255),24) + ishft(iand(n2,255),16)

  return
end subroutine decodems
