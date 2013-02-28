subroutine snr4(blue,sync,snr)

  real blue(65)
  integer ipk1(1)
  equivalence (ipk,ipk1)

  ipk1=maxloc(blue)
  ns=0
  s=0.
  do i=1,65 
     if(abs(i-ipk).gt.1) then
        s=s+blue(i)
        ns=ns+1
     endif
  enddo
  base=s/ns
  blue=blue-base
  sq=0.
  do i=1,65
     if(abs(i-ipk).gt.1) sq=sq+blue(i)**2
  enddo
  rms=sqrt(sq/(ns-1))
  snr=10.0*log10(blue(ipk)/rms) - 30.6
  sync=snr+25.5

  print*,'B',blue(ipk),rms,sync,blue(ipk)/rms,db(blue(ipk)/rms)

  return
end subroutine snr4
