/* usleep(3) */
int usleep_(unsigned long *microsec)
{
  usleep(*microsec);
  return(0);
}
