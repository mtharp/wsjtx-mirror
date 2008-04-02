#include <stdio.h>
#include <stdlib.h>
#include "portaudio.h"

#define SAMPLE_RATE  (12000)
#define FRAMES_PER_BUFFER (1024)
#define NUM_CHANNELS    (1)
/* #define DITHER_FLAG     (paDitherOff)  */
#define DITHER_FLAG     (0) /**/
#define PA_SAMPLE_TYPE  paInt16
typedef short SAMPLE;

// int soundinit(void)
int __stdcall SOUNDINIT(void)
{
  PaError err;
  err = Pa_Initialize();
  if( err == paNoError ) {
    return 0;
  }
  else {
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    return -1;
  }
}

// int soundexit(void)
int __stdcall SOUNDEXIT(void)
{
  Pa_Terminate();
  return 0;
}

// int soundin(short recordedSamples[],int totalFrames)
int __stdcall SOUNDIN(short recordedSamples[],int *nframes0)
{
    PaStreamParameters inputParameters;
    PaStream *stream;
    PaError err;
    int i;
    int totalFrames;
    int numSamples;
    int numBytes;
    
    totalFrames=*nframes0;
    //    printf("A %d\n",totalFrames);
    numSamples = totalFrames * NUM_CHANNELS;
    numBytes = numSamples * sizeof(SAMPLE);
    for( i=0; i<numSamples; i++ ) 
      recordedSamples[i] = 0;

    inputParameters.device = Pa_GetDefaultInputDevice();
    inputParameters.channelCount = NUM_CHANNELS;
    inputParameters.sampleFormat = PA_SAMPLE_TYPE;
    inputParameters.suggestedLatency = 0.4;
    inputParameters.hostApiSpecificStreamInfo = NULL;

    //    printf("Opening input stream\n");
    err = Pa_OpenStream(
              &stream,
              &inputParameters,
              NULL,                  /* &outputParameters, */
              SAMPLE_RATE,
              FRAMES_PER_BUFFER,
              paClipOff,
              NULL, /* no callback, use blocking API */
              NULL ); /* no callback, so no callback userData */
    if( err != paNoError ) goto error;

    //    printf("Starting input stream\n");
    err = Pa_StartStream( stream );
    if( err != paNoError ) goto error;

    //    printf("Reading from input stream\n");
    err = Pa_ReadStream( stream, recordedSamples, totalFrames );
    if( err != paNoError ) goto error;
    
    //    printf("Closing input stream\n");
    err = Pa_CloseStream( stream );
    if( err != paNoError ) goto error;
    return 0;

error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    return -1;
}

// int soundout(short recordedSamples[], int totalFrames)
int __stdcall SOUNDOUT(short recordedSamples[], int *nframes0)
{
    PaStreamParameters outputParameters;
    PaStream *stream;
    PaError err;
    int i;
    int totalFrames;
    int numSamples;
    int numBytes;

    totalFrames=*nframes0;
    numSamples = totalFrames * NUM_CHANNELS;
    numBytes = numSamples * sizeof(SAMPLE);
    outputParameters.device = Pa_GetDefaultOutputDevice();
    outputParameters.channelCount = NUM_CHANNELS;
    outputParameters.sampleFormat =  PA_SAMPLE_TYPE;
    outputParameters.suggestedLatency = 0.4;
    outputParameters.hostApiSpecificStreamInfo = NULL;

    //    printf("Opening output stream\n");
    err = Pa_OpenStream(
              &stream,
              NULL, /* no input */
              &outputParameters,
              SAMPLE_RATE,
              FRAMES_PER_BUFFER,
              paClipOff,
              NULL, /* no callback, use blocking API */
              NULL ); /* no callback, so no callback userData */
    if( err != paNoError ) goto error;

    if( stream )
    {
      //      printf("Starting output stream\n");
        err = Pa_StartStream( stream );
        if( err != paNoError ) goto error;

	//	printf("Writing to output stream\n");
        err = Pa_WriteStream( stream, recordedSamples, totalFrames );
        if( err != paNoError ) goto error;

	//	printf("Closing  output stream\n");
        err = Pa_CloseStream( stream );
        if( err != paNoError ) goto error;
    }
    //    printf("Done.\n");
    return 0;

error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    return -1;
}

// void msleep_(int *msec0)
void __stdcall MSLEEP(int *msec0)
{
  Pa_Sleep(*msec0);
}
