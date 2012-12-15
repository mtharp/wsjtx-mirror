program wspr0

! Command-line version of WSPR.

  character*12 arg
  integer nt(9)
  integer soundexit
  real*8 f0,tsec
  character*11 utcdate
  character*3 month(12)
  data month/'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'/

  nargs=iargc()
10 if(nargs.eq.0) then
     print*,' '
     print*,'wspr0 -- version 2.0'
     print*,' '
     print*,'Usage: wspr0 Tx  f0 ftx nport call grid dBm [snr] [outfile | nfiles]'
     print*,'       wspr0 T/R f0 ftx nport call grid dBm pctx'
     print*,'       wspr0 Rx  f0 [infile ...]'
     print*,'       wspr0 D   f0 [infile ...]'
     print*,' '
     print*,'       f0 is the transceiver dial frequency (MHz)'
     print*,'       ftx is the signal frequency (MHz)'
     print*,'       nport is the COM port number for PTT control'
     print*,'       snr is the S/N in 2500 Hz bandwidth (for test files)'
     print*,'       pctx is the percentage of 2-minute periods to Tx'
     print*,' '
     print*,'Examples:'
     print*,'       wspr0 Tx  10.1387 10.140200 1 K1JT FN20 30'
     print*,'       wspr0 Tx  10.1387 10.140200 0 K1JT FN20 30 -22 test.wav'
     print*,'       wspr0 T/R 10.1387 10.140200 0 K1JT FN20 30 25'
     print*,'       wspr0 Rx  10.1387'
     print*,'       wspr0 Rx  10.1387 00001.wav 00002.wav 00003.wav'
     print*,'       wspr0 D   10.1387 120729_1234.wav'
     print*,' '
     print*,'For more information see:'
     print*,'       physics.princeton.edu/pulsar/K1JT/WSPR0_Instructions.TXT'
     go to 999
  endif

  ntr=0
  nsec0=999999
  open(14,file='ALL_WSPR0.TXT',status='unknown',access='append')
  call soundinit
  call getarg(1,arg)
  if(arg(1:2).eq.'TX'.or. arg(1:2).eq.'Tx' .or. arg(1:2).eq.'tx') then
! Transmit only
     if(nargs.lt.7) then
        nargs=0
        go to 10
     endif
     call wspr0_tx(nargs,ntr)
  else if(arg(1:2).eq.'RX'.or. arg(1:2).eq.'Rx' .or. arg(1:2).eq.'rx') then
! Receive only
        write(*,1026)
1026    format(' UTC  dB   DT    Freq       Message'/54('-'))
        write(14,1028)
1028    format(' Date   UTC Sync dB   DT    Freq       Message'/50('-'))
     call wspr0_rx(nargs,ntr)
  else if(arg(1:1).eq.'D'.or. arg(1:1).eq.'d') then
! Decode only (running as sub-process of program WSPR).
     call wspr0_rx(nargs,ntr)
     write(*,1029)
1029 format('<DecodeFinished>')
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
     call gmtime2(nt,tsec)
     nsec=tsec
     write(utcdate,1001) nt(4),month(nt(5)),nt(6)
1001 format(i2,'-',a3,'-',i4)
     nsec=mod(nsec,86400)
     if(nsec.lt.nsec0) then
        write(*,1026)
        write(14,1028)
     endif
     nsec0=nsec

     call random_number(x)
     if(100.0*x.lt.pctx) then
        call wspr0_tx(nargs,ntr)
     else
        call wspr0_rx(nargs,ntr)
     endif
     call msleep(100)
     go to 20
  else
! Illegal set of command parameters
     nargs=0
     go to 10
  endif
  ierr=soundexit()
  call wqdecode(0,'SaveHashTable         ',0)

999 end program wspr0
