subroutine avemsg4(mseg,mode4,ndepth,decoded,nused,nq1,nq2,neme,   &
     mycall,hiscall,hisgrid,qual,ns,ncount)

! Decodes averaged JT4 data for the specified segment (mseg=1 or 2).

  parameter (MAXAVE=120)                    !Max avg count is 120
  character decoded*22,deepmsg*22,deepbest*22
  character mycall*12,hiscall*12,hisgrid*6
  real sym(207,7)
  integer nch(7)
  data nch/1,2,4,9,18,36,72/
  common/ave/ppsave(207,7,MAXAVE),nflag(MAXAVE),nsave,iseg(MAXAVE),ich1,ich2

! Count the available spectra for this Monitor segment (mseg=1 or 2),
! and the number of spectra flagged as good.

  nused=0
  ns=0
  nqual=0
  deepbest='                      '
  do i=1,nsave
     if(iseg(i).eq.mseg) then
        ns=ns+1
        if(nflag(i).eq.1) nused=nused+1
     endif
  enddo
  if(nused.lt.1) go to 100

! Compute the average of all flagged soft symbols for this segment.
  sym=0.
  ns=0
  do k=1,nsave
     if(nflag(k).eq.1 .and. iseg(k).eq.mseg) then
        sym(1:207,1:7)=sym(1:207,1:7) + ppsave(1:207,1:7,k)
        ns=ns+1
     endif
  enddo
  if(ns.gt.0) sym=sym/ns

  nadd=nused*mode4
  do k=ich1,ich2
     call extract4(sym(1,k),nadd,ncount,decoded)     !Do the KV decode
     if(ncount.ge.0 .or. nch(k).ge.mode4) exit
  enddo
  if(ncount.lt.0) decoded='                      '

  nqual=0
! Possibly should pass nadd=nused, also:
  if(ndepth.ge.3) then
     flipx=1.0                     !Normal flip not relevant for ave msg
     qbest=0.
     neme=1

     do k=ich1,ich2
        call deep4(sym(2,k),neme,flipx,mycall,hiscall,hisgrid,deepmsg,qual)
        if(qual.gt.qbest) then
           qbest=qual
           deepbest=deepmsg
        endif
        if(nch(k).ge.mode4) exit
     enddo
     deepmsg=deepbest
     qual=qbest
     nqual=qbest
! Set submode here?
     if(nqual.lt.nq1) deepbest='                      '
     if(nqual.ge.nq1 .and. nqual.lt.nq2) deepmsg(19:19)='?'
  else
     deepmsg='                      '
     qual=0.
  endif
  if(ncount.lt.0) decoded=deepmsg

! Suppress "birdie messages":
  if(decoded(1:7).eq.'000AAA ') decoded='                      '
  if(decoded(1:7).eq.'0L6MWK ') decoded='                      '

100 if(nused.lt.1) decoded='                      '

  return
end subroutine avemsg4
