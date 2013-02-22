subroutine decode4(sym,ndepth,nadd,amp,iknown,imsg,nbits,ndelta,limit,    &
             data1,ncycles,metric,ncount)

  parameter (MAXBITS=103)
  parameter (MAXBYTES=(MAXBITS+7)/8)
  real*4  sym(0:1,0:205)
  integer imsg(72)
  logical iknown(72),iknown0(72)
  integer*1 data1(MAXBYTES)          !Decoded user data, 8 bits per byte
  character*72 c72,c72a

! Depth=1: Fano decode
  iknown0=.false.
  call fano232(sym,nadd,amp,iknown0,imsg,nbits,ndelta,limit,    &
       data1,ncycles,metric,ncount)

  if(ndepth.lt.2 .or. ncount.eq.0) return
! Depth=2: MyCall known, Fano for the rest
  call fano232(sym,nadd,amp,iknown,imsg,nbits,ndelta,limit,    &
       data1,ncycles,metric,ncount)

  if(ndepth.lt.3) return
! Depth=4: MyCall and HisCall known, exhaustive search for xrpt
  write(c72a,1002) imsg
1002 format(72i1)
  c72=c72a
  call exhaust(sym,c72,data1,nqual)
  ncount=-1
  if(nqual.gt.0) then
     ncount=3
     return
  endif

  if(ndepth.lt.4) return
! Depth=5: MyCall known, DS for xcall+xgrid

  if(ndepth.lt.5) return
! Depth=6: HisCall and HisGrid known, DS for xcall

  return
end subroutine decode4
