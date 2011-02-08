subroutine fold1pps(x,npts,ip1,ip2,prof,p,pk,ipk)

  real x(npts)
  real proftmp(12005),prof(12005)
  real*8 p,ptmp

  pk=0.
  do ip=ip1,ip2
     call ffa(x,npts,npts,ip,proftmp,ptmp,pktmp,ipktmp)
     if(pktmp.gt.pk) then
        p=ptmp
        pk=pktmp
        ipk=ipktmp
        prof=proftmp
     endif
  enddo

  return
end subroutine fold1pps
