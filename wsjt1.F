        subroutine wsjt1(d,jz0,istart,samfacin,FileID,ndepth,
     +    MinSigdB,NQRN,DFTolerance,MouseButton,NClearAve,nforce,
     +    Mode,NFreeze,NAFC,NZap,mode65,mode4,idf,ntdecode0,
     +    MyCall,HisCall,HisGrid,neme,ntx2,s2,
     +    ps0,npkept,lumsg,basevb,rmspower,nslim2,psavg,ccf,Nseg,
     +    MouseDF,NAgain,LDecoded,nspecial,ndf,ss1,ss2)

!       lparameter (NP2=1024*1024)
        parameter (NP2=120*12000)

        integer*2 d(jz0)        !Buffer for raw one-byte data
        integer istart          !Starting location in original d() array
        character FileID*40     !Name of file being processed
        integer MinSigdB        !Minimum ping strength, dB
        integer NQRN            !QRN rejection parameter
        integer DFTolerance     !Defines DF search range
        integer NSyncOK         !Set to 1 if JT65 file synchronized OK
        character*12 mycall
        character*12 hiscall
        character*6 hisgrid
        real ps0(431)           !Spectrum of best ping
        integer npkept          !Number of pings kept and decoded
        integer lumsg           !Logical unit for decoded.txt
        real basevb             !Baseline signal level, dB
        integer nslim2          !Minimum strength for single-tone pings, dB
        real psavg(450)         !Average spectrum of the whole file
        integer Nseg            !First or second Tx sequence?
        integer MouseDF         !Freeze position for DF
        logical pick            !True if this is a mouse-picked ping
        logical stbest          !True if the best decode was Single-Tone
        logical STfound         !True if at least one ST decode
        logical LDecoded        !True if anything was decoded
        real s2(64,3100)        !2D spectral array
        real ccf(-5:540)        !X-cor function in JT65 mode (blue line)
        real red(512)
        real ss1(-224:224)      !Magenta curve (for JT65 shorthands)
        real ss2(-224:224)      !Orange curve (for JT65 shorthands)
        real yellow(216)
        real yellow0(216)
        real fzap(200)
        integer resample
        real*8 samfacin,samratio
        real dat2(NP2)
        character msg3*3
        character cfile6*6
        logical lcum
        integer indx(100)
        character*90 line
        common/avecom/dat(NP2),labdat,jza,modea
        common/ccom/nline,tping(100),line(100)
        common/limcom/ nslim2a
        common/extcom/ntdecode
        common/clipcom/ nclip
        save

! 900    LDecoded = ((NSyncOK.gt.0) .or. npkept.gt.0)
 900    end file 11
        call flushqqq(11)
        call flushqqq(12)
        call flushqqq(21)

        return
        end

