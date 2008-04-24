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

int th_wspr2_(void)
{
  pthread_t thread0;
  int iret0;
  int iarg0 = 0;
  iret0 = pthread_create(&thread0,NULL,wspr2_,&iarg0);
  //  printf("wspr2 %d\n",iret0);
  return 0;
}

int th_decode_(void)
{
  pthread_t thread1;
  int iret1;
  int iarg1 = 1;
  iret1 = pthread_create(&thread1,NULL,decode_,&iarg1);
  //  printf("decode %d\n",iret1);
  return 0;
}

int th_rx_(void)
{
  pthread_t thread2;
  int iret2;
  int iarg2 = 2;
  iret2 = pthread_create(&thread2,NULL,rx_,&iarg2);
  //  printf("rx %d\n",iret2);
  return 0;
}

int th_tx_(void)
{
  pthread_t thread3;
  int iret3;
  int iarg3 = 3;
  iret3 = pthread_create(&thread3,NULL,tx_,&iarg3);
  //  printf("tx %d\n",iret3);
  return 0;
}
