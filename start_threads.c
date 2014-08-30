/*
 *-------------------------------------------------------------------------------
 *
 * This file is part of the WSPR application, Weak Signal Propogation Reporter
 *
 * File Name:    start_threads.c
 * Description:
 *
 * Copyright (C) 2001-2014 Joseph Taylor, K1JT
 * License: GPL-3+
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
 * Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *-------------------------------------------------------------------------------
*/

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
  int iret1;
  int iarg1 = 1;

  if(decode_started>0)  {
    /*
    // the following was "< 100":
    if(time(NULL)-decode_started < 2)  {
      printf("Attempted to start decoder too soon:  %d   %d",
	     (int)time(NULL),decode_started);
      return 0;
    }
    */
    pthread_join(decode_thread,NULL);
    decode_started=0;
  }
  iret1 = pthread_create(&decode_thread,NULL,(void *)decode_,&iarg1);
  //  if(iret1==0) decode_started=time(NULL);
  return iret1;
}

int th_rx_(void)
{
  return spawn_thread(rx_);
}

int th_tx_(void)
{
  return spawn_thread(tx_);
}
