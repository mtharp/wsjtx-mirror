/*-------------------------------------------------------------------------------
 *
 * This file is part of the WSPR application, Weak Signal Propagation Reporter
 *
 * File Name:    gmtime2.c
 * Description:
 *
 * Copyright (C) 2001-2014 Joseph Taylor, K1JT
 * License: GPL-3
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
#include <string.h>

typedef struct _SYSTEMTIME
{
  short   Year;
  short   Month;
  short   DayOfWeek;
  short   Day;
  short   Hour;
  short   Minute;
  short   Second;
  short   Millisecond;
} SYSTEMTIME;

#ifdef Win32
extern void __stdcall GetSystemTime(SYSTEMTIME *st);
#else
#include <sys/time.h>
#include <time.h>

void GetSystemTime(SYSTEMTIME *st){
  struct timeval tmptimeofday;
  struct tm tmptmtime;
  gettimeofday(&tmptimeofday,NULL);
  gmtime_r((const time_t *)&tmptimeofday.tv_sec,&tmptmtime);
  st->Year = (short)tmptmtime.tm_year;
  st->Month = (short)tmptmtime.tm_mon+1;
  st->DayOfWeek = (short)tmptmtime.tm_wday;
  st->Day = (short)tmptmtime.tm_mday;
  st->Hour = (short)tmptmtime.tm_hour;
  st->Minute = (short)tmptmtime.tm_min;
  st->Second = (short)tmptmtime.tm_sec;
  st->Millisecond = (short)(tmptimeofday.tv_usec/1000);
}
#endif

extern void gmtime2_(int it[], double *stime)
{
  SYSTEMTIME st;

  GetSystemTime(&st);
  it[0]=st.Second;
  it[1]=st.Minute;
  it[2]=st.Hour;
  it[3]=st.Day;
  it[4]=st.Month;
  it[5]=st.Year;
  it[6]=st.DayOfWeek;
  it[7]=0;
  it[8]=0;
  *stime = st.Hour*3600.0 + st.Minute*60.0 + st.Second + st.Millisecond*0.001;
}

