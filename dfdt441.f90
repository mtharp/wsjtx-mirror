subroutine dfdt441(dat,jz,freezedf,dftol,tmsg,nmsg,xdfpk,idtpk,sbest,ppk)

! Get DF, DT, and possibly ppk (message length) from FSK441 data

  real dat(jz)
  character*28 tmsg
  real s1(jz)
  real s2(jz)
  real acf(500)
  real p(28*3*25)                           !Folded s2
  integer itone(3*28)                       !Tones of test message
  complex cz(3*28*25)                       !Complex LO for test message
  complex csum
  data twopi/6.2831853/

  nstep=5
  fdiv=5.
  call gen441(tmsg,nmsg,itone)
  nsamp=75*nmsg
  df0=441.0                                 !Tone spacing
  dt=1.0/11025.0                            !Sample interval
  df=11025.0/(fdiv*nsamp)
  ndf=dftol/df
  sbest=0.

! 1. Loop over idf, idt to find best match to tmsg

  do idf=-ndf,ndf                           !Loop over range of DF
     xdf=idf*df
     phi=0.                                 !Initialize phase
     j0=999
     do i=1,nsamp                      !Generate conjugate of message waveform
        j=(i-1)/25 + 1
        if(j.ne.j0) then
           freq=882.0 + freezedf + xdf + itone(j)*df0
           dphi=twopi*freq*dt
           j0=j
        endif
        phi=phi+dphi
        cz(i)=0.001*cmplx(cos(phi),-sin(phi))
     enddo

     k=0
     do idt=0,jz-nsamp,nstep                !Loop over time offset DT
        k=k+1
        csum=0.
        do i=1,nsamp
           csum=csum + cz(i)*dat(i+idt)
        enddo
        s=real(csum)**2 + aimag(csum)**2
        s1(k)=s
        if(s.gt.sbest) then
           sbest=s                          !Save best DF, DT
           idfpk=idf
           idtpk=idt
        endif
     enddo
     if(idfpk.eq.idf) s2(1:k)=s1(1:k)       !Save s2=s1 at best idf
  enddo
  kz=k
  xdfpk=idfpk*df

  do k=1,kz                                 !Write s2 (ccf with tmsg) to disk
     write(13,1040) k,s2(k)
1040 format(i5,f10.0)
  enddo

  do lag=0,2500/nstep                       !Compute acf of s2
     sum=0.
     do i=1,kz-lag
        sum=sum + s2(i)*s2(i+lag)
     enddo
     acf(lag)=1.e-3*sum/(kz-lag)
     tp=lag*nstep/75.0
     write(14,1050) lag,tp,acf(lag)         !Write acf to disk
1050 format(i5,f10.3,f13.3)
     if(tp.gt.1.5 .and. acf(lag).gt.acfmax) then
        acfmax=acf(lag)
        ppk=tp
     endif
  enddo

! 2. If there's a well defined period, do a "folded search" with
!    incoherent summation over message repetitions.

! 3. Peak up by doing a fine-grained search around idfpk, idtpk ...
!    or use the peakup() routine for +/- 1 step in each coordinate.

  return
end subroutine dfdt441
