      subroutine wfile5(iwave,nmax,nfsample,outfile)

C  Write a wavefile to disk.

      integer*2 iwave(nmax)
      character*70 outfile

      integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
      character*4 ariff,awave,afmt,adata
      integer*1 hdr(44)
      common/hdr/ariff,nchunk,awave,afmt,lenfmt,nfmt2,nchan2,
     +     nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata
      equivalence (hdr,ariff)

C  Generate the header
      ariff='RIFF'
      awave='WAVE'
      afmt='fmt '
      adata='data'
      lenfmt=16                       !Rest of this sub-chunk is 16 bytes long
      nfmt2=1                               !PCM = 1
      nchan2=1                              !1=mono, 2=stereo
      nbitsam2=16                           !Bits per sample
      nsamrate=nfsample
      nbytesec=nfsample*nchan2*nbitsam2/8   !Bytes per second
      nbytesam2=nchan2*nbitsam2/8           !Block-align               
      ndata=nmax*nchan2*nbitsam2/8
      nbytes=ndata+44
      nchunk=nbytes-8

#ifdef CVF
      open(12,file=outfile,form='binary',status='unknown')
#else
      open(12,file=outfile,access='stream',status='unknown')
#endif

      write(12) hdr
      write(12) iwave
      close(12)

      return
      end

