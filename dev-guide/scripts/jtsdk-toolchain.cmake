# JTSDK-QT Tool-Chain File
# Part of the JTSDK Project
SET (CMAKE_SYSTEM_NAME Windows)
SET (BASED /JTSDK-QT)
SET (QTDIR /qt5/5.2.1/mingw48_32)
# SET (HAMLIB /hamlib)
SET (HAMLIB /hamlib3/mingw32)
SET (FFTW /fftw3f)
SET (CMAKE_PREFIX_PATH ${QTDIR} ${FFTW} ${FFTW} ${HAMLIB} ${HAMLIB}/bin)
SET (CMAKE_FIND_ROOT_PATH ${BASED})
SET (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
SET (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)