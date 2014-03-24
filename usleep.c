#ifdef UNIX
#include <sys/times.h>
#include <time.h>
#include <sys/time.h>
#else
#include "sleep.h"
//#include "timeval.h"
#endif

int usleep_(unsigned long *microsec)
{
  usleep(*microsec);
  return(0);
}
