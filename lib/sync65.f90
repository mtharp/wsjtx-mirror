subroutine sync65(ss,nfa,nfb,nhsym,ca,ncand)

  parameter (NSZ=3413,NFFT=8192)
  real ss(322,NSZ)
  real ccfblue(-5:540)             !CCF with pseudorandom sequence
  real ccfred(NSZ)                 !Peak of ccfblue, as function of freq
  
  type candidate
     real freq
     real dt
     real sync
  end type candidate
  type(candidate) ca(300)

  call setup65
  df=12000.0/NFFT                            !df = 12000.0/16384 = 0.732 Hz
  ia=nfa/df
  ib=nfb/df
  lag1=-5
  lag2=59
  nsym=126
  thresh0=2.0
  ncand=0
  fdot=0.
  ccfred=0.
  ccfblue=0.

  do i=ia,ib
     call xcor(ss,i,nhsym,nsym,lag1,lag2,ccfblue,ccf0,lagpk0,flip,fdot)
! Remove best-fit slope from ccfblue and normalize so baseline rms=1.0
     call slope(ccfblue(lag1),lag2-lag1+1,lagpk0-lag1+1.0)
     ccfred(i)=ccfblue(lagpk0)
  enddo
  call pctile(ccfred(ia:ib),ib-ia+1,35,xmed)
  ccfred(ia:ib)=ccfred(ia:ib)-xmed
  ccfred(ia-1)=ccfred(ia)
  ccfred(ib+1)=ccfred(ib)

  do i=ia,ib
     freq=i*df
     itry=0
     if(ccfred(i).gt.thresh0 .and. ccfred(i).gt.ccfred(i-1) .and.       &
          ccfred(i).gt.ccfred(i+1)) then
        itry=1
        ncand=ncand+1
     endif
!     write(79,1010) i,freq,ccfred(i),itry,ncand
!1010 format(i6,2f10.2,i5,i6)
!     flush(79)
     if(itry.ne.0) then
        call xcor(ss,i,nhsym,nsym,lag1,lag2,ccfblue,ccf0,lagpk,flip,fdot)
        call slope(ccfblue(lag1),lag2-lag1+1,lagpk-lag1+1.0)
        xlag=lagpk
        if(lagpk.gt.lag1 .and. lagpk.lt.lag2) then
           call peakup(ccfblue(lagpk-1),ccfmax,ccfblue(lagpk+1),dx2)
           xlag=lagpk+dx2
        endif
        dtx=xlag*2048.0/11025.0 - 2.7   !### empirical
        ccfblue(lag1)=0.
        ccfblue(lag2)=0.
!        do j=lag1,lag2
!           write(14,1020) j,ccfblue(j)
!1020       format(i5,f10.3)
!        enddo
        ca(ncand)%freq=freq
        ca(ncand)%dt=dtx
        ca(ncand)%sync=ccfred(i)
     endif
  enddo

  return
end subroutine sync65
