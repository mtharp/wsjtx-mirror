subroutine avg4(nutc,snrsync,dtxx,nfreq,mode4,ntol,ndepth,neme,minw,       &
  mycall,hiscall,hisgrid,nfanoave,avemsg,qave,deepave,ichbest,nave)

! Decodes averaged JT4 data

  use jt4
  character*22 avemsg,deepave,deepbest
  character mycall*12,hiscall*12,hisgrid*6
  real sym(207,7)
  logical first
  data first/.true./
  save

  if(first) then
     iutc=-1
     nfsave=0
     dtdiff=0.2
     first=.false.
  endif

  do i=1,64
     if(nutc.eq.iutc(i) .and. abs(nhz-nfsave(i)).le.ntol) go to 10
  enddo  
  iutc(nsave)=nutc
  syncsave(nsave)=snrsync
  dtsave(nsave)=dtxx
  nfsave(nsave)=nfreq
  ppsave(1:207,1:7,nsave)=rsymbol(1:207,1:7)  !Save data for message averaging

10 sym=0.
  syncsum=0.
  dtsum=0.
  nfsum=0
  nsum=0

  do i=1,64
     if(iutc(i).lt.0) cycle
     if(mod(iutc(i),2).ne.mod(nutc,2)) cycle       !Use only same sequence
     if(abs(nfreq-nfsave(i)).gt.ntol) cycle        !Freq must match
     if(abs(dtxx-dtsave(i)).gt.dtdiff) cycle       !DT must match
     sym(1:207,1:7)=sym(1:207,1:7) +  ppsave(1:207,1:7,i)
     syncsum=syncsum + syncsave(i)
     dtsum=dtsum + dtsave(i)
     nfsum=nfsum + nfsave(i)
     nsum=nsum+1
  enddo

  syncave=0.
  dtave=0.
  fave=0.
  if(nsum.gt.0) then
     sym=sym/nsum
     syncave=syncsum/nsum
     dtave=dtsum/nsum
     fave=float(nfsum)/nsum
  endif

!  nadd=nused*mode4
  kbest=ich1
  do k=ich1,ich2
     call extract4(sym(1,k),ncount,avemsg)     !Do the Fano decode
     nfanoave=0
     if(ncount.ge.0) then
        ichbest=k
        nave=nsum
        go to 900
     endif
     if(nch(k).ge.mode4) exit
  enddo

  deepave='                      '
  qave=0.

! Possibly should pass nadd=nused, also ?
  if(ndepth.ge.3) then
     flipx=1.0                     !Normal flip not relevant for ave msg
     qbest=0.
     do k=ich1,ich2
        call deep4(sym(2,k),neme,flipx,mycall,hiscall,hisgrid,deepave,qave)
        write(82,3101) nutc,sym(51:53,k),flipx,k,qave,deepave
3101    format(i4.4,4f8.1,i3,f7.2,2x,a22)
        if(qave.gt.qbest) then
           qbest=qave
           deepbest=deepave
           kbest=k
           nave=-nsum
!           print*,'b',qbest,k,deepbest
        endif
        if(nch(k).ge.mode4) exit
     enddo

     deepave=deepbest
     qave=qbest
     ichbest=kbest
  endif

900 return
end subroutine avg4
