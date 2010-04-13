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

        sq=dot_product(dat(1:jz),dat(1:jz))
        rms=sqrt(sq/1000.0)
        fac=884.244/rms
        dat(1:jz)=fac*dat(1:jz)
        k=0
        nadd=200
        do j=1,jz/nadd
           sq=0.
           do i=1,nadd
              k=k+1
              sq=sq + dat(k)**2
           enddo
           sdb=db(sq/nadd) + 10.0
           write(13,1002) j/120.0,sdb
1002       format(f8.3,f10.3)
        enddo

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
        write(*,1010) iping,dtx,mswidth,nsnr,nrpt,ndf,isbest,c1,    &
             decoded,nerr,metric
1010    format(i3,f6.1,i5,i4,i4,i6,i3,a1,2x,a24,i7,i5)
        if(nping.ne.0) go to 999
     endif
  enddo
        
999 end program tms
