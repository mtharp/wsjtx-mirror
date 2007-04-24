! Variable             Purpose                              Set in Thread
!-------------------------------------------------------------------------
real ps0               !Spectrum of best ping, FSK441/JT6m      Decoder
real psavg             !Average spectrum                        Decoder
real s2                !2d spectrum for horizontal waterfall    GUI
real ccf               !CCF in time (blue curve)                Decoder
real green             !Data for green line                     GUI
integer ngreen         !Length of green                         GUI
real dgain             !Digital audio gain setting              GUI
integer iter           !(why is this here??)
integer ndecoding      !Decoder status (see decode2.f90)     GUI,Decoder
integer ndecoding0     !Status on previous decode            GUI,Decoder
integer mousebutton    !Which button was clicked?               GUI
integer ndecdone       !Is decoder finished?                 GUI,Decoder
integer npingtime      !Time in file of mouse-selected ping  GUI,Decoder
integer ierr           !(why is this here?)
integer lauto          !Are we in Auto mode?                    GUI
integer mantx          !Manual transmission requested?       GUI,SoundIn
integer nrestart       !True if transmission should restart  GUI,SoundIn
integer ntr            !Are we in 2nd sequence?                 SoundIn
integer nmsg           !Length of Tx message                    SoundIn
integer nsave          !Which files to save?                    GUI
integer nadd5          !Prepend 5 sec of 0's before decoding?   GUI 
integer dftolerance    !DF tolerance (Hz)                       GUI
logical LDecoded       !Was a message decoded?                  Decoder
logical rxdone         !Has the Rx sequence finished?      SoundIn,Decoder
integer monitoring     !Are we monitoring?                      GUI
integer nzap           !Is Zap checked?                         GUI
integer nsavecum       !(why is this here?)
integer minsigdb       !Decoder threshold setting               GUI
integer nclearave      !Set to 1 to clear JT65 avg         GUI,Decoder
integer nfreeze        !Is Freeze checked?                      GUI
integer nafc           !Is AFC checked?                         GUI
integer nmode          !Which WSJT mode?                   GUI,Decoder
integer mode65         !JT65 sub-mode (A/B/C ==> 1/2/4) GUI,SoundIn,Decoder
integer nclip          !Clipping level                          GUI
integer ndebug         !Write debugging info?                   GUI
integer nblank         !Is NB checked?                          GUI
integer nfmid          !Center frequency of main display        GUI
integer nforce         !Force decoding of questionable data  GUI,Decoder
integer nfrange        !Frequency range of main display         GUI
integer nport          !Requested COM port number               GUI
integer mousedf        !Mouse-selected freq offset, DF          GUI
integer neme           !EME calls only in deep search?          GUI
integer nsked          !Sked mode for deep search?              GUI
integer naggressive    !Is "Aggressive decoding" checked?       GUI
integer ntx2           !Is "No shorthands if Tx1" checked?      GUI
integer nslim2         !2nd Decoder threshold for FSK441. JT6M  GUI
integer nagain         !Decode same file again?                 GUI
integer nsavelast      !Save last file?                         GUI
integer shok           !Shorthand messages OK?                  GUI
integer sendingsh      !Sending a shorthand message?            SoundIn
integer*2 d2a          !Rx data, extracted from y1              Decoder
integer*2 d2b          !Rx data, selected by mouse-pick         Decoder
integer*2 b            !Pixel values for waterfall spectrum     GUI
integer jza            !Length of data in d2a                GUI,Decoder
integer jzb            !(why is this here?)
integer ntime          !Integer Unix time (now)               SoundIn
integer idinterval     !Interval between CWIDs, minutes         GUI
integer msmax          !(why is this here?)
integer lenappdir      !Length of Appdir string                 GUI
integer idf            !Frequency offset in Hz                  Decoder
integer ndiskdat       !1 if data read from disk, 0 otherwise   GUI
integer nlines         !Available lines of waterfall data       GUI
integer nflat          !Is waterfall to be flattened?           GUI
integer ntxreq         !Tx msg# requested                       GUI
integer ntxnow         !Tx msg# being sent now                  GUI
integer ndepth         !Requested "depth" of JT65 decoding      GUI
integer nspecial       !JT65 shorthand msg#: RO=2 RRR=3 73=4    Decoder
integer ndf            !Measured DF in Hz                       Decoder
real ss1               !Magenta curve for JT65 shorthand msg    Decoder
real ss2               !Orange curve for JT65 shorthand msg     Decoder
character mycall*12    !My call sign                            GUI
character hiscall*12   !His call sign                           GUI
character hisgrid*6    !His grid locator                        GUI
character txmsg*28     !Message to be transmitted               GUI
character sending*28   !Message being sent                      SoundIn
character mode*6       !WSJT operating mode                     GUI
character utcdate*12   !UTC date                                GUI
character*24 fname0    !Filenames to be recorded, read, ...     Decoder
character*24 fnamea
character*24 fnameb
character*24 decodedfile
character*80 AppDir      !WSJT installation directory           GUI
character*80 filetokilla !Filenames (full path)                 Decoder
character*80 filetokillb
character*12 pttport

common/gcom2/ps0(431),psavg(450),s2(64,3100),ccf(-5:540),             &
     green(500),ngreen,dgain,iter,ndecoding,ndecoding0,mousebutton,   &
     ndecdone,npingtime,ierr,lauto,mantx,nrestart,ntr,nmsg,nsave,nadd5, &
     dftolerance,LDecoded,rxdone,monitoring,nzap,nsavecum,minsigdb,   &
     nclearave,nfreeze,nafc,nmode,mode65,nclip,ndebug,nblank,nport,   &
     mousedf,neme,nsked,naggressive,ntx2,nslim2,nagain,nsavelast,     &
     shok,sendingsh,d2a(661500),d2b(661500),b(60000),jza,jzb,ntime,   &
     idinterval,msmax,lenappdir,idf,ndiskdat,nlines,nflat,ntxreq,ntxnow,  &
     ndepth,nspecial,ndf,nfmid,nforce,nfrange,ss1(-224:224),ss2(-224:224),   &
     mycall,hiscall,hisgrid,txmsg,sending,mode,fname0,fnamea,         &
     fnameb,decodedfile,AppDir,filetokilla,filetokillb,utcdate,pttport

!### volatile /gcom2/
