subroutine jt4a(dd,jz,nutc,nfqso,newdat,nfa,nfb,ntol0,nagain,ndepth,      &
          nsubmode,mycall,mygrid,hiscall,hisgrid)

  real*4 dd(jz)
  real*4 dat(30*12000)
  real*4 ccf(-5:540)
  real*4 psavg(450)
  real*4 ps0(450)
  character*6 cfile6
  character*12 mycall,hiscall
  character*6 mygrid,hisgrid

  NClearAve=0
  MinSigdB=0
  ntol=600
  NFreeze=0
  mode=7
  mode4=1
  minwidth=1                      !MinW ?
  Nseg=1                          !???
  MouseDF2=nfqso - 1270
!  NAgain=0
!  ndepth=3
  neme=1
  idf=0                           !???
  lumsg=6                         !### temp ? ###
  ndiag=1

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

  call wsjt4(dat,jz2,cfile6,NClearAve,MinSigdB,                          &
       ntol,NFreeze,mode,mode4,minwidth,mycall,hiscall,hisgrid,   &
       Nseg,MouseDF2,NAgain,ndepth,neme,idf,lumsg,nspecial,ndf,     &
       NSyncOK,ccf,psavg,ndiag,ps0)

  return
end subroutine jt4a
