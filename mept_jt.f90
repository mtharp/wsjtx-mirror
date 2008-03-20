program mept_jt

  use dfport
  character*40 infile,outfile
  character*12 arg
  integer td(9)
  real*8 f0
  character*11 utcdate
  character*3 month(12)
  data month/'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'/

  nargs=iargc()
10 if(nargs.eq.0) then
     print*,' '
     print*,'MEPT_JT Version 0.3 r90'
     print*,' '
     print*,'Usage: mept_jt Tx  f0 ftx nport call grid dBm [snr] [outfile | nfiles]'
     print*,'       mept_jt T/R f0 ftx nport call grid dBm pctx'
     print*,'       mept_jt Rx  f0 [infile ...]'
     print*,' '
     print*,'       f0 is the transceiver dial frequency (MHz)'
     print*,'       ftx is the signal frequency (MHz)'
     print*,'       nport is the COM port number for PTT control'
     print*,'       snr is the S/N in 2500 Hz bandwidth (for test files)'
     print*,'       pctx is the percentage of 2-minute periods to Tx'
     print*,' '
     print*,'Examples:'
     print*,'       mept_jt Tx  10.1386 10.140100 1 K1JT FN20 30'
     print*,'       mept_jt Tx  10.1386 10.140100 0 K1JT FN20 30 -22 test.wav'
     print*,'       mept_jt T/R 10.1386 10.140100 0 K1JT FN20 30 25'
     print*,'       mept_jt Rx  10.1386'
     print*,'       mept_jt Rx  10.1386 00001.wav 00002.wav 00003.wav'
     print*,' '
     print*,'For more information see:'
     print*,'       physics.princeton.edu/pulsar/K1JT/MEPT_Instructions.TXT'
     go to 999
  endif

  ntr=0
  nsec0=999999
  call getarg(1,arg)
  if(arg(1:2).eq.'TX'.or. arg(1:2).eq.'Tx' .or. arg(1:2).eq.'tx') then
! Transmit only
     if(nargs.lt.7) then
        nargs=0
        go to 10
     endif
     call mept_tx(nargs,ntr)
  else if(arg(1:2).eq.'RX'.or. arg(1:2).eq.'Rx' .or. arg(1:2).eq.'rx') then
! Receive only
     call mept_rx(nargs,ntr)
  else if(arg(1:3).eq.'T/R'.or. arg(1:3).eq.'t/r') then
! Transmit and receive, choosing sequences randomly
     if(nargs.ne.8) then
        nargs=0
        go to 10
     endif
     call random_seed
     ntr=1
     call getarg(2,arg)
     read(arg,*) f0
     call getarg(8,arg)
     read(arg,*) pctx
     pctx=min(max(pctx,0.0),100.0)
20   nsec=time()
     call gmtime(nsec,td)
     write(utcdate,1001) td(4),month(1+td(5)),td(6)+1900
1001 format(i2,'-',a3,'-',i4)
     nsec=mod(nsec,86400)
     if(nsec.lt.nsec0) then
        write(*,1028) utcdate,f0+1400.d-6,f0+1600.d-6
        write(13,1028) utcdate,f0+1400.d-6,f0+1600.d-6
1028    format(/' UTC Date: ',a11,'    Search range:',f11.6,' to',f11.6,' MHz'// &
             ' UTC Sync dB    DT     Freq    Message                  Noise'/    &
             '-------------------------------------------------------------')
     endif
     nsec0=nsec

     call random_number(x)
     if(pctx.eq.49.5) print*,pctx,100.0*x
     if(100.0*x.lt.pctx) then
        call mept_tx(nargs,ntr)
     else
        call mept_rx(nargs,ntr)
     endif
     call pa_sleep(100)
     go to 20
  else
! Illegal set of command parameters
     nargs=0
     go to 10
endif

999 end program mept_jt
