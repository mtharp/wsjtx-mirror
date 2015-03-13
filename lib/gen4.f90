subroutine gen4(msg0,ichk,msgsent,i4tone,itype)

! Encode a JT4 message and returns msgsent, the message as it will be
! decodes; an integer array i4tone(207) of 4-FSK tons values in the
! range 0-3; and itype, the JT message type.  (If ichk is nonzero, the
! tones are not computed.)

  character*22 msg0
  character*22 message          !Message to be generated
  character*22 msgsent          !Message as it will be received
  character*3 cok               !'   ' or 'OOO'
  real*8 t,dt,phi,f,f0,dfgen,dphi,pi,twopi,samfac,tsymbol
  integer*2 iwave(NMAX)         !Generated wave file
  integer sendingsh
  integer dgen(13)
  integer*1 data0(13),symbol(216)
  logical first
  common/prcom2/ npr2(207),pr2(207)
  common/n1n2ng/ncall1,ncall2,ngrid
  data npr2/                                                    &
       0,0,0,0,1,1,0,0,0,1,1,0,1,1,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0, &
       0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,0,0, &
       1,0,0,1,0,0,1,1,1,1,1,0,0,0,1,0,1,0,0,0,1,1,1,1,0,1,1,0,0,1, &
       0,0,0,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,0,1,0,1, &
       0,1,1,1,0,0,1,0,1,1,0,1,1,1,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,1, &
       0,1,1,1,0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1, &
       1,0,0,1,1,0,0,0,0,1,1,0,0,0,1,0,1,1,0,1,1,1,1,0,1,0,1/

  data first/.true./
  save

  message=msg0
  do i=1,22
     if(ichar(message(i:i)).eq.0) then
        message(i:)='                      '
        exit
     endif
  enddo

  do i=1,22                               !Strip leading blanks
     if(message(1:1).ne.' ') exit
     message=message(i+1:)
  enddo

  nsym=207                               !Symbols per transmission
  if(first) then
     do i=1,nsym
        pr2(i)=2*npr2(i)-1
     enddo
     first=.false.
  endif

  call chkmsg(message,cok,nspecial,flip)
  call packmsg(message,dgen)  !Pack 72-bit message into 12 six-bit symbols
  if(ngrid.ge.32402 .and. ngrid.le.32462) flip=-1.0   !Use #-sync for reports
  call entail(dgen,data0)
  call unpackmsg(dgen,msgsent)

  nbytes=(72+31+7)/8
  call encode(data0,nbytes,symbol(2))    !Convolutional encoding
  symbol(1)=0                            !Reference phase
  sendingsh=0
  if(iand(dgen(10),8).ne.0) sendingsh=-1 !Plain text flag
  call interleave4(symbol(2),1)          !Apply JT4 interleaving

! Set up necessary constants
  tsymbol=2520.d0/11025.d0
  dt=1.d0/(samfac*11025.d0)
  f0=118*11025.d0/1024 + ntxdf
  dfgen=11025.d0/2520                     !4.375 Hz
  t=0.d0
  phi=0.d0
  j0=0
  ndata=(nsym*11025.d0*samfac*tsymbol)/2
  ndata=2*ndata
  do i=1,ndata
     t=t+dt
     j=int(t/tsymbol) + 1   !Symbol number, 1-207
     if(j.ne.j0) then
        f=f0 + (npr2(j)+2*symbol(j)-1.5) * dfgen * mode4
        if(flip.lt.0.0) f=f0+((1-npr2(j))+2*symbol(j)-1.5)*dfgen*mode4
        dphi=twopi*dt*f
        j0=j
     endif
     phi=phi+dphi
     iwave(i)=32767.0*sin(phi)
  enddo

  do j=1,5512                !Put another 0.5 sec of silence at end
     i=i+1
     iwave(i)=0
  enddo
  nwave=i

  if(flip.lt.0.0 .and. (ngrid.lt.32402 .or. ngrid.gt.32464)) then
     do i=22,1,-1
        if(msgsent(i:i).ne.' ') exit
     enddo
     msgsent=msgsent(1:i)//' OOO'
  endif
  do i=22,1,-1
     if(msgsent(i:i).ne.' ') goto 20
  enddo
20 nmsg=i

  return
end subroutine gen4

