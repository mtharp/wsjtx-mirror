#include <stdio.h>
#include <portaudio.h>

int padevsub_(int *idevin, int *idevout)
{
  int numdev,ndefin,ndefout;
  int nchin[21], nchout[21];
  int      i, devIdx;
  int      numDevices;
  const PaDeviceInfo *pdi;
  PaError  err;

  Pa_Initialize();
  numDevices = Pa_GetDeviceCount();
  numdev = numDevices;

  if( numDevices < 0 )  {
    err = numDevices;
    Pa_Terminate();
    return err;
  }

  if ((devIdx = Pa_GetDefaultInputDevice()) > 0) {
    ndefin = devIdx;
  } else {
    ndefin = 0;
  }

  if ((devIdx = Pa_GetDefaultOutputDevice()) > 0) {
    ndefout = devIdx;
  } else {
    ndefout = 0;
  }

  printf("\nAudio     Input    Output     Device Name\n");
  printf("Device  Channels  Channels\n");
  printf("------------------------------------------------------------------\n");

  for( i=0; i < numDevices; i++ )  {
    pdi = Pa_GetDeviceInfo(i);
//    if(i == Pa_GetDefaultInputDevice()) ndefin = i;
//    if(i == Pa_GetDefaultOutputDevice()) ndefout = i;
    nchin[i]=pdi->maxInputChannels;
    nchout[i]=pdi->maxOutputChannels;
    printf("  %2d       %2d        %2d       %s\n",i,nchin[i],nchout[i],pdi->name);
  }

  printf("\nUser requested devices:   Input = %2d   Output = %2d\n",
  	 *idevin,*idevout);
  printf("Default devices:          Input = %2d   Output = %2d\n",
  	 ndefin,ndefout);
  if((*idevin<0) || (*idevin>=numdev)) *idevin=ndefin;
  if((*idevout<0) || (*idevout>=numdev)) *idevout=ndefout;
  if((*idevin==0) && (*idevout==0))  {
    *idevin=ndefin;
    *idevout=ndefout;
  }
  printf("Will open devices:        Input = %2d   Output = %2d\n",
  	 *idevin,*idevout);

  //  Pa_Terminate();

  return 0;
}

