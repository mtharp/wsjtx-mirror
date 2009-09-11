subroutine unpktext(iu,msg)

  character*24 msg
  integer iu(3)
  integer*8 n1,n45
  character*45 c
  data c/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ +-./?@#$'/
  common/txtcom/n1a,n1b
  equivalence(n1a,n1)

  n1a=iu(1)
  n1b=iu(2)                                !n1 now holds 64 bits
  n2=iand(n1a,511)
  n1=ishft(n1,-9)                          !n1 now holds 55 bits
  n2=ishft(n2,13) + ishft(iu(3),-19)
  ntext=iand(ishft(iu(3),-18),1)

  n45=45
  do i=10,1,-1
     j=mod(n1,n45) + 1
     msg(i:i)=c(j:j)
     n1=n1/45
  enddo

  do i=14,11,-1
     j=mod(n2,45) + 1
     msg(i:i)=c(j:j)
     n2=n2/45
  enddo
  msg(15:24) = '          '

  return
end subroutine unpktext
