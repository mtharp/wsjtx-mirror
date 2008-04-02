subroutine getutc(cdate,ctime,ihr,imin,sec,tsec)

  character cdate*8,ctime*10,czone*5
  real*8 tsec
  integer nt(8)
!        1    2    3    4     5    6    7    8
!  nt: year,month,day,ntzmin,nhr,nmin,nsec,msec

  call date_and_time(cdate,ctime,czone,nt)
  tsec=3600*nt(5) + 60*nt(6) + nt(7) + 0.001d0*nt(8) - 60*nt(4)
  ihr=tsec/3600.d0
  imin=(tsec/60.d0 - 60.d0*ihr)
  sec=tsec - 3600*ihr - 60*imin 
  cdate(1:1)=char(48+nt(1)/1000)
  cdate(2:2)=char(48+mod(nt(1),1000)/100)
  cdate(3:3)=char(48+mod(nt(1),100)/10)
  cdate(4:4)=char(48+mod(nt(1),10))
  cdate(5:5)=char(48+nt(2)/10)
  cdate(6:6)=char(48+mod(nt(2),10))
  cdate(7:7)=char(48+nt(3)/10)
  cdate(8:8)=char(48+mod(nt(3),10))
  msec=1000.d0*tsec
  ctime(1:1)=char(48+ihr/10)
  ctime(2:2)=char(48+mod(ihr,10))
  ctime(3:3)=char(48+imin/10)
  ctime(4:4)=char(48+mod(imin,10))
  nsec=sec
  ctime(5:5)=char(48+nsec/10)
  ctime(6:6)=char(48+mod(nsec,10))
  ctime(7:7)='.'
  msec=1000*(sec-nsec)
  ctime(8:8)=char(48+msec/100)
  ctime(9:9)=char(48+mod(msec,100)/10)
  ctime(10:10)=char(48+mod(msec,10))

  return
end subroutine getutc
