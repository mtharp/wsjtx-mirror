program polecho

  complex csx(-1000:1000),csy(-1000:1000)
  complex w,z
  real*4 red(2000),blue(2000)
  character arg*8,infile*60
  logical ok,done

  abs2(z)=real(z)*real(z) + aimag(z)*aimag(z)

  nargs=iargc()
  if(nargs.ne.6) then
     print*,'Usage: polecho yfac dphi nut1 nut2 nadd infile'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) yfac
  call getarg(2,arg)
  read(arg,*) dphi
  call getarg(3,arg)
  read(arg,*) nut1
  call getarg(4,arg)
  read(arg,*) nut2
  call getarg(5,arg)
  read(arg,*) nadd
  call getarg(6,infile)

  open(21,file=infile,status='old',access='stream')

  nok=0
  nblank=0
  k=0
  do iblk=1,9999
     nn=0
     do ip=1,nadd
10      k=k+1
        read(21,end=100) nutc,naz,nel,dop,techo,fspread,csx,csy
        if(nutc.lt.nut1) go to 10
        if(nutc.gt.nut2) go to 999

        rmsx=sqrt(0.5*sum(csx*conjg(csx))/2001.0)
        rmsy=sqrt(0.5*sum(csy*conjg(csy))/2001.0)
        
        ih=nutc/10000
        im=(nutc-ih*10000)/100
        is=mod(nutc,100)
        uth=ih + im/60.0 + is/3600.0
        if(uth.lt.15.0) uth=uth+24.0
        ok=.true.

        if(index(infile,"432").gt.0) then

           bx=0.030 + 0.002*(70-nel)/58.0
           if(nel.lt.12) bx=0.032 + 0.005*(12-nel)/12.0
           if(nel.lt.12 .and.naz.gt.180) bx=0.032 + 0.016*(12-nel)/12.0

           if(naz.lt.180) then
              by=0.026 + 0.001*(70-nel)/57.0
              if(nel.lt.13) by=0.027 + 0.011*(13-nel)/13.0
           else
              by=0.026 + 0.001*(70-nel)/47.0
              if(nel.lt.23) by=0.027 + 0.033*(23-nel)/23.0
           endif

        else
           bx=0.078
           by=0.068
           if(rmsx.lt.0.037) ok=.false.
        endif

        if(rmsx.lt.1.1*bx .and. rmsy.le.1.1*by .and. ok) then
!                          1   2   3    4    5   6  7
           write(13,1010) uth,naz,nel,rmsx,rmsy,bx,by
1010       format(f10.6,2i6,4f10.6)
           nok=nok+1
           nn=nn+1
           done=mod(k,nadd).eq.0
           call polfit2(csx,csy,uth,nn,nadd,done,dphi,dl,dc,pol,delta,red,blue)
        else
           nblank=nblank+1
        endif

     enddo
  enddo
100 print*,'Zapped:',float(nblank)/(nok+nblank)

999 end program polecho
