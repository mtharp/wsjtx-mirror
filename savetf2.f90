subroutine savetf2(id,fnamedate,savedir,fhdr)

  parameter (NZ=60*96000)
  parameter (NSPP=174)
  parameter (NPKTS=NZ/NSPP)
  integer*2 id(2,NZ)
  real*8 fhdr
  character*80 savedir,fname
  character cdate*8,ctime2*10,czone*5,fnamedate*6
  integer  itt(8)

  call date_and_time(cdate,ctime2,czone,itt)
  nh=itt(5)-itt(4)/60
  nm=itt(6)
  ns=itt(7)
  if(ns.lt.50) nm=nm-1
  if(nm.lt.0) then
     nm=nm+60
     nh=nh-1
  endif
  if(nh.lt.0) nh=nh+24
  if(nh.ge.24) nh=nh-24

  call cs_lock('savetf2')
  write(fname,1001) fnamedate,nh,nm
1001 format('/',a6,'_',2i2.2,'.iq')
  do i=80,1,-1
     if(savedir(i:i).ne.' ') go to 1
  enddo
1 iz=i
  fname=savedir(1:iz)//fname
  open(17,file=fname,status='unknown',access='stream',err=998)
  write(17,err=997) fhdr,id
  close(17)
  go to 999

997 print*,'Error writing *.iq file'
  print*,fname
  go to 999

998 print*,'Cannot open file:'
  print*,fname

999 continue
  call cs_unlock
  return
end subroutine savetf2

