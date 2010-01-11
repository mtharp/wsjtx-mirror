subroutine iscat(dat,jz,cfile6,MinSigdB,NFreeze,MouseDF,DFTolerance,    &
          nxa,nxb,NSyncOK,ccfblue,ccfred,ps0)

  real dat(jz)                !Raw audio data
  integer DFTolerance
  real s2(64,63)              !2D spectral array
  character cfile6*6,cf*1
  real ccfblue(-5:540),ccfred(-224:224)
  real ps0(431)
  character decoded*22

  NsyncOK=0
  nfft=1024                   !Do FFTs of twice the symbol length
  nstep=128                   !Step by 1/4 symbols
  df=12000.0/nfft
  nadd=1
  decoded=' '

!  if(nxb.eq.0) then
!     istart=1
!     jza=jz
!  else
!     istart=max(nint(jz*nxa/500.0),1)
!     jza=min(nint(jz*(nxb-nxa)/500.0),jz)
!  endif
!  if(jza.lt.32*1200) go to 999

  nn=512*75
  do istart=1,jz-nn,nn/2
     lenz=jz/nn
     do len=lenz,2,-1
        jza=len*nn
        if(jza.gt.jz-istart) go to 90
        isbest=1
        i0=istart
        len0=len
        if(nxb.gt.0) then
           i0=max(nint(jz*nxa/500.0),1)
           jza=min(nint(jz*(nxb-nxa)/500.0),jz)
           len0=jza/nn
           if(len0.lt.1) go to 90
        endif

        call synciscat(dat(i0),jza,DFTolerance,NFreeze,MouseDF,      &
             dtx,dfx,snrx,nsync,isbest,ccfblue,ccfred,s2,ps0,nsteps,     &
             short,kshort)

        nsnr=nint(snrx)
        if(nsnr.lt.-30 .or. nsync.lt.0) nsync=0
        nsnrlim=-32
        jdf=nint(dfx)
        cf=' '
        decoded=' '
        if(nsync.ge.MinSigdB) then
           call extract(s2,nadd,isbest,ncount,decoded,ndec)
           cf='*'
        endif

        if(nsync.eq.0 .and. short.gt.2.0) then
           if(kshort.eq.1) decoded='RO'
           if(kshort.eq.2) decoded='RRR'
           if(kshort.eq.3) decoded='73'
           isbest=0
           nsnr=db(short) - 23.0
        endif

        call cs_lock('iscat')
        t1=i0/12000.0
!        t2=t1+jza/12000.0
!        write(*,1000) t1,t2,len0,nsync,short,kshort
!1000    format(2f6.1,i4,i8,f8.1,i5)
        write(11,1010) cfile6,nsync,nsnr,jdf,isbest,cf,decoded,ndec,t1,len0
        if(decoded.ne.'                      ') then
           write(21,1010) cfile6,nsync,nsnr,jdf,isbest,cf,decoded,ndec,t1,len0
1010       format(a6,i4,i5,i5,i3,a1,3x,a22,10x,i1,f6.1,i4)
        endif
        call cs_unlock
        if(decoded.ne.'                      ') go to 999
        if(nxb.gt.0) go to 999
        if(i0.ne.1 .or. jza.ne.jz) rewind 11
90      continue
     enddo
  enddo

999 return
  if(nxb.gt.0) nxb=nint(nsteps*128*500.0/jz + nxa)
end subroutine iscat
