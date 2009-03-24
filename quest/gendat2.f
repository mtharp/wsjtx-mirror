      subroutine gendat2(gsym,sig,nadd,nqsb,mode65,nn,s,s2)

      real s(64,79)
      real s2(64,79)
      integer gsym(63)
      integer nc8(8)
      common/rancom/idum
      data nc8/3,6,2,4,5,0,7,1/
      save

      ntot=nn+16
      do j=1,ntot
         fade=1.0
         if(nqsb.gt.0) then
            fade=(rayleigh())**nqsb
            mm0=0
         endif
         x=gasdev(idum) + fade*sig
         y=gasdev(idum)
         s(1,j)=0.5*(x*x + y*y)
         do i=2,64
            x=gasdev(idum)
            y=gasdev(idum)
            s(i,j)=0.5*(x*x + y*y)
         enddo
         if(nadd.gt.1) then
            do n=2,nadd
               mm=(n-1)/mode65
               if(nqsb.gt.0 .and. mm.ne.mm0) then
                  fade=(rayleigh())**nqsb
                  mm0=mm
               endif
               x=gasdev(idum) + fade*sig
               y=gasdev(idum)
               s(1,j)=s(1,j)+0.5*(x*x + y*y)
               do i=2,64
                  x=gasdev(idum)
                  y=gasdev(idum)
                  s(i,j)=s(i,j)+0.5*(x*x + y*y)
               enddo
            enddo
            fac=1.0/nadd
            do i=1,64
               s(i,j)=fac*s(i,j)
            enddo
         endif

C  Move signal into proper bin:
         s1=s(1,j)
         k=1+gsym(j)
         if(j.gt.nn) then
            i=mod(j-nn-1,8)+1
            k=nc8(i)
         endif
         s(1,j)=s(k,j)
         s(k,j)=s1
      enddo

C  Reorder data from s() into s2()
      nd1=nn/2
      do j=1,ntot
         k=nn+j
         if(j.ge.9 .and. j.le.nd1+8) k=j-8
         if(j.ge.nd1+9 .and. j.le.nd1+16) k=nn+j-nd1
         if(j.ge.nd1+17) k=j-16
         do i=1,64
            s2(i,j)=s(i,k)
         enddo
      enddo

      return
      end

