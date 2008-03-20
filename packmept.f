      subroutine packmept(msg,dat)

      character*22 msg
      integer dat(12)
      character*12 c1,c2
      character*4 c3
      character*6 grid6
      logical text1,text2,text3

C  Convert all letters to upper case
      do i=1,22
         if(msg(i:i).ge.'a' .and. msg(i:i).le.'z') 
     +     msg(i:i)= char(ichar(msg(i:i))+ichar('A')-ichar('a'))
      enddo

      do i=1,22
         if(msg(i:i).eq.' ') go to 1       !Get 1st blank
      enddo 
      go to 10                             !Bad message
      
 1    ia=i
      c1=msg(1:ia-1)
      do i=ia+1,22
         if(msg(i:i).eq.' ') go to 2       !Get 2nd blank
      enddo
      go to 10                             !Bad message

 2    ib=i
      c2=msg(ia+1:ib-1)

      do i=ib+1,22
         if(msg(i:i).eq.' ') go to 3       !Get 3rd blank
      enddo
      go to 10                             !Bad message

 3    ic=i
      c3='    '
      if(ic.ge.ib+1) c3=msg(ib+1:ic)
      call packcall(c1,nc1,text1)
      call packgrid(c2,ng,text2)
      read(c3,*,err=10) ndbm
      if((.not.text1) .and. (.not.text2) .and.
     +   (ndbm.ge.-64) .and. (ndbm.le.63)) go to 20

 10   print*,'Error: Badly structured MEPT_JT message.'
      stop

C  Encode data into 6-bit words
 20   n2=64*iand(ng,65534) + ndbm + 64
      dat(1)=iand(ishft(nc1,-22),63)                !6 bits
      dat(2)=iand(ishft(nc1,-16),63)                !6 bits
      dat(3)=iand(ishft(nc1,-10),63)                !6 bits
      dat(4)=iand(ishft(nc1, -4),63)                !6 bits
      dat(5)=4*iand(nc1,15)+iand(ishft(n2,-20),3)   !4+2 bits
      dat(6)=iand(ishft(n2,-14),63)                 !6 bits
      dat(7)=iand(ishft(n2,-8),63)                  !6 bits
      dat(8)=iand(ishft(n2,-2),63)                  !6 bits
      dat(9)=16*iand(n2,3)                          !2 bits

      return
      end
