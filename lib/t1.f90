program t1

  parameter (MZ=26,JZ=30)
  integer ic(MZ,JZ),icsave(MZ)
  real c(MZ)
  character*12 arg

  call getarg(1,arg)
  read(arg,*) nz
  
  do i=1,MZ                     !Create 4 mutually orthogonal codewords
     ic(i,1)=mod(i-1,4)
     ic(i,2)=mod(i,4)
     ic(i,3)=mod(i+1,4)
     ic(i,4)=mod(i+2,4)
  enddo

  do j=1,4                      !Write them out
     write(*,1000) j,MZ,ic(1:MZ,j)
1000 format(2i5,3x,26i2)
  enddo
 
  do j=5,JZ                     !Find codewords up to j=JZ with max 
     npk=0                      !distance from all the rest
     do i=1,nz
        call random_number(c)
        ic(1:MZ,j)=int(4*c)
        nd=MZ
        do k=1,j-1              !Test candidate against all others in list
           nd=min(nd,count(ic(1:MZ,j).ne.ic(1:MZ,k)))
        enddo
        if(nd.gt.npk) then
           npk=nd
           icsave=ic(1:MZ,j)    !Best candidate so far, save it
        endif
     enddo
     write(*,1000) j,npk,ic(1:MZ,j)
  enddo

end program t1
