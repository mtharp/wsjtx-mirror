subroutine getmu(s0,s1,n,amp,mu0,mu1)

  parameter (NMAX=100)
  real*8 pdfChisq,p0,p1,ps0,ps1,pn0,pn1,x
  real log2
  common/pspncom/ps(0:NMAX),pn(0:NMAX),scale
  log2(x)=log(x)/log(2.0)

  ps0=pdfChisq(n*s0,n,amp)
  pn1=pdfChisq(n*s1,n,0.0)
  p0=ps0*pn1/(ps0+pn1)

  ps1=pdfChisq(n*s1,n,amp)
  pn0=pdfChisq(n*s0,n,0.0)
  p1=ps1*pn0/(ps1+pn0)

  mu0=nint(scale*(log2(2.0*p0/(p0+p1)) - 0.5))
  mu1=nint(scale*(log2(2.0*p1/(p0+p1)) - 0.5))

  return
end subroutine getmu
