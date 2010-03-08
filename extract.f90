subroutine extract(s3,nadd,isbest,ncount,decoded,ndec)

  real s3(64,63)
  real tmp(4032)
  character decoded*22,msg*24
  character*5 cmode
  integer era(51),dat4(13),indx(64)
  integer mrsym(63),mr2sym(63),mrprob(63),mr2prob(63)
  integer*1 dbits(96)
  integer iu(3)
  data nsec1/0/
  save

  cmode='JT64'                             !### test only ###
  nfail=0
  ndec=0

1 call demod64a(s3,nadd,mrsym,mrprob,mr2sym,mr2prob,ntest,nlow,nhigh)
  if(ntest.lt.50 .or. nlow.gt.20) then
     ncount=-999                         !Flag bad data
     go to 900
  endif

  call chkhist(mrsym,nhist,ipk)
  if(nhist.ge.20) then
     nfail=nfail+1
     call pctile(s3,tmp,4032,50,base)     ! ### or, use ave from demod64a ?
     do j=1,63
        s3(ipk,j)=base
     enddo
     go to 1
  endif

  kk=5
  if(isbest.eq.2) kk=8
  if(isbest.eq.3) kk=13
  nbit=6*kk

! First, try decoding with hard-decision RS decoder, no erasures.
  call indexx(63,mrprob,indx)
  decoded='                      '
  call krsdecode(mrsym,kk,era,0,dat4,ncount)
  if(ncount.ge.0) then
     dbits=0
     call unpackbits(dat4,13,6,dbits)
     call packbits(dbits,3,32,iu)
     call srcdec(cmode,nbit,iu,msg)
     decoded=msg(1:22)
     ndec=1
     go to 900
  endif

! BM algorithm failed.  Test probabilities for reasonable values...
  nbig=0
  do j=1,63
     if(mrprob(j).eq.255 .and. mr2prob(j).eq.0) nbig=nbig+1
  enddo
  if(nbig.ge.10) go to 900

! Try the KV decoder.
  maxe=8
  xlambda=15.0
  naddsynd=200
  if(kk.eq.8) then
     xlambda=12.0
     naddsynd=50
     maxe=6
  else if(kk.eq.5) then
     xlambda=10.0
     naddsynd=50
     maxe=3
  endif

  nsec1=nsec1+1
  call cs_lock('extract')
  write(22,rec=1) nsec1,kk,xlambda,maxe,naddsynd,mrsym,mrprob,mr2sym,mr2prob
  call flushqqq(22)
  call cs_unlock

  call runqqq('kvasd2.exe','-q',iret)

  call cs_lock('extract')
  if(iret.eq.0) then
     read(22,rec=2,err=20) nsec2,ncount,dat4
     decoded='                      '
     if(ncount.ge.0) then
        dbits=0
        call unpackbits(dat4,13,6,dbits)
        call packbits(dbits,3,32,iu)
        call srcdec(cmode,nbit,iu,msg)
        decoded=msg(1:22)
        ndec=2
        go to 20
     endif
  elseif(iret.eq.-1) then
     write(*,1000)
1000 format('No KV decoder present, will use BM algorithm.')
  else
     write(*,1001) iret
1001 format('Error in KV decoder, return code:',i12)
  endif

20  call cs_unlock

900 continue
  return
end subroutine extract
