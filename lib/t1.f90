program t1

  parameter (NMAX=10000000,M=26)
  integer ic(M,NMAX)
  integer ndist(NMAX)
  real c(M)

  do i=1,NMAX
     call random_number(c)
     ic(1:M,i)=int(4*c)
  enddo

  do j=1,NMAX
     ndist(j)=count(ic(1:M,j).ne.ic(1:M,1))
     if(ndist(j).le.10) write(13,1000) j,ndist(j)
1000 format(2i10)
  enddo

end program t1
