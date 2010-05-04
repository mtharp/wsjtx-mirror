subroutine iscat(dat,jz,cfile6,MinSigdB,NFreeze,MouseDF,DFTolerance,    &
          NSyncOK,ccfblue,ccfred,ps0)

! Decode in ISCAT mode

  real dat(jz)                !Raw audio data
  integer DFTolerance
  real s2(64,63)              !2D spectral array
  character cfile6*6,c1*1
  real ccfblue(-5:540),ccfred(-224:224)
  real ps0(431)
  character decoded*22
  logical dofft

  NsyncOK=0
  nadd=1
  decoded=' '
  c1=' '
  ndec=0
  dofft=.true.

! Try a range of starting points, stepping by half the message length
  nn=512*(63+10+2)                         !Message length in samples
  do istart=1,jz-nn,nn/2
     lenz=(jz-istart)/nn
! Try a range of integral numbers of message repetitions, starting with largest
     do len=lenz,1,-1
        jza=min(jz-istart,nint(len+0.75)*nn)
        isbest=1
        i0=istart
        len0=len

! Establish sync or find a shorthand message
        call synciscat(dat(i0),jza,i0,dofft,DFTolerance,NFreeze,MouseDF,   &
             dtx,dfx,snrx,isync,isbest,ccfblue,ccfred,s2,ps0,short,        &
             dfshort,kshort)
        if(len.eq.2) isync=isync-1
        if(len.eq.1) isync=isync-2
        if(isync.lt.0) isync=0

        nsnr=nint(snrx)
        jdf=nint(dfx)
        decoded=' '
        if(isync.ge.MinSigdB) then
           c1='*'
           call extract(s2,nadd,isbest,ncount,decoded,ndec)
        else if(short.gt.5.0) then
           jdf=nint(dfshort)
           if(kshort.eq.1) decoded='RO'
           if(kshort.eq.2) decoded='RRR'
           if(kshort.eq.3) decoded='73'
           isbest=0
           nsnr=nint(db(short)-23.0)
           ndec=1
        endif
        t1=i0/12000.0

        call cs_lock('iscat')
        write(11,1010) cfile6,isync,nsnr,jdf,isbest,c1,decoded,ndec,t1,len0
        if(decoded.ne.'                      ') then
           write(21,1010) cfile6,isync,nsnr,jdf,isbest,c1,decoded,ndec,t1,len0
1010       format(a6,i4,i5,i5,i3,a1,2x,a22,10x,i1,f6.1,i4)
        endif
        call cs_unlock
        if(decoded.ne.'                      ') go to 999
        if(i0.ne.1 .or. jza.ne.jz) rewind 11
     enddo
  enddo

999 return
end subroutine iscat
