program simsync

  parameter (NMAX=1000)
  real sym(0:1,240)
  real ccf(-10:20)
  character*12 arg
  integer isync(207)
  data isync/                                                       &
       0,0,0,0,1,1,0,0,0,1,1,0,1,1,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0, &
       0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,0,0, &
       1,0,0,1,0,0,1,1,1,1,1,0,0,0,1,0,1,0,0,0,1,1,1,1,0,1,1,0,0,1, &
       0,0,0,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,0,1,0,1, &
       0,1,1,1,0,0,1,0,1,1,0,1,1,1,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,1, &
       0,1,1,1,0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1, &
       1,0,0,1,1,0,0,0,0,1,1,0,0,0,1,0,1,1,0,1,1,1,1,0,1,0,1/

  nargs=iargc()
  if(nargs.ne.3) then
     print*,'Usage: simsync nadd snr iters'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) nadd
  call getarg(2,arg)
  read(arg,*) snrdb
  sig0=10.0**(0.05*snrdb) * (1.0/nadd)**0.25
  call getarg(3,arg)
  read(arg,*) iters

  write(*,1010) 
1010 format(/'  EsNo  EbNo  db65    sync'/  &
             '---------------------------')

  rate=0.350
  baud=nadd*11025.0/2520.0
  idb1=0
  idb2=-20
  if(snrdb.ne.0.0) idb2=idb1
  do idb=idb1,idb2,-1
     EsNo=idb
     if(snrdb.ne.0.0) EsNo=snrdb
     EbNo=EsNo - 10.0*log10(rate)
     db65=EsNo - 10.0*log10(2500.0/baud)
     sig0=sqrt(10.0**(0.1*EsNo))                !Signal level

     ngood=0
     do iter=1,iters
        do j=1,240
           sig=0.
           s0=0.
           s1=0.
           if(j.ge.11 .and. j.le.217) sig=sig0
           do n=1,nadd
              x=0.707107*gran()
              y=0.707107*gran()
              s0=s0 + x**2 + y**2
              x=0.707107*gran()
              y=0.707107*gran()
              s1=s1 + (x+sig)**2 + y**2
           enddo
           s0=s0/nadd
           s1=s1/nadd
           if(j.ge.11 .and. j.le.217) then
              if(isync(j-10).eq.1) then
                 sym(0,j)=s0
                 sym(1,j)=s1
              else
                 sym(0,j)=s1
                 sym(1,j)=s0
              endif
           else
              sym(0,j)=s0
              sym(1,j)=s1
           endif
        enddo

        sq=0.
        ccfmax=0.
        ccf=0.
        lagpk=-99
        do lag=-10,20
           ccf(lag)=0.
           do i=1,207
              k=isync(i)
              j=i+10+lag
              ccf(lag)=ccf(lag) + sym(k,j) - sym(1-k,j)
           enddo
           if(ccf(lag).gt.ccfmax) then
              ccfmax=ccf(lag)
              lagpk=lag
           else
              sq=sq + ccf(lag)**2
           endif
!        write(15,3001) lag,ccf(lag)
!3001    format(i3,f12.3)
        enddo
        if(lagpk.eq.0) ngood=ngood+1
        rms=sqrt(sq/30.0)
        snr=ccfmax/rms
!     write(*,1010) iter,lagpk,snr
!1010 format(i10,i4,f6.2)
     enddo
     fsync=float(ngood)/iters
     write(*,1020)  EsNo,EbNo,db65,fsync
1020 format(3f6.1,f9.4)
  enddo

999 end program simsync
