subroutine audiodev(ndevin,ndevout,inbad,outbad)

!                        !f2py threadsafe
!f2py intent(in)  ndevin,ndevout
!f2py intent(out) inbad,outbad

  character cdevice*40
  integer inbad,outbad
  integer nchin(0:20),nchout(0:20),inerr(0:20),outerr(0:20)

  call padevsub(numdevs,ndefin,ndefout,nchin,nchout,inerr,outerr)
  open(17,file='audio_caps',status='old')
  inbad=1
  do i=0,numdevs-1
     read(17,1101) cdevice
1101 format(29x,a40)
     i1=index(cdevice,':')
     if(i1.gt.10) cdevice=cdevice(:i1-1)
     if(nchin(i).gt.0 .and. inerr(i).eq.0) then
!        write(*,1001) i,nchin(i),cdevice
!1001    format(i2,'.  ',i3,'  input channels: ',a40)
        if(i.eq.ndevin) inbad=0
     endif
  enddo

  rewind 17
  outbad=1
  do i=0,numdevs-1
     read(17,1101) cdevice
     i1=index(cdevice,':')
     if(i1.gt.10) cdevice=cdevice(:i1-1)
     if(nchout(i).gt.0 .and. outerr(i).eq.0) then
!        write(*,1007) i,nchout(i),cdevice
!1007    format(i2,'.  ',i3,' output channels: ',a40)
        if(i.eq.ndevout) outbad=0
     endif
  enddo
  close(17)

  return
end subroutine audiodev
