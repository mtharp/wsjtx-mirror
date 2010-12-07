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

pthread_t decode_thread;
static int decode_started=0;

int th_wspr2_(void)
{
  pthread_t wspr2_thread;
  int ret1,ret2,ret3;
  int iarg0 = 0;
  struct sched_param param;

  // Create wspr2 thread.
  ret1=pthread_create(&wspr2_thread,NULL,wspr2_,&iarg0);

  // Set wspr2_thread priority to normal.
  param.sched_priority=0;
  ret2=pthread_setschedparam(wspr2_thread,SCHED_OTHER,&param);

  // Detach the thread
  ret3=pthread_detach(wspr2_thread);

  return 0;

}

int th_decode_(void)
{
  int ret1,ret2;
  int iarg1 = 1;
  struct sched_param param;

  if(decode_started>0)  {
    // the following was "< 100":
    if(time(NULL)-decode_started < 5)  {
      printf("Attempted to start decoder too soon:  %d   %d",
	     time(NULL),decode_started);
      return 0;
    }
    pthread_join(decode_thread,NULL);
    decode_started=0;
  }

  ret1 = pthread_create(&decode_thread,NULL,decode_,&iarg1);
  if(ret1==0) decode_started=time(NULL);

  // Set thread priority below normal. (Priority must be in range -15 to +15.)
  param.sched_priority=-1;
  ret2=pthread_setschedparam(decode_thread,SCHED_OTHER,&param);

  return ret1;
}

int th_rx_(void)
{
  pthread_t rx_thread;
  int ret1,ret2,ret3;
  int iarg0 = 0;
  struct sched_param param;

  // Create rx thread.
  ret1=pthread_create(&rx_thread,NULL,rx_,&iarg0);

  // Set rx_thread priority above normal.
  param.sched_priority=1;
  ret2=pthread_setschedparam(rx_thread,SCHED_OTHER,&param);

  // Detach the thread
  ret3=pthread_detach(rx_thread);

  return 0;
}

int th_tx_(void)
{
  pthread_t tx_thread;
  int ret1,ret2,ret3;
  int iarg0 = 0;
  struct sched_param param;

  // Create tx thread.
  ret1=pthread_create(&tx_thread,NULL,tx_,&iarg0);

  // Set tx_thread priority above normal.
  param.sched_priority=1;
  ret2=pthread_setschedparam(tx_thread,SCHED_OTHER,&param);

  // Detach the thread
  ret3=pthread_detach(tx_thread);

  return 0;

}
