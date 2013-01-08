subroutine wsprd_init(ntrminutes,f0,infile)

  real*8 f0
  character arg*12,infile*80

  ntrminutes=2
  f0=0.
  nargs=iargc()
  j=0
  do i=1,999
     j=j+1
     call getarg(j,arg)
     if(arg(1:2).eq.'-m') then
        j=j+1
        call getarg(j,arg)
        read(arg,*) ntrminutes
     else if(arg(1:2).eq.'-f') then
        j=j+1
        call getarg(j,arg)
        read(arg,*) f0
     else
        call getarg(j,infile)
     endif
     if(j.ge.nargs) exit
  enddo

  return
end subroutine wsprd_init
