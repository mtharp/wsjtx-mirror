subroutine ephem(mjd0,east_long,geodetic_lat,height,RA,Dec,Az,El,techo,   &
          dop,fspread_1GHz)

  implicit real*8 (a-h,o-z)
  real*8 jd                      !Time of observationa as a Julian Date
  real*8 mjd,mjd0                !Modified Julian Date
  real*8 prec(3,3)               !Precession matrix, J2000 to Date
  real*8 rme2000(6)              !Vector from Earth center to Moon, JD2000
  real*8 rmeDate(6)              !Vector from Earth center to Moon at Date
  real*8 raeDate(6)              !Vector from Earth center to Obs at Date
  real*8 rmaDate(6)              !Vector from Obs to Moon at Date
  real*8 xl(2),b(2)
  logical km,bary,jplok          !Set km=.true. to get km, km/s from ephemeris
  common/stcomx/km,bary,pvsun(6) !Common used in JPL subroutines
  save xl,b

  twopi=8.d0*atan(1.d0)          !Define some constants
  rad=360.d0/twopi
  clight=2.99792458d5
  au2km=0.1495978706910000d9
  pi=0.5d0*twopi
  pio2=0.5d0*pi
  km=.true.
  freq=1000.0d6

  do jj=1,2
     mjd=mjd0
     if(jj.eq.1) mjd=mjd - 1.d0/1440.d0
     jd=2400000.5d0 + mjd
     ttmjd=mjd + sla_DTT(jd)/86400.d0
     ttjd=jd + sla_DTT(jd)/86400.d0

     inquire(file='JPLEPH',exist=jplok)
     if(jplok) then
        call pleph(ttjd,10,3,rme2000)            !RME (J2000) from JPL ephemeris

        year=2000.d0 + (jd-2451545.d0)/365.25d0
        call sla_PREC (2000.0d0, year, prec)     !Get precession matrix
        rmeDate(1:3)=matmul(prec,rme2000(1:3))   !Moon geocentric xyz at Date
        rmeDate(4:6)=matmul(prec,rme2000(4:6))   !Moon geocentric vel at Date
     else
        call sla_DMOON(ttmjd,rmeDate)            !No JPL ephemeris, use DMOON
        rmeDate=rmeDate*au2km
     endif

! Local Apparent Sid Time:
     xlast=sla_DRANRM(sla_GMST(mjd) + sla_EQEQX(ttmjd) + east_long)
     call sla_PVOBS(geodetic_lat,height,xlast,raeDate)
     raeDate=raeDate*au2km
     rmaDate=rmeDate - raeDate


     tmpmjd=int(jd-2400000.5d0)                !Modified Julian Day number
     ut=(jd-2400000.5d0-tmpmjd)*24.d0          !UT (hours)
     if(ut.lt.20.d0) ut=ut+24.d0      !### Temp, for plotting convenience

!Topocentric RA, Dec, dist, velocity
     call sla_DC62S(rmaDate,RA,Dec,dist,RAdot,DECdot,vr)
     dop=-2.d0 * freq * vr/clight                    !EME doppler shift
     techo=2.d0*dist/clight                          !Echo delay time (s)
     call libration(jd,RA,Dec,xl(jj),b(jj))
  enddo

  fspread_1GHz=0.0d0
  dldt=57.2957795131*(xl(2)-xl(1))
  dbdt=57.2957795131*(b(2)-b(1))
  rate=sqrt((2*dldt)**2 + (2*dbdt)**2)
  fspread_1GHz=0.5*6741*rate

  call sla_DE2H(xlast-RA,Dec,geodetic_lat,Az,El)

  return
end subroutine ephem
