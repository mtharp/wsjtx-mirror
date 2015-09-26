subroutine extract2(s3,nadd,ntrials,param,decoded)

  real s3(64,63)
  real tmp(4032)
  character msg*22
  integer dat4(12)
  integer mrsym(63),mr2sym(63),mrprob(63),mr2prob(63)
  integer correct(0:62)
  integer param(0:7)
  integer indx(0:62)
  common/extcom/ntdecode
  data ndone/0/,ngood/0/
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
  ncandidates=param(0)
  nhard=param(1)
  nsoft=param(2)
  nera=param(3)
  ngmd=param(4)
  ndone=ndone+1

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
     p1=mrprob(i)/255.0 + 1.e-10
     p2=mr2prob(i)/255.0
     if(n.eq.2) then
        write(34,1002) p1,p2,p2/p1,p1-p2,(p1-p2)/p1
1002    format(5f9.3)
     else
        write(33,1002) p1,p2,p2/p1,p1-p2,(p1-p2)/p1
     endif
  enddo

  msg='                      '
  if(nhard.ge.0) call unpackmsg(dat4,msg) !Unpack the user message
  if(msg.eq.'VK7MO K1JT FN20       ') ngood=ngood+1
  frac=float(ngood)/ndone
  write(*,1010) ndone,frac,ncandidates,nhard,nsoft,nera,ngmd,n1,n2,n0,msg
  write(32,1010) ndome,frac,ncandidates,nhard,nsoft,nera,ngmd,n1,n2,n0,msg
1010 format(i5,f8.3,i9,7i4,2x,a22)

  return
end subroutine extract2
