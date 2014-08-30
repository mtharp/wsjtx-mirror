/*
 *-------------------------------------------------------------------------------
 *
 * This file is part of the WSPR application, Weak Signal Propogation Reporter
 *
 * File Name:     fthread.c
 * Description:
 *
 * Original Author: V. Ganesh
 * Source: http://v-ganesh.tripod.com/papers/fthreads.pdf*
 *
 * Copyright (C) 2008-2014 Joseph Taylor, K1JT
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

// Create a new fortran thread through a subroutine.
void fthread_create_(void *(*thread_func)(void *), pthread_t *theThread) 
{
  pthread_create(theThread, NULL, thread_func, NULL);
} 

/*
// Yield control to other threads
void fthread_yield_() 
{
  pthread_yield();
}
*/

// Return my own thread ID
pthread_t fthread_self_() 
{
  return pthread_self();
} 

// Lock the execution of all threads until we have the mutex
int fthread_mutex_lock_(pthread_mutex_t **theMutex) 
{
  return(pthread_mutex_lock(*theMutex));
}

int fthread_mutex_trylock_(pthread_mutex_t **theMutex) 
{
  return(pthread_mutex_trylock(*theMutex));
}

// Unlock the execution of all threads that were stopped by this mutex
void fthread_mutex_unlock_(pthread_mutex_t **theMutex) 
{
  pthread_mutex_unlock(*theMutex);
}

// Get a new mutex object
void fthread_mutex_init_(pthread_mutex_t **theMutex) 
{
  *theMutex = (pthread_mutex_t *) malloc(sizeof(pthread_mutex_t));
  pthread_mutex_init(*theMutex, NULL);
}

// Release a mutex object
void fthread_mutex_destroy_(pthread_mutex_t **theMutex) 
{
  pthread_mutex_destroy(*theMutex);
  free(*theMutex);
}

// Waits for thread ID to join
void fthread_join(pthread_t *theThread) 
{
  int value = 0;
  pthread_join(*theThread, (void **)&value);
}

// Exit from a thread
void fthread_exit_(void *status) 
{
  pthread_exit(status);
}

