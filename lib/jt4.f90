module jt4
  parameter (MAXAVE=120)
  integer iutc(MAXAVE)
  integer nflag(MAXAVE)
  integer iseg(MAXAVE)
  integer nfsave(MAXAVE)
  integer listutc(10)
  real    ppsave(207,7,MAXAVE)
  real    dtsave(MAXAVE)
  real    snrsave(MAXAVE)
  integer nsave,nlist,ich1,ich2
  integer nch(7)
  integer npr(207)
  data nch/1,2,4,9,18,36,72/
  data npr/                                                         &
       0,0,0,0,1,1,0,0,0,1,1,0,1,1,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0, &
       0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,0,0, &
       1,0,0,1,0,0,1,1,1,1,1,0,0,0,1,0,1,0,0,0,1,1,1,1,0,1,1,0,0,1, &
       0,0,0,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,0,1,0,1, &
       0,1,1,1,0,0,1,0,1,1,0,1,1,1,1,0,0,0,0,1,1,0,1,1,0,0,0,1,1,1, &
       0,1,1,1,0,1,1,1,0,0,1,0,0,0,1,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1, &
       1,0,0,1,1,0,0,0,0,1,1,0,0,0,1,0,1,1,0,1,1,1,1,0,1,0,1/
end module jt4
