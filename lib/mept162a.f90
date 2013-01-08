subroutine mept162a(datetime,f0,c2,ps,lc2,npts,nbfo)

! Orchestrates the process of finding, synchronizing, and decoding 
! WSPR signals.

  logical lc2
  character*22 message
  character*11 datetime
  real*8 f0,freq
  real ps(-256:256)
  real sstf(5,275)
  real a(5)
  complex c2(65536)
  complex c3(45000),c4(45000)

  jz=45000
  c2(jz+1:)=0.

  call sync162(c2,jz,ps,sstf,kz)        !Look for sync patterns, get DF and DT

  if(kz.eq.0) go to 900
  do k=1,kz
     snrsync=sstf(1,k)
     snrx=sstf(2,k)
     dtx=sstf(3,k)
     dfx=sstf(4,k)
     drift=sstf(5,k)
     a(1)=-dfx
     a(2)=-0.5*drift
     a(3)=0.
     call twkfreq(c2,c3,jz,a)                    !Remove drift

     minsync=1                                   !####
     nsync=nint(snrsync)
     if(nsync.lt.0) nsync=0
     if(npts.le.120*12000) then
        minsnr=-33
        nsnrx=nint(snrx)                         !WSPR-2
        if(nsnrx.lt.minsnr) nsnrx=minsnr
        freq=f0 + 1.d-6*(dfx+nbfo)
     else
        minsnr=-42
        nsnrx=nint(snrx-9.0)                     !WSPR-15
        if(nsnrx.lt.minsnr) nsnrx=minsnr
        dfx=dfx/8
        freq=f0 + 1.d-6*(dfx+nbfo+112.5d0)
     endif
     message='                      '
     if(nsync.ge.minsync .and. nsnrx.ge.minsnr) then
        dt=1.0/375
        do idt=0,128
           ii=(idt+1)/2
           if(mod(idt,2).eq.1) ii=-ii
           i1=nint((dtx+2.0)/dt) + ii !Start index for synced symbols
           if(i1.ge.1) then
!  Fix this earlier!
              c4(1:jz-i1+1)=c3(i1:)
              c4(jz-i1+2:)=0.
           else
              c4(:-i1+1)=0.
              c4(-i1+2:jz)=c3(:i1+jz-1)
              if(jz.lt.45000) c4(jz:)=0.
           endif
           call decode162(c4,45000,message,ncycles,metric,nerr)
           if(message(1:6).ne.'      ' .and.                        &
                message(1:6).ne.'000AAA' .and.                      &
                index(message,'A000AA').le.0) then
              nf1=nint(-a(2))
              if(npts.gt.120*12000) dtx=8*(dtx + 1.8)   !1.8 is empirical ###

              write(13,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1,   &
                   ncycles/81,ii
1010          format(a11,i4,i4,f5.1,f11.6,2x,a22,i3,i6,i5)
              write(*,1020) datetime(8:11),nsnrx,dtx,freq,nf1,message
1020          format(a4,i4,f5.1,f11.6,i3,2x,a22)
              write(14,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1,      &
                   ncycles/81,ii
              call flush(14)
              exit
           endif
        enddo
     endif
  enddo

900 return
end subroutine mept162a
