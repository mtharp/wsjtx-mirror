/*
 *-------------------------------------------------------------------------------
 *
 * This file is part of the WSPR application, Weak Signal Propagation Reporter
 *
 * File Name:     ptt.c
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

#include <windows.h>
#include <stdio.h>

int ptt_(int *nport, char *unused, int *ntx, int *iptt)
{
  static HANDLE hFile;
  static int open=0;
  char s[10];
  int i3,i4,i5,i6,i9,i00;

  if(*nport==0) {
    *iptt=*ntx;
    return(0);
  }

  if(*ntx && (!open)) {
    sprintf(s,"\\\\.\\COM%d",*nport);
    hFile=CreateFile(
		     TEXT(s),
		     GENERIC_WRITE,
		     0,
		     NULL,
		     OPEN_EXISTING,
		     FILE_ATTRIBUTE_NORMAL,
		     NULL
		     );
    if(hFile==INVALID_HANDLE_VALUE) {
      printf("PTT: Cannot open COM port %d.\n",*nport);
      return(1);
    }
    open=1;
  }

  if(*ntx && open) {
    EscapeCommFunction(hFile,3);
    EscapeCommFunction(hFile,5);
    *iptt=1;
  }

  else {
    EscapeCommFunction(hFile,4);
    EscapeCommFunction(hFile,6);
    EscapeCommFunction(hFile,9);
    i00=CloseHandle(hFile);
    *iptt=0;
    open=0;
  }
  return(0);
}
