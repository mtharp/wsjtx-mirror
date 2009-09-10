      subroutine genmet(mode,bias,mettab)

C  Return appropriate metric table for soft-decision convolutional decoder.

      real bias                         !bias for integer table
      integer scale                     !scale factor for integer table
C Metric table (RxSymbol,TxSymbol)
      integer mettab(0:255,0:1)

      if(mode.eq.6) then       !JT2, DBPSK
         open(19,file='dmet_20_-2_2.dat',status='old')
         scale=20
      else if(mode.eq.7) then  !Non-coherent 2FSK
         open(19,file='dmet_10_-1_3.dat',status='old')
         scale=10
      else if(mode.eq.64) then  !Non-coherent 64-FSK
         open(19,file='met64.21',status='old')
         scale=10
      else
         print*,'Unsupported mode:',mode,' in genmet.'
         stop
      endif

      do i=0,255
         read(19,*) xjunk,d0,d1
         mettab(i,0)=nint(scale*(d0-bias))
         mettab(i,1)=nint(scale*(d1-bias))
      enddo

      return
      end

