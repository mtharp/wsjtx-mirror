subroutine xfft(x,nfft)

! Real-to-complex FFT.

  real x(nfft)

  call four2a(x,nfft,1,-1,0)

  return
end subroutine xfft

