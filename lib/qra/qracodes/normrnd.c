// normrnd.c 
// functions to generate gaussian distributed numbers
// 
// (c) 2016 - Nico Palermo, IV3NWV - Microtelecom Srl, Italy
//
// Credits to Andrea Montefusco - IW0HDV for his help on adapting the sources
// to OSs other than MS Windows
//
// ------------------------------------------------------------------------------
// This file is part of the qracodes project, a Forward Error Control
// encoding/decoding package based on Q-ary RA (Repeat and Accumulate) LDPC codes.
//
//    qracodes is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//    qracodes is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License
//    along with qracodes source distribution.  
//    If not, see <http://www.gnu.org/licenses/>.


#include "normrnd.h"

#if _WIN32 // note the underscore: without it, it's not msdn official!
	// Windows (x64 and x86)
	#include <windows.h>   // required only for GetTickCount(...)
#elif __unix__ // all unices, not all compilers
	#define rand_s rand_r
	#include <stdlib.h>
	#include <limits.h> // for UINT_MAX
	// Unix
#elif __linux__
	// linux
#elif __APPLE__
	// Mac OS, not sure if this is covered by __posix__ and/or __unix__ though...
#endif



// use MS rand_s(...) function
void normrnd_s(float *dst, int nitems, float mean, float stdev)
{
	unsigned int r;
	float phi=0, u=0;
	int set = 0;

	while (nitems--) 
		if (set==1) {
			*dst++ = (float)sin(phi)*u*stdev+mean;
			set = 0;
			}
		else {
			rand_s(&r); phi = (M_2PI/(1.0f+UINT_MAX))*r;
			rand_s(&r); u   = (float)sqrt(-2.0f* log( (1.0f/(1.0f+UINT_MAX))*(1.0f+r) ) );
			*dst++ = (float)cos(phi)*u*stdev+mean;
			set=1;
			}
}

// use MS rand() function
void normrnd(float *dst, int nitems, float mean, float stdev)
{
	float phi=0, u=0;
	int set = 0;

	while (nitems--) 
		if (set==1) {
			*dst++ = (float)sin(phi)*u*stdev+mean;
			set = 0;
			}
		else {
			phi = (M_2PI/(1.0f+RAND_MAX))*rand();
			u   = (float)sqrt(-2.0f* log( (1.0f/(1.0f+RAND_MAX))*(1.0f+rand()) ) );
			*dst++ = (float)cos(phi)*u*stdev+mean;
			set=1;
			}
}

