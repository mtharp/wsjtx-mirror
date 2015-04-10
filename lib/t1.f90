program t1

  parameter (MZ=26,JZ=30)
  integer ic(MZ,JZ)
  real c(MZ)
  character*12 arg

  call getarg(1,arg)
  read(arg,*) nz
  
  do i=1,MZ
     ic(i,1)=mod(i-1,4)
     ic(i,2)=mod(i,4)
     ic(i,3)=mod(i+1,4)
     ic(i,4)=mod(i+2,4)
  enddo

  do j=1,4
     write(*,1000) j,MZ
1000 format(2i5)
  enddo
 
  do j=5,JZ
     npk=0
     do i=1,nz
        call random_number(c)
        ic(1:MZ,j)=int(4*c)
        nd=MZ
        do k=1,j-1
           nd=min(nd,count(ic(1:MZ,j).ne.ic(1:MZ,k)))
        enddo
        if(nd.gt.npk) then
           npk=nd
        endif
     enddo
     write(*,1000) j,npk
  enddo

end program t1
