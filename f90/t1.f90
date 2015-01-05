program t1

  character cutc*6

  read*,cutc
  read*,cutc
  read*,cutc

  dp=0.
  p0=0.
  do i=1,9999
     read(*,*,end=999) cutc,nn,naz,nel,db,snr,df,w,p
     if((p-p0).lt.-90.0) dp=dp+180.0
     if((p-p0).ge.90.0) dp=dp-180.0
     p0=p
     read(cutc,1000) ih,im,is
1000 format(3i2)
     if(ih.lt.15) ih=ih+24
     uth=ih + im/60.0 + is/3600.0
     pdp=p+dp
     if(uth.gt.33.83 .and. uth.lt.34.44) pdp=pdp+180
     write(*,1010) uth,nint(pdp),nint(p),nint(dp)
1010 format(f10.6,3i6)
  enddo

999 end program t1
