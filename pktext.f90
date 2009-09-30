subroutine pktext(msg,iu)

  character*24 msg
  integer iu(3)
  integer*8 n1
  character*45 c
  data c/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ +-./?@#$'/
  common/txtcom/n1a,n1b
  equivalence(n1a,n1)

  n2=0
  n1=0

  do i=1,10                               !First 5 characters in n1
     do j=1,45                            !Get character code
        if(msg(i:i).eq.c(j:j)) go to 10
     enddo
     j=37
10   n1=45*n1 + (j-1)
  enddo

  do i=11,14                              !Characters 11-14 in n2
     do j=1,45                            !Get character code
        if(msg(i:i).eq.c(j:j)) go to 20
     enddo
     j=37
20   n2=45*n2 + (j-1)
  enddo

! We now have 55 bits in n1 and 22 bits in n2

  n1=ishft(n1,9) + ishft(n2,-13)
  iu(1)=n1a
  iu(2)=n1b
  m13=2**13 - 1
  iu(3)=iand(n2,m13)                      !13 bits from n2
  iu(3)=2*iu(3)+1                         !Shift left and insert free-text bit
  iu(3)=ishft(iu(3),18)

  return
end subroutine pktext
