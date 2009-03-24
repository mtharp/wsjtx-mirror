subroutine qdecode(s,nbits,ns2,m0,nsyms,nsymd,nsymt,nblk,      &
  limit,krs,ncode,recv1,ntimeout,metric)

! Decode a synchronized signal

  include 'qparams.f90'
  real s(NCH,NSZ)                  !Simulated spectra
  integer recv1(NZ1)               !Decoded user message
  integer*1 dgen6(NZ4)             !Encoded data as 8-bit bytes
  integer*1 symbols(NZ4)
  integer*1 tmp(NZ4)
  integer*1 ddec(NSZ)
  integer*1 i1
  integer t4(NSZ)
  integer mettab(0:255,0:1)
  logical first
  data first/.true./
  integer*1 symbols0
  common/tmpcom/symbols0(NZ4)
  equivalence (i1,i4)
  save

  if(first) then
! Get the metric table
     bias=0.0                        !Metric bias: viterbi=0, seq=rate
     if(ncode.eq.232) bias=0.4
     scale=10                        !Optimize?
     if(m0.eq.1) open(19,file='met.117',status='old')
     if(m0.eq.2) open(19,file='met.127',status='old')
     if(m0.eq.3) open(19,file='met.136',status='old')
     if(m0.eq.4) open(19,file='met.147',status='old')
     if(m0.eq.5) open(19,file='met.158',status='old')
     if(m0.eq.6) open(19,file='met.169',status='old')

     do i=0,255
        read(19,*) xjunk,d0,d1
        mettab(i,0)=nint(scale*(d0-bias))
        mettab(i,1)=nint(scale*(d1-bias))    !### Check range, etc.  ###
     enddo
     ntones=2**m0
     first=.false.
  endif

! Compute bit-wise soft symbols
  js=0
  k=0
  do j=1,nsymt
     n=mod(j-1,nblk)+1
     if(n.gt.ns2 .or. js.ge.nsyms) then     !Use only data symbols
        do m=m0-1,0,-1
           n=2**m
           r1=0.
           r2=0.
           do i=0,ntones-1
              if(iand(i,n).ne.0) then
                 r1=max(r1,s(i+11,j+10))
              else
                 r2=max(r2,s(i+11,j+10))
              endif
           enddo
           k=k+1
           symbols(k)=min(127,max(-127,nint(2.0*(r1-r2)))) + 128
        enddo
     else
        js=js+1
     endif
  enddo

  if(ncode.eq.232) then
     ndelta=17
     ntimeout=0
     call fano232(symbols,nbits+31,mettab,ndelta,limit,    &
          ddec,ncycles,metric,ierr)
     if(ncycles/(nbits+31).ge.limit) ntimeout=1
  else
     nstart=0
     nend=0
!     call vdecode(symbols,nbits,mettab,ddec,metric,nstart,nend)
     if(ncode.eq.216) then
        call vit216(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.218) then
        call vit218(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.316) then
        call vit316(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.416) then
        call vit416(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.418) then
        call vit418(symbols,nbits,mettab,ddec,metric)
     else
        stop 'Unsupported code'
     endif

  endif
  nbytes=(nbits+7)/8
  do i=1,nbytes
     n=ddec(i)
     t4(i)=iand(n,255)
  enddo
  call unpackbits(t4,nbytes,8,tmp)

  call packbits(tmp,krs,m0,t4)
  do i=1,krs
     if(t4(i).lt.128) dgen6(i)=t4(i)
     if(t4(i).ge.128) dgen6(i)=t4(i)-256
  enddo
  do i=1,krs
     recv1(i)=dgen6(i)
  enddo

return
end subroutine qdecode
