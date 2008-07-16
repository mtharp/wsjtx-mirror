#include <stdio.h>
#include <portaudio.h>
#include <string.h>

int padevsub_(int *numdev, int *ndefin, int *ndefout, 
	      int nchin[], int nchout[])
{
  int      i, devIdx;
  int      numDevices;
  const    PaDeviceInfo *pdi;
  PaError  err;

  Pa_Initialize();
  numDevices = Pa_GetDeviceCount();
  *numdev = numDevices;

  if( numDevices < 0 )  {
    err = numDevices;
    Pa_Terminate();
    return err;
  }

  if ((devIdx = Pa_GetDefaultInputDevice()) > 0) {
    *ndefin = devIdx;
  } else {
    *ndefin = 0;
  }

  if ((devIdx = Pa_GetDefaultOutputDevice()) > 0) {
    *ndefout = devIdx;
  } else {
    *ndefout = 0;
  }

  printf("\nAudio     Input    Output     Device Name\n");
  printf("Device  Channels  Channels\n");
  printf("------------------------------------------------------------------\n");

  for( i=0; i < numDevices; i++ )  {
    pdi = Pa_GetDeviceInfo(i);
//    if(i == Pa_GetDefaultInputDevice()) *ndefin = i;
//    if(i == Pa_GetDefaultOutputDevice()) *ndefout = i;
    nchin[i]=pdi->maxInputChannels;
    nchout[i]=pdi->maxOutputChannels;
    printf("  %2d       %2d        %2d       %s\n",i,nchin[i],nchout[i],pdi->name);
  }
  return 0;
}

