subroutine decode4(sym,ndepth,nadd,amp,iknown,imsg,nbits,ndelta,limit,    &
             data1,ncycles,metric,ncount)

  parameter (MAXBITS=103)
  parameter (MAXBYTES=(MAXBITS+7)/8)
  real*4  sym(0:1,0:205)
  integer imsg(72)
  logical iknown(72)
  integer*1 data1(MAXBYTES)          !Decoded user data, 8 bits per byte
  character*72 c72,c72a

  call fano232(sym,nadd,amp,iknown,imsg,nbits,ndelta,limit,    &
       data1,ncycles,metric,ierr)
  if(ierr.eq.0) then
     ncount=0
     return
  endif
  if(ndepth.ge.3) then
     write(c72a,1002) imsg
1002 format(72i1)
     c72=c72a
     c72(1:14)='              '
     call exhaust(sym,c72,data1,nqual)
     ncount=-1
     if(nqual.gt.0) ncount=3
  endif

  return
end subroutine decode4
