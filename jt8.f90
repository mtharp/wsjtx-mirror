subroutine jt8(dat,jz,cfile6,MinSigdB,DFTolerance,NFreeze,              &
             MouseDF2,NSyncOK,ccfblue,ccfred)

! Orchestrates the process of decoding JT8 messages, using data that
! have been 2x downsampled.  The search for shorthand messages has
! already been done.

  real dat(jz)                        !Raw data
  integer DFTolerance
  real ccfblue(-5:540),ccfred(-224:224)
  real s3(0:7,124)                    !2d spectrum, synchronized, data only
  character line*90,decoded*24,deepmsg*24,special*5
  character csync*2,cfile6*6,cmode*5
  integer iu(3)
  integer*1 symbols(372)
  integer*1 ddec(10)
  integer*1 gsym1(372)
  integer*1 gsym2(372)
  integer mettab(0:255,0:1)
  integer igray0(0:7)
  logical first
  data igray0/0,1,3,2,7,6,4,5/    !Use this to remove the gray code
  data first/.true./
  save first,mettab

  if(first) then
! Get the metric table
     bias=0.0                        !Metric bias: viterbi=0, seq=rate
     scale=10                        !Optimize?
     open(19,file='met8.21',status='old')
     do i=0,255
        read(19,*) xjunk,d0,d1
        mettab(i,0)=nint(scale*(d0-bias))
        mettab(i,1)=nint(scale*(d1-bias))    !### Check range, etc.  ###
     enddo
     close(19)
     first=.false.
  endif

! Attempt to synchronize: get DF and DT.
  csymc='  '
  call syncjt8(dat,jz,DFTolerance,NFreeze,MouseDF,dtx,dfx,snrx,      &
       snrsync,ccfblue,ccfred,s3)
  nsync=nint(snrsync)

  if(nsync.ge.minsigdb) then
! We have achieved sync.  Remove gray code and compute single-bit soft symbols.
     fac=2.0
     do j=1,124
        k=3*j-2
        r1=max(s3(4,j),s3(5,j),s3(6,j),s3(7,j))
        r2=max(s3(0,j),s3(1,j),s3(2,j),s3(3,j))
        gsym2(k)=min(127,max(-127,nint(fac*(r1-r2)))) + 128

        r1=max(s3(2,j),s3(3,j),s3(4,j),s3(5,j))
        r2=max(s3(0,j),s3(1,j),s3(6,j),s3(7,j))
        gsym2(k+1)=min(127,max(-127,nint(fac*(r1-r2)))) + 128

        r1=max(s3(1,j),s3(2,j),s3(4,j),s3(7,j))
        r2=max(s3(0,j),s3(3,j),s3(5,j),s3(6,j))
        gsym2(k+2)=min(127,max(-127,nint(fac*(r1-r2)))) + 128
     enddo

! Remove interleaving
     do i1=0,30
        do i2=0,11
           i=31*i2+i1
           j=12*i1+i2
           gsym1(j+1)=gsym2(i+1)
        enddo
     enddo

     nbit=78
     call vit416(gsym1,nbit,mettab,ddec,metric)
     iz=(nbit+7)/8
     ddec(iz+1:)=0
     n1=ddec(1)
     n2=ddec(2)
     n3=ddec(3)
     n4=ddec(4)
     iu(1)=ishft(iand(n1,255),24) + ishft(iand(n2,255),16) +         &
           ishft(iand(n3,255),8) + iand(n4,255)
     n1=ddec(5)
     n2=ddec(6)
     n3=ddec(7)
     n4=ddec(8)
     iu(2)=ishft(iand(n1,255),24) + ishft(iand(n2,255),16) +         &
           ishft(iand(n3,255),8) + iand(n4,255)
     n1=ddec(9)
     n2=ddec(10)
     iu(3)=ishft(iand(n1,255),24) + ishft(iand(n2,255),16)

     decoded='                        '
     cmode='JT8'
     call srcdec(cmode,nbit,iu,decoded)
     nsnr=nint(snrx)
     ndf=nint(dfx)
     csync='3*'
     NSyncOK=1

     call cs_lock('jt8')
     write(11,1010) cfile6,nsync,nsnr,dtx,ndf,csync,decoded
1010 format(a6,i3,i5,f5.1,i5,1x,a2,1x,a24)
     call cs_unlock
  endif

  return
end subroutine jt8
