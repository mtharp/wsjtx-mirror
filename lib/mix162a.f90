subroutine mix162a(c2,ps)

  real ps(-256:256)
  complex c2(0:65535),c2a(0:65535)

  c2=conjg(c2)
  c2a(0:45000-1)=c2(0:45000-1)
  c2a(45000:)=0.
  nfft2=65536
  nh2=nfft2/2
  call four2a(c2a,nfft2,1,-1,1)
  
  ia=1-nh2
  ib=nh2

  k=-257
  do i=ia-64,ib,128
     k=k+1
     sq=0.
     do n=0,127
        j=mod(i+n+4*nfft2,nfft2)
        sq=sq + real(c2a(j))**2 + aimag(c2a(j))**2
     enddo
     ps(k)=4.085e-8*sq * 10.0**(-0.98)
  enddo

  return
end subroutine mix162a
