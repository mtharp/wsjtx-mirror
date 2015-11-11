subroutine extr2(mrsym,mrprob,mr2sym,mr2prob,sym1,nused,nexplim,ntrials)

  parameter (NMAX=10000)
  integer mrsym(0:62),mr2sym(0:62),mrprob(0:62),mr2prob(0:62)
  integer*1 sym1(0:62,NMAX)
  integer dat4(12)
  integer test(0:62),correct(0:62)
  integer param(0:7)
  integer indx(0:62)
  character msg*22
  real*8 tt
  data ndone/0/,ngood/0/,nbad/0/,nverbose/0/
  save

  ndone=ndone+1
  if(nexplim.le.0) go to 1
  nbest=999999
  do j=1,nused
     test=sym1(0:62,j)
     call exp_decode(mrsym,mrprob,mr2sym,nh,ns,test)
     if(nh+ns.lt.nbest) then
        nhard=nh
        nsoft=ns
        nbest=nhard+nsoft
        ncandidates=0
        ntry=0
        correct=test
     endif
  enddo
  if(nbest.lt.nexplim) go to 10

1 call sfrsd2(mrsym,mrprob,mr2sym,mr2prob,ntrials,nverbose,correct,   &
       param,indx,tt,ntry)
  ncandidates=param(0)
  nhard=param(1)
  nsoft=param(2)
  nera=param(3)
  ngmd=param(4)

10 do i=1,12
     dat4(i)=correct(12-i)
  enddo

  msg='                      '
  if(nhard.ge.0) then
     call unpackmsg(dat4,msg) !Unpack the user message
     if(msg.eq.'VK7MO K1JT FN20       ') then
        ngood=ngood+1
     else
        nbad=nbad+1
     endif
  endif
  fgood=float(ngood)/ndone
  fbad=float(nbad)/ndone
  nboth=nhard+nsoft
  if(nhard.lt.0) then
     nsoft=99
     nera=99
     nboth=99
     nh=-1
     ns=99
  endif
!  write(*,1010) ndone,fgood,fbad,ntest,ncandidates,nhard,nsoft,nboth2,nboth,  &
!       ntry,tt,msg
!1010 format(i4,2f6.3,i3,i8,4i3,i8,f8.1,1x,a18)
  write(*,1010) ndone,fgood,fbad,ncandidates,nhard,nsoft,      &
       nh-nhard,ns-nsoft,nboth,ntry,msg
1010 format(i4,2f6.3,i8,5i3,i8,1x,a22)
  write(32,1010) ndone,fgood,fbad,ncandidates,nhard,nsoft,      &
       nh-nhard,ns-nsoft,nboth,ntry,msg

  return
end subroutine extr2
