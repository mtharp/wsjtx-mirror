subroutine qsync(s,icos,nblk,ns2,nsyms,nsymt,esync,nsync)

! Establish synchronization in frequency and time

  include 'qparams.f90'
  real s(NCH,NSZ)                  !Simulated spectra
  integer icos(10)

! Set the search ranges
  iimax=9
  jjmax=9

  smax=0.
  do ii=-iimax,iimax
     do jj=-jjmax,jjmax
        sum=0.
        js=0
        do j=1,nsymt
           n=mod(j-1,nblk)+1
           if(n.le.ns2 .and. js.lt.nsyms) then
              js=js+1
              sum=sum + s(10+icos(n)+ii,10+j+jj)
           endif
        enddo
        if(sum.gt.smax) then
           smax=sum
           ipk=ii
           jpk=jj
        endif
     enddo
  enddo
  snrsync=(smax-nsyms)/sqrt(float(nsyms))    !??? normalize by avg sig ???
  if(ipk.ne.0 .or. jpk.ne.0) then
     esync=max(esync,snrsync)
  else
     nsync=nsync+1
  endif

  return
end subroutine qsync
