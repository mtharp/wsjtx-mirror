      subroutine decode1a(id,newdat,freq,nflip,mode65,
     +         mycall,hiscall,hisgrid,neme,ndepth,nqd,dphi,ndphi,
     +         sync2,a,dt,nkv,nhist,qual,decoded)

C  Apply AFC corrections to a candidate JT65 signal, and then try
C  to decode it.

      parameter (NFFT1=77760,NFFT2=2430)
      parameter (NMAX=60*96000)          !Samples per 60 s
      integer*2 id(2,NMAX)               !46 MB: raw data from Linrad timf2
      complex cx0(NMAX/64)               !Data at 1378.125 samples/s
      complex cx(NMAX/64)                !Data at 1378.125 samples/s
      complex c5x(NMAX/256)              !Data at 344.53125 samples/s
      complex c5a(256),c5b(256)
      complex z

      real s2(256,126)
      real a(5)
      real*8 samratio
      logical first
      character decoded*22
      character mycall*12,hiscall*12,hisgrid*6
      data first/.true./,jjjmin/1000/,jjjmax/-1000/
      save

C  Mix sync tone to baseband, low-pass filter, and decimate by 64
      dt00=dt
C  If freq=125.0 kHz, f0=48000 Hz.
      f0=1000*(freq-77.0)                  !Freq of sync tone (0-96000 Hz)
      call filbig(id,NMAX,f0,newdat,cx0,n5)
C Move data later by 1 s.  (This is a kludge.)
      do i=1,1378
         cx(i)=0.
      enddo
      do i=1,n5
         cx(1378+i)=cx0(i)
      enddo

      joff=0
      sqa=0.
      do i=1,n5
         sqa=sqa + real(cx(i))**2 + aimag(cx(i))**2
      enddo
      sqa=sqa/n5
      sqb=sqb/n5

C  Find best DF, f1, f2, DT.  Start by lpf and downsampling to 344.53125 Hz.
      call fil6521(cx,n5,c5x,n6)
      fsample=1378.125/4.
      a(5)=dt00
      i0=nint((a(5)+0.5)*fsample) - 2
      if(i0.lt.1) i0=1
      nz=n6+1-i0

C Best fit for DF, f1, f2:
      call afc65b(c5x(i0),nz,fsample,nflip,a,dt,ccfbest,dtbest)
      sq0=sqa
      sync2=3.7*ccfbest/sq0

C Apply AFC corrections to the time-domain signal.  (We're back to
C full bandwidth now, at the 1378.125 Hz sample rate.)
      call twkfreq(cx,cx,n5,a)                           !###

C Compute spectrum at best polarization for each symbol.  This is done
C for whole symbols in JT65A, half-symbols in JT65B, and quarter-symbols
C in JT65C.
C NB: Adding or subtracting a small number (e.g., 5) to j may make it decode.
      nsym=126
      nfft=512/mode65
      j=(dt00+dtbest+2.685)*1378.125 + joff
      if(j.lt.0) j=0
      do k=1,nsym
         do n=1,mode65
            do i=1,nfft
               j=j+1
               c5a(i)=cx(j)
            enddo
            call four2a(c5a,nfft,1,1,1)
            if(n.eq.1) then
               do i=1,64
                  s2(i,k)=real(c5a(i))**2 + aimag(c5a(i))**2
               enddo
            else
               do i=1,64
                  s2(i,k)=s2(i,k) + real(c5a(i))**2 + aimag(c5a(i))**2
               enddo
            endif
         enddo
      enddo

      flip=nflip
      call decode65b(s2,flip,mycall,hiscall,hisgrid,neme,ndepth,
     +    nqd,nkv,nhist,qual,decoded)
      dt=dt00 + dtbest
      a(4)=0.

      return
      end
