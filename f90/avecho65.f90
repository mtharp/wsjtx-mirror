subroutine avecho65(cc,dop,nn,techo,fspread,fsample,i00,dphi,t0,f1a,     &
     dl,dc,pol,delta,rms1,rms2,snr,sigdb,dfreq,width,red,blue)

  parameter (NZ=520000,NZH=NZ/2,NTX=27*8192)
  parameter (NFFT=256*1024)
  complex cc(2,NZ)
  complex cx(0:NFFT-1),cy(0:NFFT-1)
  complex csx(-1000:1000),csy(-1000:1000)
  complex z
  real*4 sx(-1000:1000),sy(-1000:1000)
  real blue(2000),red(2000)
  integer ipkv(1)
  equivalence (ipk,ipkv)
  save sx,sy
  abs2(z)=real(z)*real(z) + aimag(z)*aimag(z)


  if(nn.eq.0) then
     sx=0.
     sy=0.
  endif

  nn=nn+1
  if(nn.gt.100) nn=1
  cx(0:NZH-1)=cc(1,1:NZH)
  cy(0:NZH-1)=cc(2,1:NZH)

  call txtone(cx,tx,f1x)
  call txtone(cy,ty,f1y)
  t0=(tx+ty)/2.0
  f1a=(f1x+f1y)/2.0
  istart=nint((t0+techo)*fsample)
  cx(0:NTX-1)=cc(1,istart:istart+NTX-1)
  cx(NTX:)=0.
  cy(0:NTX-1)=cc(2,istart:istart+NTX-1)
  cy(NTX:)=0.
  fdop=f1a+dop

  sq1=0.
  sq2=0.
  do i=0,NTX
     sq1=sq1 + abs2(cx(i))
     sq2=sq2 + abs2(cy(i))
  enddo
  rms1=sqrt(0.5*sq1/NTX)
  rms2=sqrt(0.5*sq2/NTX)

  call cspec(cx,fdop,csx)
  call cspec(cy,fdop,csy)

!  open(21,file='emecho.dat',status='unknown',access='stream',position='append')
!  write(21) dop,techo,fspread,dphi,csx,csy
!  close(21)

!### Do the following only when nn=1 ??  Or only on "first" call ??
  smax=0.
  do i=-200,200
     sx(i)=sx(i) + abs2(csx(i))
     sy(i)=sy(i) + abs2(csy(i))
     if(sx(i).gt.smax .or. sy(i).gt.smax) then
        smax=max(sx(i),sy(i))
        i0=i
     endif
  enddo

!###  i0=i00
  call polfit(csx,csy,nn,i0,dphi,dl,dc,pol,delta,red,blue)

  ave=min(sum(red(1101:1500))/400.,sum(red(1501:1900))/400.)
  sq1=dot_product(red(1101:1500)-ave,red(1101:1500)-ave)
  sq2=dot_product(red(1501:1900)-ave,red(1501:1900)-ave)
  rms=sqrt(min(sq1,sq2)/399.0)
  redmax=maxval(red(950:1050))
  snr=min(99.9,(redmax-ave)/rms)
  ipkv=maxloc(red(951:1050))+950
  df=fsample/NFFT
  dfreq=(ipk-1001)*df

  s=0.
  do i=ipk,ipk+300
     if(red(i).lt.1.0) exit
     s=s+(red(i)-ave)
  enddo
  do i=ipk-1,ipk-300,-1
     if(red(i).lt.1.0) exit
     s=s+(red(i)-ave)
  enddo
  bins=s/(red(ipk)-ave)
  width=df*bins

  sigdb=-99.0
  if(ave.gt.0.0) sigdb=10.0*log10(redmax/ave - 1.0) - 35.7

  open(20,file='emecho.txt',status='unknown',access='append')
!  write(20,1010) nn,nint(dphi),t0,nint(f1a),dl,dc,nint(pol),nint(delta),rms1,rms2,snr,sigdb,dfreq,width
!1010 format(i3,i4,f5.2,i6,2f5.1,i4,i3,3f5.1,f6.1,2f5.1)
  ndphi=nint(dphi)
  nf1a=nint(f1a)
  npol=nint(pol)
  ndelta=nint(delta)
!  write(20,1010) nn,ndphi,t0,nf1a,dl,dc,npol,ndelta,rms1,rms2,snr,sigdb,dfreq,width
!1010 format(i3,i4,f5.2,i6,2f5.1,i4,i4,3f5.1,f6.1,f6.1,f5.1)
  ndphi=nint(dphi)
  nf1a=nint(f1a)
  npol=nint(pol)
  ndelta=nint(delta)
  rms1=min(99.9,rms1)
  rms2=min(99.9,rms2)
  write(20,1010) nn,ndphi,t0,nf1a,dl,dc,npol,ndelta,rms1,rms2,snr,sigdb,dfreq,width
1010 format(i3,i4,f5.2,i7,2f5.1,i4,i5,2f5.1,2f6.1,f6.1,f5.1)
  close(20)

  return
end subroutine avecho65
