subroutine extract(s3,nadd,isbest,ncount,decoded)

  real s3(64,63)
  real tmp(4032)
  character decoded*22,msg*24
  character*5 cmode
  integer era(51),dat4(13),indx(64)
  integer mrsym(63),mr2sym(63),mrprob(63),mr2prob(63)
  integer*1 dbits(96)
  integer iu(3)
  logical first
  common/extcom/ntdecode
  data first/.true./,nsec1/0/
  save

  nfail=0
1 call demod64a(s3,nadd,mrsym,mrprob,mr2sym,mr2prob,ntest,nlow)
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

  ndec=0                                  !Temp for tests ###
  kk=5
  if(isbest.eq.2) kk=8
  if(isbest.eq.3) kk=13
  nbit=6*kk

  nemax=30
  maxe=8
  xlambda=15.0
  naddsynd=200
  if(ntdecode.eq.48) then
     xlambda=12.0
     naddsynd=50
  endif

  if(ndec.eq.1) then
     nsec1=nsec1+1
     call cs_lock('extract')
     write(22,rec=1) nsec1,xlambda,maxe,naddsynd,mrsym,mrprob,mr2sym,mr2prob
     call flushqqq(22)
     call cs_unlock

     call runqqq('kvasd.exe','-q',iret)

     call cs_lock('extract')
     if(iret.ne.0) then
        if(first) write(*,1000) iret
1000    format('Error in KV decoder, or no KV decoder present.'/        &
             'Return code:',i8,'.  Will use BM algorithm.')
        ndec=0
        first=.false.
        go to 20
     endif
     read(22,rec=2,err=20) nsec2,ncount,dat4

     decoded='                      '
     if(ncount.ge.0) then
!        call unpackmsg(dat4,decoded) !Unpack the user message
        decoded='Message decoded'
        print*,decoded
     endif
20   call cs_unlock
  endif

  if(ndec.eq.0) then
     call indexx(63,mrprob,indx)
     do i=1,nemax
        j=indx(i)
        if(mrprob(j).gt.120) then
           ne2=i-1
           go to 2
        endif
        era(i)=j-1
     enddo
     ne2=nemax
2    decoded='                      '
     do nerase=0,ne2,2
        call krsdecode(mrsym,kk,era,nerase,dat4,ncount)
        if(ncount.ge.0) then
           dbits=0
           call unpackbits(dat4,13,6,dbits)
           call packbits(dbits,3,32,iu)
           cmode='JT64'                             !### test only ###
           call srcdec(cmode,nbit,iu,msg)
           decoded=msg(1:22)
           go to 900
        endif
     enddo
  endif

900 continue
  return
end subroutine extract
