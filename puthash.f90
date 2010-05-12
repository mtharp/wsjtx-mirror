subroutine puthash(c1,g1,ih,jz)

! Manage the call/grid hash table

  character c1*12,g1*4
  include 'hcom.f90'

  ih=-1
  jz=-1
  i1=index(c1,' ')
  if(i1.lt.4) go to 900            !Abort if c1 is too short for a callsign
  call hash(c1,i1-1,ih)            !Get hash code

  jz=np(ih,0)                      !Number already stored with this code?
  if(jz.eq.0) then                 !If none, store c1/g1 as a new entry
     nnp=nnp+1
     dcall(nnp)=c1
     dgrid(nnp)=g1
     np(ih,0)=1
     np(ih,1)=nnp
  else
     do j=1,jz
        i=np(ih,j)
        if(c1.eq.dcall(i)) then    !This call already stored?
           if(g1.eq.'    ') dgrid(i)=g1  !Yes, save grid if available
           go to 10
        endif
     enddo
     nnp=nnp+1                     !New call, must make a new entry
     k=np(ih,1)
     dcall(nnp)=dcall(k)           !Move existing entry #1 to end of list
     dgrid(nnp)=dgrid(k)
     dcall(k)=c1                   !New entry becomes j=1
     dgrid(k)=g1
     np(ih,0)=jz+1                 !Increment jz
     np(ih,jz+1)=nnp
  endif
10 jz=np(ih,0)                     !Return final value of jz

900 return
end subroutine puthash
