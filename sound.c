#include <stdio.h>
#include <stdlib.h>
#include <portaudio.h>

#define SAMPLE_RATE  (48000)
#define FRAMES_PER_BUFFER (8192)
#define NUM_CHANNELS    (1)
/* #define DITHER_FLAG     (paDitherOff)  */
#define DITHER_FLAG     (0) /**/
#define PA_SAMPLE_TYPE  paInt16
typedef short SAMPLE;

#ifdef CVF
int __stdcall SOUNDINIT(void)
#else 
int soundinit_(void)
#endif
{
  PaError err;
  err = Pa_Initialize();
  if( err == paNoError ) {
    return 0;
  }
  else {
//    Pa_Terminate();
    fprintf( stderr, "An error occured when initializing the audio stream\n");
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "WSPR will now exit/n");
    exit(255);
  }
}

#ifdef CVF
int __stdcall SOUNDEXIT(void)
#else
int soundexit_(void)
#endif
{
  Pa_Terminate();
  return 0;
}

#ifdef CVF
int __stdcall SOUNDIN(int *idevin, short recordedSamples[],int *nframes0)
#else
int soundin_(int *idevin, short recordedSamples[],int *nframes0)
#endif
{
    PaStreamParameters inputParameters;
    PaStream *stream;
    PaError err;
    int i;
    int totalFrames;
    int numSamples;
    int numBytes;
    
    totalFrames=*nframes0;
    numSamples = totalFrames * NUM_CHANNELS;
    numBytes = numSamples * sizeof(SAMPLE);
    for( i=0; i<numSamples; i++ ) 
      recordedSamples[i] = 0;

    inputParameters.device = *idevin;
    inputParameters.channelCount = NUM_CHANNELS;
    inputParameters.sampleFormat = PA_SAMPLE_TYPE;
    inputParameters.suggestedLatency = 0.4;
    inputParameters.hostApiSpecificStreamInfo = NULL;

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

    err = Pa_StartStream( stream );
    if( err != paNoError ) goto error;

    err = Pa_ReadStream( stream, recordedSamples, totalFrames );
    if( err != paNoError ) goto error;
    
    err = Pa_CloseStream( stream );
    if( err != paNoError ) goto error;
    return 0;

error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
#ifdef CVF
     SOUNDINIT();
#else 
     soundinit_();
#endif
    return -1;
}

#ifdef CVF
int __stdcall SOUNDOUT(int *idevout,short recordedSamples[], int *nframes0)
#else
int soundout_(int *idevout, short recordedSamples[], int *nframes0)
#endif
{
    PaStreamParameters outputParameters;
    PaStream *stream;
    PaError err;
    int totalFrames;
    int numSamples;
    int numBytes;

    totalFrames=*nframes0;
    numSamples = totalFrames * NUM_CHANNELS;
    numBytes = numSamples * sizeof(SAMPLE);
    outputParameters.device = *idevout;
    outputParameters.channelCount = NUM_CHANNELS;
    outputParameters.sampleFormat =  PA_SAMPLE_TYPE;
    outputParameters.suggestedLatency = 0.4;
    outputParameters.hostApiSpecificStreamInfo = NULL;

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
        err = Pa_StartStream( stream );
        if( err != paNoError ) goto error;

        err = Pa_WriteStream( stream, recordedSamples, totalFrames );
        if( err != paNoError ) goto error;

        err = Pa_CloseStream( stream );
        if( err != paNoError ) goto error;
    }
    return 0;

error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
#ifdef CVF
    SOUNDINIT();
#else 
    soundinit_();
#endif
    return -1;
}

#ifdef CVF
void __stdcall MSLEEP(int *msec0)
#else
void msleep_(int *msec0)
#endif
{
  Pa_Sleep(*msec0);
}
