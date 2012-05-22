#ifndef COMMONS_H
#define COMMONS_H

#define NFFT 32768

extern "C" {

extern struct {                     //This is "common/datcom/..." in Fortran
  float d4[4*5760000];              //Raw I/Q data from Linrad
  float ss[4*322*NFFT];             //Half-symbol spectra at 0,45,90,135 deg pol
  float savg[4*NFFT];               //Avg spectra at 0,45,90,135 deg pol
  double fcenter;                   //Center freq from Linrad (MHz)
  int nutc;                         //UTC as integer, HHMM
  int idphi;                        //Phase correction for Y pol'n, degrees
  int mousedf;                      //User-selected DF
  int mousefqso;                    //User-selected QSO freq (kHz)
  int nagain;                       //1 ==> decode only at fQSO +/- Tol
  int ndepth;                       //How much hinted decoding to do?
  int ndiskdat;                     //1 ==> data read from *.tf2 or *.iq file
  int neme;                         //Hinted decoding tries only for EME calls
  int newdat;                       //1 ==> new data, must do long FFT
  int nfa;                          //Low decode limit (kHz)
  int nfb;                          //High decode limit (kHz)
  int nfcal;                        //Frequency correction, for calibration (Hz)
  int nfshift;                      //Shift of displayed center freq (kHz)
  int mcall3;                       //1 ==> CALL3.TXT has been modified
  int ntimeout;                     //Max for timeouts in Messages and BandMap
  int ntol;                         //+/- decoding range around fQSO (Hz)
  int nxant;                        //1 ==> add 45 deg to measured pol angle
  int map65RxLog;                   //Flags to control log files
  int nfsample;                     //Input sample rate
  int nxpol;                        //1 if using xpol antennas, 0 otherwise
  int mode65;                       //JT65 sub-mode: A=1, B=2, C=4
  char mycall[12];
  char mygrid[6];
  char hiscall[12];
  char hisgrid[6];
  char datetime[20];
} datcom_;
}

#endif // COMMONS_H
