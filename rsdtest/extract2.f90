subroutine extract2(s3,nadd,ntrials,param,decoded)

  real s3(64,63)
  real tmp(4032)
  character decoded*22
  integer dat4(12)
  integer mrsym(63),mr2sym(63),mrprob(63),mr2prob(63)
  integer correct(0:62)
  integer param(0:7)
  integer indx(0:62)
  logical first
  common/extcom/ntdecode
  data first/.true./,nsec1/0/
  save

  nfail=0
1 call demod64a(s3,nadd,mrsym,mrprob,mr2sym,mr2prob,ntest,nlow)

!  if(ntest.lt.50 .or. nlow.gt.20) then
!     ncount=-999                         !Flag bad data
!     go to 900
!  endif

  call chkhist(mrsym,nhist,ipk)
  if(nhist.ge.20) then
     nfail=nfail+1
     call pctile(s3,tmp,4032,50,base)     ! ### or, use ave from demod64a ?
     do j=1,63
        s3(ipk,j)=base
     enddo
     go to 1
  endif

  call graycode(mrsym,63,-1)
  call interleave63(mrsym,-1)
  call interleave63(mrprob,-1)

  call graycode(mr2sym,63,-1)
  call interleave63(mr2sym,-1)
  call interleave63(mr2prob,-1)

  nverbose=0
  call sfrsd2(mrsym,mrprob,mr2sym,mr2prob,ntrials,nverbose,correct,param,indx)
  ncount=param(1)
  do i=1,12
     dat4(i)=correct(12-i)
  enddo

  n0=0
  n1=0
  n2=0
  do j=0,62
     i=(62-j) + 1
     if(correct(j).eq.mrsym(i)) then
        n=1
        n1=n1+1
     else if(correct(j).eq.mr2sym(i)) then
        n=2
        n2=n2+1
     else
        n=0
        n0=n0+1
     endif
  enddo
  param(5)=n1
  param(6)=n2
  param(7)=n0

  decoded='                      '
  if(ncount.ge.0) then
     call unpackmsg(dat4,decoded) !Unpack the user message
  endif

  return
end subroutine extract2
