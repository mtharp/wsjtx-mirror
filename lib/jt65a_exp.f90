subroutine jt65a(dd0,npts,newdat,nutc,nf1,nf2,nfqso,ntol,nsubmode,   &
     minsync,nagain,ndecoded)

!  Process dd0() data to find and decode JT65 signals.

  parameter (NSZ=3413,NZMAX=60*12000)
  parameter (NFFT=1000)
  real dd0(NZMAX)
  real dd(NZMAX)
  integer*2 id2(NZMAX)
  real ss(322,NSZ)
  real savg(NSZ)
  real a(5)
  character*22 decoded,decoded0
  type candidate
     real freq
     real dt
     real sync
  end type candidate
  type(candidate) ca(300)
  type decode
     real freq
     real dt
     real sync
     character*22 decoded
  end type decode
  type(decode) dec(30)
  common/decstats/num65,numbm,numkv,num9,numfano
  common/steve/thresh0
  save

  dd=0.
  tpad=2.0
  npad=12000*tpad
  dd(1+npad:npts+npad)=dd0(1:npts)
  npts=npts+npad
  ndecoded=0

  do iii=1,2 ! 2-pass decoding loop
    newdat=1
    if(iii.eq.1) then !first-pass parameters
      thresh0=2.5
      nsubtract=1
    elseif( iii.eq.2 ) then !second-pass parameters
      thresh0=2.5
      nsubtract=0
    endif

!  if(newdat.ne.0) then
     call timer('symsp65 ',0)
     ss=0.
     call symspec65(dd,npts,ss,nhsym,savg)    !Get normalized symbol spectra
     call timer('symsp65 ',1)
!  endif
    nfa=nf1
    nfb=nf2
!  if(newdat.eq.0) then
!  if(newdat.eq.0 .or. nfqso.eq.1270) then
!     nfa=nfqso-ntol
!     nfb=nfqso+ntol
!  endif

    ncand=0
    call timer('sync65  ',0)
    call sync65(ss,nfa,nfb,nhsym,ca,ncand)    !Get a list of JT65 candidates
    call timer('sync65  ',1)

!    write(*,*) iii, ncand, nfa, nfb,newdat

    df=12000.0/NFFT                     !df = 12000.0/8192 = 1.465 Hz
    mode65=2**nsubmode
    nflip=1                             !### temporary ###
    nqd=0
    decoded0=""

    do icand=1,ncand
      freq=ca(icand)%freq
      dtx=ca(icand)%dt
      sync1=ca(icand)%sync
      call timer('decod65a',0)
      call decode65a(dd,npts,newdat,nqd,freq,nflip,mode65,sync2,a,dtx,   &
          nbmkv,nhist,decoded)
      call timer('decod65a',1)
      if(decoded.eq.decoded0) cycle            !Don't display dupes

!     if(decoded.ne.'                      ') then
      if(decoded.ne.'                      ' .or. minsync.lt.0) then
        if( nsubtract .eq. 1 ) then
           call timer('subtr65 ',0)
           call subtract65(dd,npts,freq,dtx)
           call timer('subtr65 ',1)
        endif
        nfreq=nint(freq+a(1))
        ndrift=nint(2.0*a(2))
        s2db=10.0*log10(sync2) - 32             !### empirical (was 40) ###
        nsnr=nint(s2db)
        if(nsnr.lt.-30) nsnr=-30
        if(nsnr.gt.-1) nsnr=-1
        dtx=dtx-tpad
        if(nbmkv.eq.1) numbm=numbm+1
        if(nbmkv.eq.2) numkv=numkv+1

! Serialize writes - see also decjt9.f90
!$omp critical(decode_results) 
        ndupe=0 ! de-dedupe
        do i=1, ndecoded
          if( decoded==dec(i)%decoded ) ndupe=1
        enddo
        if( ndupe .ne. 1 ) then
          ndecoded=ndecoded+1
          dec(ndecoded)%freq=freq
          dec(ndecoded)%dt=dtx
          dec(ndecoded)%sync=sync2
          dec(ndecoded)%decoded=decoded
          write(*,1010) iii,nutc,nsnr,dtx,nfreq,decoded
1010      format(i1,2x,i4.4,i4,f5.1,i5,1x,'#',1x,a22)
          write(13,1012) nutc,nint(sync1),nsnr,dtx,float(nfreq),ndrift,  &
             decoded,nbmkv
1012      format(i4.4,i4,i5,f6.1,f8.0,i4,3x,a22,' JT65',i4)
          call flush(6)
          call flush(13)
        endif
!$omp end critical(decode_results)
      endif
    enddo !candidate loop

  enddo !two-pass loop

!  id2(1:npts)=dd(1:npts)
!  write(56) id2(1:npts)

!     if(nagain.eq.1) exit
!  enddo

  return
end subroutine jt65a
