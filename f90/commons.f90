subroutine commons

  integer RXLENGTH1,RXLENGTH2
  parameter (RXLENGTH1=135168,RXLENGTH2=33792)
  integer*2 d2,d2a

  common/datcom/d2(RXLENGTH2),ndop,nfrit,nsum,f1,nclearave,nqual,rms,   &
       snrdb,dfreq,width,blue(2000),red(2000),d2a(RXLENGTH1)
  save datcom

  return
end subroutine commons
