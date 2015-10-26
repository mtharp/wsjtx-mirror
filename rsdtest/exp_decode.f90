subroutine exp_decode(mrsym,mrprob,mr2sym,nh,ns,sym)

  integer mrsym(0:62),mr2sym(0:62),mrprob(0:62)
  integer sym(0:62)  !,correct(0:62)
!  data sym/14,39,53,53,29, 3,55,23,49, 5,22,53,53,39,52,15, 0,10, 5,56,63, &
!            5,14,38,43,19,45,33,47,32,40,22, 3,50,19,52,47,54,18,42,20,28, &
!           26, 7,50,58, 5,57,45,44,19, 5, 7,56,15,25,18,62,56,54,55,17,13/

  nh=0
  ns=0
  do i=0,62
     j=62-i
     if(mrsym(j).ne.sym(i)) then
        nh=nh+1
        if(mr2sym(j).ne.sym(i)) ns=ns+mrprob(j)
     endif
  enddo
  ns=63*ns/sum(mrprob)
!  if(nhard<42 .and. (nhsrd+nsoft)<72) correct=sym

  return
end subroutine exp_decode
