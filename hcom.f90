  parameter (MAXI=10000,MAXJ=5)
  integer*2 np(0:32767,0:MAXJ)
  character*12 dcall(MAXI)
  character*4 dgrid(MAXI)
  common/hcom/nnp,np,dcall,dgrid
