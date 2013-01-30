subroutine rfile2(fname,buf,n,nr)

! Read a binary file.

  integer*1 buf(n)
  character fname*(*)

  open(10,file=fname,access='stream',status='old')
  read(10,end=10) buf
10 close(10)
  
  return
end subroutine rfile2
