program t3

  character cutc*6

  read*,cutc
  read*,cutc
  read*,cutc

  s1=0.
  s2=0.
  ns=0

  do i=1,9999
     read(*,*,end=999) cutc,nn,naz,nel,db,snr,df,w,p
     if(abs(df).lt.2.0 .and. snr.gt.10.0) then
        s1=s1+df
        s2=s2+w
        ns=ns+1
     endif
     if(mod(i,10).eq.0) then
        read(cutc,1000) ih,im,is
1000    format(3i2)
        if(ih.lt.15) ih=ih+24
        uth=ih + im/60.0 + is/3600.0
        write(*,1010) uth,s1/ns,s2/ns,s1/(3*ns),s2/(3*ns)
1010    format(f10.6,4f8.3)
        s1=0.
        s2=0.
        ns=0
     endif
  enddo

999 end program t3
