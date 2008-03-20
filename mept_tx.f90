subroutine mept_tx(nargs,ntr)

!  Read command-line arguments and generate Tx data for the MEPT_JT mode.

#ifdef CVF
  use dfport
#endif

  parameter (NMAX=120*12000)
  real*8 f0,ftx
  character*70 arg
  character*12 call1
  character*4 grid
  character*3 cdbm
  character*22 message
  character*70 outfile
  integer*2 iwave(NMAX)
  integer playsound,ptt

  snrdb=99.
  outfile=""
  nfiles=9999
  call getarg(2,arg)
  read(arg,*) f0
  call getarg(3,arg)
  read(arg,*) ftx
  ntxdf=nint(1.d6*(ftx-f0))-1500
  if(abs(ntxdf).gt.100) then
     print*,'Error: ftx must be above f0 by 1400 to 1600 Hz'
     stop
  endif
  call getarg(4,arg)
  read(arg,*) nport
  call getarg(5,call1)
  call getarg(6,grid)
  call getarg(7,arg)
  read(arg,*) ndbm
  if(nargs.lt.8 .or. ntr.ne.0) go to 10
  call getarg(8,arg)
  read(arg,*) snrdb
  if(nargs.lt.9) go to 10
  call getarg(9,outfile)
  read(outfile,1008,err=1) nfiles
1008  format(i4)
  outfile=""
  go to 10
1 nfiles=1

10 i1=index(call1,' ')
  write(cdbm,'(i3)'),ndbm
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  message=call1(1:i1)//grid//' '//cdbm
  do ifile=1,nfiles
     if(nfiles.gt.1 .and. nfiles.lt.9999) write(outfile,1010) ifile
1010 format(i5.5,'.wav')
     call genmept(call1,grid,ndbm,ntxdf,snrdb,iwave)
     if(snrdb.eq.11.0) go to 999
     if(outfile.ne."") then
        call wfile5(iwave,NMAX,12000,outfile)
        write(*,1020) f0,ftx,snrdb,message,outfile(1:24)
1020    format(2f11.6,f6.1,2x,a22,2x,a24)
     else
20      nsec=time()
        isec=mod(nsec,86400)
        ih=isec/3600
        im=(isec-ih*3600)/60
        is=mod(isec,60)
        if(mod(im,2).ne.0) go to 30
        if(is.eq.0) then
           if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
           if(ntr.eq.0) write(*,1030) ih,im,is,f0,ftx,message
1030       format(i2.2,':',i2.2,':',i2.2,2f11.6,2x,a22)
           do i=22,1,-1
              if(message(i:i).ne.' ') go to 25
           enddo
25         iz=i
           write(*,1031) ih,im,ftx,message(1:iz)
           write(13,1031) ih,im,ftx,message(1:iz)
1031       format(2i2.2,14x,f11.6,'  Transmitting "',a,'"')
           ierr=playsound(iwave)
           if(nport.gt.0) ierr=ptt(nport,junk,0,iptt)
           if(ntr.ne.0) go to 999
        endif
30      call pa_sleep(100)
        go to 20
     endif
     if(nfiles.eq.9999) go to 999
enddo

999 return
end subroutine mept_tx
