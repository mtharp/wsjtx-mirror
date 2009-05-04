#include <stdio.h>
#include <stdlib.h>
#ifdef Win32
   #include "pthread_w32.h"
#else
   #include <pthread.h>
#endif
#include <inttypes.h>
#include <time.h>
#include <sys/time.h>

extern void wspr2_(int *iarg);
extern void decode_(int *iarg);
extern void rx_(int *iarg);
extern void tx_(int *iarg);

int spawn_thread(void (*f)(int *n)) {
  pthread_t thread;
  int iret;
  int iarg0 = 0;

  iret=pthread_create(&thread,NULL,(void *)f,&iarg0);
  if (iret) {
    perror("spawning new thread");
    return iret;
  }

  iret = pthread_detach(thread);
  if (iret) {
    perror("detaching thread");
    return iret;
  }
  return 0;
}


int th_wspr2_(void)
{
  int ierr;
  ierr=spawn_thread(wspr2_);
  return ierr;
}

int th_decode_(void)
{
  return spawn_thread(decode_);
}

int th_rx_(void)
{
  return spawn_thread(rx_);
}

int th_tx_(void)
{
  return spawn_thread(tx_);
}
