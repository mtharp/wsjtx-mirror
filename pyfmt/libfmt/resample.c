/*
 *-------------------------------------------------------------------------------
 *
 * This file is part of the WSPR application, Weak Signal Propagation Reporter
 *
 * File Name:    resample.c
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
#include <samplerate.h>

int resample_( float din[], float dout[], double *samfac, int *jz, int *ntype)
{
  SRC_DATA src_data;
  int input_len;
  int output_len;
  int ierr;
  int nchan=1;
  double src_ratio;

  src_ratio=*samfac;
  input_len=*jz;
  output_len=(int) (input_len*src_ratio);

  src_data.data_in=din;
  src_data.data_out=dout;
  src_data.src_ratio=src_ratio;
  src_data.input_frames=input_len;
  src_data.output_frames=output_len;

  ierr=src_simple(&src_data,*ntype,nchan);
  *jz=output_len;
  /*  printf("%d  %d  %d  %d  %f\n",input_len,output_len,
	 src_data.input_frames_used,
	 src_data.output_frames_gen,src_ratio);
  */
  return ierr;
}
