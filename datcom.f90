parameter (NSMAX=60*96000)          !Samples per 60 s file
real*8 fcfile
real*4 dd                           !92 MB: raw data from Linrad timf2
character*80 fname80
common/datcom/dd(2,NSMAX,2),nutc,newdat2,kbuf,kxp,kk,kkdone,nlost,   &
     nlen,fname80
equivalence (id,fcfile)
