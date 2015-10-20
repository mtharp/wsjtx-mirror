subroutine extract(s3,nadd,ncount,decoded)

  real s3(64,63)
  real tmp(4032)
  character decoded*22
  integer dat4(12)
  integer mrsym(63),mr2sym(63),mrprob(63),mr2prob(63)
  integer correct(0:62)
  integer param(0:7)
  integer indx(0:62)
  real*8 tt
  common/extcom/ntdecode
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
  ntrials=10000
  call sfrsd2(mrsym,mrprob,mr2sym,mr2prob,ntrials,nverbose,correct,   &
       param,indx,tt,ntry)
  ncandidates=param(0)
  nhard=param(1)
  nsoft=param(2)
  nera=param(3)
  ngmd=param(4)
  ndone=ndone+1
  do i=1,12
     dat4(i)=correct(12-i)
  enddo

  ncount=-1
  decoded='                      '
! if(nhard.ge.0) then
  if(nhard.ge.0 .and. nhard.le.42 .and. nsoft.le.32 .and.              &
       (nhard+nsoft).le.73) then
     call unpackmsg(dat4,decoded)                  !Unpack the message
     ncount=0
  endif

  return
end subroutine extract
