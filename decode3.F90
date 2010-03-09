subroutine decode3(d2,jz,istart,filename)

#ifdef CVF
  use dfport
#endif

  integer*2 d2(jz),d2d(125*12000)
  character*24 filename
  character FileID*40
  include 'gcom1.f90'
  include 'gcom2.f90'
  
  if(ichar(filename(1:1)).eq.0) go to 999
    
  FileID=filename
  decodedfile=filename
  lumsg=11
  if(mode(1:4).eq.'JT64') then
     if(mode(5:5).eq.'A') mode64=1
     if(mode(5:5).eq.'B') mode64=2
     if(mode(5:5).eq.'C') mode64=4
  endif

  sum=0.
  do i=1,jz
     sum=sum+d2(i)
  enddo
  nave=nint(sum/jz)
  do i=1,jz
     d2(i)=d2(i)-nave
     d2d(i)=d2(i)
  enddo

  nseg=1
  if(mode(1:4).eq.'JT64') then
     i=index(FileID,'.')-3
     if(FileID(i:i).eq.'1'.or.FileID(i:i).eq.'3'.or.FileID(i:i).eq.'5'  &
          .or.FileID(i:i).eq.'7'.or.FileID(i:i).eq.'9') nseg=2
  endif
  if(mode(1:4).eq.'JTMS') NZap=0

  call cs_lock('decode3')
  open(23,file=appdir(:lenappdir)//'/CALL3.TXT',status='unknown')
  call cs_unlock

  call wsjt1(d2d,jz,istart,FileID,ndepth,                         &
       MinSigdB,DFTolerance,MouseButton,NClearAve,nforce,         &
       mode,NFreeze,NAFC,NZap,mode64,mode4,idf,ntdecode,          &
       MyCall,HisCall,HisGrid,ntx2,s2,                            &
       ps0,npkept,lumsg,basevb,rmspower,nslim2,psavg,ccf,Nseg,    &
       MouseDF,NAgain,LDecoded,nspecial,ndf,ss1,ss2)
  nforce=0
  ntx2=0
  close(23)
  if(basevb.le.-98.0) go to 999

! See whether this file should be saved or erased from disk
  if(nsave.eq.1 .and. ldecoded) filetokilla=''
  if(nsave.eq.3 .or. (nsave.eq.2 .and. lauto.eq.1)) then
     filetokilla=''
     filetokillb=''
  endif
  if(nsavelast.eq.1) filetokillb=''
  nsavelast=0
  ierr=unlink(filetokillb)
  
  nclearave=0
  nagain=0
  if(mode(1:4).eq.'JT64' .or. mode(1:5).eq.'ISCAT'.or. mode(1:3).eq.'JT8') then
     call pix2d64(d2d,jz)
  else if(mode(1:4).eq.'JTMS') then
     nz=s2(1,1)
     call pix2d(d2d,jz,mousebutton,MouseDF,NFreeze,mode,ngreen,s2,64,nz,b)
  endif

999 return
end subroutine decode3
