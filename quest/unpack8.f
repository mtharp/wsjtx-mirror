      subroutine unpack8(ddec,nbits,dbits)

      integer*1 ddec(32),dbits(256)
      integer*1 n1
      equivalence (n,n1)

      nbytes=(nbits+7)/8
      k=0
      do i=1,nbytes
         mask=256
         do j=1,8
            mask=mask/2
            k=k+1
            dbits(k)=0
            iddec=ddec(i)
            if(iand(mask,iddec).ne.0) dbits(k)=1
         enddo
      enddo

      return
      end
