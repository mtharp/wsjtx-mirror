subroutine jt4a(dd,jz,nutc,nfqso,newdat,nfa,nfb,ntol0,nagain,ndepth,      &
          nclearave,minw,nsubmode,mycall,mygrid,hiscall,hisgrid,nlist0,   &
          listutc0)

  use jt4
  integer listutc0(10)
  real*4 dd(jz)
  real*4 dat(30*12000)
  real*4 ccf(-5:540)
  real*4 psavg(450)
  real*4 ps0(450)
  character*6 cfile6
  character*12 mycall,hiscall
  character*6 mygrid,hisgrid

  mode4=nch(nsubmode+1)
  MinSigdB=0
  ntol=ntol0
  NFreeze=1
  mode=7
!  NAgain=0
!  ndepth=3
  neme=1
  lumsg=6                         !### temp ? ###
  ndiag=1
  nlist=nlist0
  listutc=listutc0

! Lowpass filter and decimate by 2
  call lpf1(dd,jz,dat,jz2)

  i=index(MyCall,char(0))
  if(i.le.0) i=index(MyCall,' ')
  mycall=MyCall(1:i-1)//'            '
  i=index(HisCall,char(0))
  if(i.le.0) i=index(HisCall,' ')
  hiscall=HisCall(1:i-1)//'            '

  write(cfile6(1:4),1000) nutc
1000 format(i4.4)
  cfile6(5:6)='  '

  call wsjt4(dat,jz2,nutc,NClearAve,MinSigdB,ntol,mode4,   &
       minw,mycall,hiscall,hisgrid,nfqso,NAgain,ndepth,neme,nspecial,   &
       NSyncOK,ccf,psavg,ps0)

  return
end subroutine jt4a
