program tms

  real dat(65536)
  integer DFTolerance
  character c1*1,decoded*24,arg*12,cfile6*6

  nargs=iargc()
  if(nargs.ne.3) then
     print*,'Usage: tms DF Tol nping'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) mousedf
  call getarg(2,arg)
  read(arg,*) DFTolerance
  call getarg(3,arg)
  read(arg,*) nping

  open(10,file='dat.40',status='old',form='unformatted')
  NFreeze=1

  do iter=1,999
     read(10,end=999) iping,jz,(dat(i),i=1,jz)
     if(iping.eq.nping .or. nping.eq.0) then
        call syncms(dat,jz,NFreeze,MouseDF,DFTolerance,snrsync,   &
             dfx,lagbest,isbest,nerr,metric,decoded)
        nsnr=nint(db(snrsync)-2.0)
        ndf=nint(dfx)
        dtx=0.
        mswidth=jz/12.0
        nrpt=16
        if(mswidth.ge.120) nrpt=26
        if(mswidth.gt.1000) nrpt=36
        if(nsnr.ge.6) nrpt=nrpt+1
        if(nsnr.ge.9) nrpt=nrpt+1
        c1=' '
        if(nsnr.ge.2 .and. isbest.ne.0) c1='*'
        cfile6='000000'
        write(*,1010) cfile6,dtx,mswidth,nsnr,nrpt,ndf,isbest,c1,    &
             decoded,nerr,metric
1010    format(a6,f6.1,i5,i4,i4,i6,i3,a1,2x,a24,i7,i5)
        if(nping.ne.0) go to 999
     endif
  enddo
        
999 end program tms
