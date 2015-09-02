subroutine hash(string,len,ihash)
  use iso_c_binding, only: c_loc
  use hashing
  parameter (MASK15=32767)
!  character*(*), target :: string
  character*1, target :: string
  integer*8 len
     i=nhash(c_loc(string),len,146)
     ihash=iand(i,MASK15)
  return
end subroutine hash
