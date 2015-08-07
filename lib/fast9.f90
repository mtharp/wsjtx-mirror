subroutine fast9(id2,narg,line)

! Decoder for "fast9" modes, JT9E to JT9H.

  parameter (NMAX=30*12000)
  integer*2 id2(0:NMAX)
  integer narg(0:11)
  integer*1 i1SoftSymbols(207)
  real s1(720000)                      !To reserve space.  Logically s1(nq,jz)
  real s2(240,340)                     !Symbol spectra at quarter-symbol steps
  real ss2(0:8,85)                     !Folded symbol spectra
  real ss3(0:7,69)                     !Folded spectra without sync symbols
  character*22 msg                     !Decoded message
  character*80 line(100)
  save s1,nsubmode0
  data nsubmode0/-1/

  nutc=narg(0)                         !narg() holds parameters from GUI
  npts=min(narg(1),NMAX)
  nsubmode=narg(2)
  if(nsubmode.lt.4) go to 900
  newdat=narg(3)
  minsync=narg(4)
  npick=narg(5)
  t0=0.001*narg(6)
  t1=0.001*narg(7)
  maxlines=narg(8)
  nmode=narg(9)
  nrxfreq=narg(10)
  ntol=narg(11)

  line(1:100)(1:1)=char(0)
  s=0
  s2=0
  nsps=60 * 2**(7-nsubmode)
  nfft=2*nsps
  nh=nfft/2
  nq=nfft/4
  istep=nsps/4
  jz=NMAX/istep
  df=12000.0/nfft
  db1=db(2500.0/df)
  nfa=max(200,nrxfreq-ntol)
  nfb=min(nrxfreq+ntol,2500)
  nline=0

  if(newdat.eq.1 .or. nsubmode.ne.nsubmode0) then
     call spec9f(id2,npts,nsps,s1,jz,nq)          !Compute symbol spectra, s1 
  endif
  nsubmode0=nsubmode
  tmsg=nsps*85.0/12000.0

  limit=1000
  nlen0=0
  do ilength=1,14
     nlen=1.4142136**(ilength-1)
     if(nlen.gt.jz/340) nlen=jz/340
     if(nlen.eq.nlen0) cycle
     nlen0=nlen
     db0=db(float(nlen))
     jlen=nlen*340
     jstep=jlen/4                      !### Is this about right? ###
     if(nsubmode.ge.6) jstep=jlen/2

     do ja=1,jz-jlen,jstep
        jb=ja+jlen-1
        call foldspec9f(s1,nq,jz,ja,jb,s2)        !Fold symbol spectra into s2

! Find sync; put sync'ed symbol spectra into ss2 and ss3
! Possibly should loop to get sorted list of best ccfs, first; then attempt 
! decoding from top down.  Might want to do a peakup in DT and DF, then
! re-compute symbol spectra.

! However... this simple approach works pretty well, as a start:

        call sync9f(s2,nq,nfa,nfb,ss2,ss3,lagpk,ipk,ccfbest)

        call softsym9f(ss2,ss3,snrdb,i1SoftSymbols)     !Compute soft symbols

        call jt9fano(i1SoftSymbols,limit,nlim,msg)      !Invoke Fano decoder
        t0=(ja-1)*istep/12000.0
        t1=(jb-1)*istep/12000.0
        nsnr=nint(snrdb) - db0 - db1             !### Is this OK? ###
!        if(nsnr.lt.-20) nsnr=-20
!        if(nsnr.gt.30)  nsnr=30.

        freq=ipk*df

!        write(*,3001) nlen,t0,t1,ccfbest,nsnr,nint(freq),lagpk,ipk,nlim,msg

        if(msg.ne.'                      ') then

!           write(71,3001) nlen,t0,t1,ccfbest,nsnr,nint(freq),lagpk,ipk,nlim,msg
!3001       format(i2,2f6.1,f9.2,4i6,i8,2x,a22)
!           flush(71)

! Display multiple decodes only if they differ:
           do n=1,nline
              if(index(line(n),msg).gt.1) go to 100
           enddo
!### Might want to use decoded message to get a complete estimate of S/N.
           nline=nline+1
           write(line(nline),1000) nutc,nsnr,t0,nint(freq),msg
1000       format(i6.6,i4,f5.1,i5,1x,'@',1x,a22)
           if(nline.eq.maxlines) go to 900
        endif
100     continue
     enddo
  enddo

900 return
end subroutine fast9
