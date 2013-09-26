subroutine blanker(id,npts,tblank,fblank)

  integer*2 id(npts)
  integer*2 nrms(900000)
  integer hist(0:32767)

  hist=0
  nadd=nint(tblank*12000)
  nblks=npts/nadd
  nblank=fblank*nblks
  k=0
  do iblk=1,nblks
     sq=0.
     do n=1,nadd
        k=k+1
        xid=id(k)
        sq=sq+xid*xid
     enddo
     n=sqrt(sq/nadd)
     hist(n)=hist(n)+1
     nrms(iblk)=n
  enddo
  nsum=0
  do i=32767,0,-1
     nsum=nsum+hist(i)
     if(nsum.ge.nblank) exit
  enddo
  idmax=i

  do iblk=1,nblks
     if(nrms(iblk).ge.idmax) then
        ib=nadd*iblk
        ia=ib-nadd+1
        id(ia:ib)=0
     endif
  enddo

  return
end subroutine blanker
