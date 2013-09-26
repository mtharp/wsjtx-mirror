subroutine blanker(id,npts,nadd)

  integer*2 id(npts)
  integer*2 nrms(900000)
  integer hist(0:3277)

  hist=0
  nblks=npts/nadd
  k=0
  do iblk=1,nblks
     sq=0.
     do n=1,nadd
        k=k+1
        xid=id(k)
        sq=sq+xid*xid
     enddo
     n=0.1*sqrt(sq/nadd)
     hist(n)=hist(n)+1
     nrms(iblk)=n
  enddo
  nsum=0
  do i=0,3277
     nsum=nsum+hist(i)
     if(nsum.ge.nblks/2) exit
  enddo
  idmax=10*i
  do iblk=1,nblks
     if(nrms(iblk).ge.idmax) then
        ib=nadd*iblk
        ia=ib-nadd+1
        id(ia:ib)=0
     endif
  enddo

  return
end subroutine blanker
