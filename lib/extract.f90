subroutine extract(s3,nadd,nqd,ntrials,naggressive,ndepth,              &
     ncount,nhist,decoded,ltext,nft,qual)

! Input:
!   s3       64-point spectra for each of 63 data symbols
!   nadd     number of spectra summed into s3
!   nqd      0/1 to indicate decode attempt at QSO frequency

! Output:
!   ncount   number of symbols requiring correction (-1 for no KV decode)
!   nhist    maximum number of identical symbol values
!   decoded  decoded message (if ncount >=0)
!   ltext    true if decoded message is free text
!   nft      0=no decode; 1=FT decode; 2=hinted decode

  use prog_args                       !shm_key, exe_dir, data_dir
  use packjt

  real s3(64,63)
  character decoded*22
  character*6 mycall
  integer dat4(12)
  integer mrsym(63),mr2sym(63),mrprob(63),mr2prob(63)
  integer mrs(63),mrs2(63)
  integer correct(63),tmp(63)
  integer param(0:7)
  integer indx(0:62)
  real*8 tt
  logical nokv,ltext
  common/chansyms65/correct
  common/test000/param                              !### TEST ONLY ###
  data nokv/.false./,nsec1/0/
  save

  qual=0.
  nbirdie=20
  npct=50
  afac1=1.1
  nft=0
  nfail=0
  decoded='                      '
  call pctile(s3,4032,npct,base)
  s3=s3/base
! Get most reliable and second-most-reliable symbol values, and their
! probabilities
1 call demod64a(s3,nadd,afac1,mrsym,mrprob,mr2sym,mr2prob,ntest,nlow)

  call chkhist(mrsym,nhist,ipk)       !Test for birdies and QRM
  if(nhist.ge.nbirdie) then
     nfail=nfail+1
     call pctile(s3,4032,npct,base)
     s3(ipk,1:63)=base
     if(nfail.gt.30) then
        decoded='                      '
        ncount=-1
        go to 900
     endif
     go to 1
  endif

  mrs=mrsym
  mrs2=mr2sym

  call graycode65(mrsym,63,-1)        !Remove gray code 
  call interleave63(mrsym,-1)         !Remove interleaving
  call interleave63(mrprob,-1)

  call graycode65(mr2sym,63,-1)      !Remove gray code and interleaving
  call interleave63(mr2sym,-1)       !from second-most-reliable symbols
  call interleave63(mr2prob,-1)
  ntry=0

  nverbose=0
  call timer('ftrsd   ',0)
  call ftrsd2(mrsym,mrprob,mr2sym,mr2prob,ntrials,nverbose,correct,   &
       param,indx,tt,ntry)
  call timer('ftrsd   ',1)
  ncandidates=param(0)
  nhard=param(1)
  nsoft=param(2)
  nerased=param(3)
  nsofter=param(4)
  ntotal=param(5)

  nhard_max=44
  nd_a=72 + naggressive
  if(nhard.le.nhard_max .and. ntotal.le.nd_a) nft=1

!  print*,'AAA',ndepth
  if(nft.eq.0 .and. ndepth.ge.5) then
!     print*,'BBB',ndepth
     call timer('exp_deco',0)
     mode65=1
     flip=1.0
     mycall='K1ABC'                   !### TEMPORARY ###
     call exp_decode65(s3,mrs,mrs2,mode65,flip,mycall,qual,decoded)
     if(qual.ge.1.0) then
        nft=2
     else
        param=0
        ntry=0
     endif
     call timer('exp_deco',1)
     go to 900
  endif

  ncount=-1
  decoded='                      '
  ltext=.false.
  if(nft.gt.0) then
    !turn the corrected symbol array into channel symbols for subtraction
    !pass it back to jt65a via common block "chansyms65"
     do i=1,12
        dat4(i)=correct(13-i)
     enddo
     do i=1,63
       tmp(i)=correct(64-i)
     enddo
     correct(1:63)=tmp(1:63)
     call interleave63(correct,63,1)
     call graycode65(correct,63,1)
     call unpackmsg(dat4,decoded)     !Unpack the user message
     ncount=0
     if(iand(dat4(10),8).ne.0) ltext=.true.
  endif
900 continue
  if(nft.eq.1 .and. nhard.lt.0) decoded='                      '
!  write(*,3300) nft,nhard,ntotal,int(qual),decoded
!3300 format(4i5,2x,a22)

  return
end subroutine extract
