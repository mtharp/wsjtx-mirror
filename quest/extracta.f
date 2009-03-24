      subroutine extracta(s3,nadd,nn,kk,nqbits,ndec,ncount,decoded,dat)

      real s3(64,63)
      character decoded*22,decoded0*22
      integer*1 dat1(23)
      integer dat(63),era(56),dat4(23),indx(63)
      integer mrsym(63),mr2sym(63),mrprob(63),mr2prob(63)
      logical first
      data first/.true./,xlambda0/99./,maxe0/8/,nads0/200/

      call demod64(s3,nadd,nn,nqbits,mrsym,mrprob,mr2sym,mr2prob)

!      call graycode(mrsym,63,-1)
!      call interleave63(mrsym,-1)
!      call interleave63(mrprob,-1)

      if(ndec.eq.0) then
         nemax=(nn-kk)/2
         call indexx(nn,mrprob,indx)
         do i=1,nemax
            j=indx(i)
            if(mrprob(j).gt.120) then
               ne2=i-1
               go to 2
            endif
            era(i)=j-1
         enddo
         ne2=nemax
 2       decoded='                      '
         do nerase=0,ne2,2
            call rs_decode(mrsym,era,nerase,dat4,ncount)
            if(ncount.ge.0) then
!               print*,ncount,nerase,ne2
               do i=1,kk
                  dat(i)=dat4(i)
               enddo
!               call unpackmsg(dat4,decoded)
               go to 900
            endif
         enddo
      else
!         call graycode(mr2sym,63,-1)
!         call interleave63(mr2sym,-1)
!         call interleave63(mr2prob,-1)
C  Initialize KV decoder to maximum parameter values.
!         if(first) call asdinit(6,64,63,12,3,15.0,12,200,8)
!         first=.false.
C  Initialize to working parameter values.
!         if(xlambda.ne.xlambda0 .or. MaxE.ne.MaxE0)
!     +        call asdinit(6,64,63,12,3,xlambda,MaxE,200,8)
         xlambda0=xlambda
         maxe0=maxe
         call rsasd(mrsym,mrprob,mr2sym,mr2prob,ierror,ncount,dat1)
         decoded='                      '
         if(ncount.ge.0) then
C  Copy decoded information from i*1 to i*4 array, then unpack message
            do i=1,kk
               dat(i)=dat1(i)
            enddo
!            call unpackmsg(dat,decoded) !Unpack the user message
         endif
      endif

!      sum=0.
!      base=0.
!      do j=1,63
!         sum=sum + p(gsym(j)+1,j)
!         base=base + p(63-gsym(j)+1,j)
!      enddo
!      print*,sum-base,sum,base
      
 900  return
      end
