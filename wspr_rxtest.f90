program wspr_rxtest

  character datetime*11,message*15
  include 'acom1.f90'

  nargs=iargc()
  if(nargs.lt.1) then
     print*,'Usage: wspr_rxtest infile [...]'
     go to 999
  endif

  ltest=.true.
  do ifile=1,nargs
     call getarg(ifile,infile)
     len=80
     call getfile(infile,80)
     call decode
  enddo

999 end program wspr_rxtest

subroutine msleep(n)
  return
end subroutine msleep
