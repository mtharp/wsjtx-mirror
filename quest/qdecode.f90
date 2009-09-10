subroutine qdecode(s,nbits,jsym,ns2,m0,nsyms,nsymd,nsymt,nblk,      &
  limit,krs,ncode,recv1,ntimeout,metric,ncount)

! Decode a synchronized signal

  include 'qparams.f90'
  real s(NCH,NSZ)                  !Simulated spectra
  integer recv1(NZ1)               !Decoded user message
  integer jsym(NSZ)
  integer*1 dgen6(NZ4)             !Encoded data as 8-bit bytes
  integer*1 symbols(NZ4)
  integer*1 tmp(NZ4)
  integer*1 ddec(NSZ)
  integer*1 i1
  integer t4(NSZ)
  integer mrsym(63),mr2sym(63),mrprob(63),mr2prob(63)
  real s3(64,63)
  integer mettab(0:255,0:1)
  logical first
  data first/.true./
  integer*1 symbols0
  common/tmpcom/symbols0(NZ4)
  equivalence (i1,i4)
  save

  ntones=2**m0
  if(ncode/100.lt.10 .and. first) then
! Get the metric table
     bias=0.0                        !Metric bias: viterbi=0, seq=rate
     if(ncode.eq.232) bias=0.37
     scale=10                        !Optimize?
     if(m0.eq.1) open(19,file='met2.21',status='old')
     if(m0.eq.2) open(19,file='met4.21',status='old')
     if(m0.eq.3) open(19,file='met8.21',status='old')
     if(m0.eq.4) open(19,file='met16.21',status='old')
     if(m0.eq.5) open(19,file='met32.21',status='old')
     if(m0.eq.6) open(19,file='met64.21',status='old')

     do i=0,255
        read(19,*) xjunk,d0,d1
        mettab(i,0)=nint(scale*(d0-bias))
        mettab(i,1)=nint(scale*(d1-bias))    !### Check range, etc.  ###
     enddo
     first=.false.
  endif

! Get spectra and compute bitwise soft symbols for convolutional codes
  js=0
  k=0
  nadd=1
  do j=1,nsymt
     n=mod(j-1,nblk)+1
     if(jsym(j).eq.0) then                  !Use only data symbols
        if(ncode/100.ge.10) then
           k=k+1
           do i=1,ntones
              s3(i,k)=s(i+10,j+10)
           enddo
        else
           do m=m0-1,0,-1                   !Get bit-wise soft symbols
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
        endif
     else
        js=js+1
     endif
  enddo

  if(ncode/100.ge.10) then
     nn=ncode/100
     call demod64(s3,nadd,nn,8,mrsym,mrprob,mr2sym,mr2prob)
     call rsasd(mrsym,mrprob,mr2sym,mr2prob,ierror,ncount,ddec)
     recv1(1:krs)=ddec(1:krs)
     go to 900
  endif

  if(ncode.eq.232) then
     ndelta=17
     ntimeout=0
     call fano232(symbols,nbits+31,mettab,ndelta,limit,    &
          ddec,ncycles,metric,ierr)
     if(ncycles/(nbits+31).ge.limit) ntimeout=1
  else
     if(ncode.eq.207) then
        call vit207(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.209) then
        call vit209(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.211) then
        call vit211(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.213) then
        call vit213(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.215) then
        call vit215(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.216) then
        call vit216(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.217) then
        call vit217(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.218) then
        call vit218(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.316) then
        call vit316(symbols,nbits,mettab,ddec,metric)
     else if(ncode.eq.416) then
        call vit416(symbols,nbits,mettab,ddec,metric)
     endif

  endif

100 nbytes=(nbits+7)/8
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

900 return
end subroutine qdecode
