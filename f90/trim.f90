program ptrim

  character*132 line

1 read(*,1000,end=999) line
1000 format(a132)
  n=len_trim(line)
  if(n.eq.1 .and. line(1:1).eq.'!') line(1:1)=' '
  write(*,1010) (line(i:i),i=1,n)
1010 format(132a1)
  go to 1

999 end program ptrim
