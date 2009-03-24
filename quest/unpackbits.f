      subroutine unpackbits(sym,nsymd,m0,dbits)

C  Unpack bits from sym() into dbits(), m0 bits per byte.
C  NB: nsymd is the number of input bytes; there will be 
C  m0*nsymd output bytes.

      integer sym(nsymd)
      integer*1 dbits(*)
      integer*1 n1
      equivalence (n,n1)

      k=0
      do i=1,nsymd
         mask=2**m0
         do j=1,m0
            mask=mask/2
            k=k+1
            dbits(k)=0
            if(iand(mask,sym(i)).ne.0) dbits(k)=1
         enddo
      enddo

      return
      end
