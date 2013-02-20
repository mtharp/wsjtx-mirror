real*8 FUNCTION bessi(n,x)
  implicit real*8 (a-h,o-z)
  PARAMETER (IACC=40,BIGNO=1.0e10,BIGNI=1.0e-10)
  if (n.lt.2) pause 'bad argument n in bessi'
  if (x.eq.0.d0) then
     bessi=0.
  else
     tox=2.d0/abs(x)
     bip=0.d0
     bi=1.d0
     bessi=0.d0
     m=2*((n+int(sqrt(float(IACC*n)))))
     do j=m,1,-1
        bim=bip+float(j)*tox*bi
        bip=bi
        bi=bim
        if (abs(bi).gt.BIGNO) then
           bessi=bessi*BIGNI
           bi=bi*BIGNI
           bip=bip*BIGNI
        endif
        if (j.eq.n) bessi=bip
     enddo
     bessi=bessi*bessi0(x)/bi
     if (x.lt.0..and.mod(n,2).eq.1) bessi=-bessi
  endif

  return
END FUNCTION bessi
