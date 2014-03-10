cmake_minimum_required (VERSION 2.8.8)

project (libwsprx C Fortran)

if (POLICY CMP0020)
  cmake_policy (SET CMP0020 NEW) # link to Qt winmain on Windows
endif (POLICY CMP0020)

# make sure that the default is a RELEASE
if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE RELEASE CACHE STRING
    "Choose the type of build, options are: None Debug Release."
    FORCE)
endif (NOT CMAKE_BUILD_TYPE)

set (CMAKE_POSITION_INDEPENDENT_CODE ON)


#
# Fortran setup
#

# FFLAGS depend on the compiler
get_filename_component (Fortran_COMPILER_NAME ${CMAKE_Fortran_COMPILER} NAME)

if (Fortran_COMPILER_NAME MATCHES "gfortran.*")
  # gfortran
  set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fno-f2c -O3")
  set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -g")
elseif (Fortran_COMPILER_NAME MATCHES "ifort.*")
  # ifort (untested)
  set (CMAKE_Fortran_FLAGS_RELEASE "-f77rtl -O3")
  set (CMAKE_Fortran_FLAGS_DEBUG   "-f77rtl -O0 -g")
elseif (Fortran_COMPILER_NAME MATCHES "g77")
  # g77
  set (CMAKE_Fortran_FLAGS_RELEASE "-funroll-all-loops -fno-f2c -O3 -m32")
  set (CMAKE_Fortran_FLAGS_DEBUG   "-fno-f2c -O0 -g -m32")
else (Fortran_COMPILER_NAME MATCHES "gfortran.*")
  message ("CMAKE_Fortran_COMPILER full path: " ${CMAKE_Fortran_COMPILER})
  message ("Fortran compiler: " ${Fortran_COMPILER_NAME})
  message ("No optimized Fortran compiler flags are known, we just try -O2...")
  set (CMAKE_Fortran_FLAGS_RELEASE "-O2")
  set (CMAKE_Fortran_FLAGS_DEBUG   "-O0 -g")
endif (Fortran_COMPILER_NAME MATCHES "gfortran.*")

# setup and test Fortran C/C++ interaction

include (FortranCInterface)
FortranCInterface_VERIFY (CXX QUIET)
FortranCInterface_HEADER (FC.h MACRO_NAMESPACE "FC_" SYMBOL_NAMESPACE "FC_"
  SYMBOLS )


set (FSRCS
 WSPRcode.f90
 blanker.f90
 db.f90
 decode162.f90
 encode232.f90
 fano232.f90
 fil3.f90
 fil3c.f90
 four2a.f90
 genwsprx.f90
 hash.f90
 mept162a.f90
 mix162.f90
 mix162a.f90
 mixlpf.f90
 morse.f90
 packgrid.f90
 packpfx.f90
 pctile.f90
 redsync.f90
 savec2.f90
 symspec.f90
 sync162.f90
 timf2.f90
 unpackgrid.f90
 unpackpfx.f90
 wqdecode.f90
 wqencode.f90
 wspr0.f90
 wsprd.f90
 wsprd_init.f90

 ccf2.f
 deg2grid.f
 fchisq.f
 flat3.f
 getrms.f
 grid2deg.f
 inter_mept.f
 nchar.f
 pack50.f
 packcall.f
 ps162.f
 set.f
 sort.f
 ssort.f
 twkfreq.f
 unpack50.f
 unpackcall.f
 xfft.f
  )

set (CSRCS
 nhash.c
)

if (WIN32)
  set (CSRCS ${CSRCS} ptt.c)
else (set (CSRCS ${CSRCS} ptt_unix.c))
endif (WIN32)


add_definitions (-DBIGSYM=1)
set_source_files_properties (sec_midn.f90 PROPERTIES COMPILE_FLAGS -fno-second-underscore)


#
# build our targets
#
add_library (wsprximpl STATIC ${FSRCS} ${CSRCS})
qt5_use_modules (wsprximpl Core)

add_executable (wsprd wsprd.f90)
target_link_libraries (wsprd wsprximpl ${fftw3f_LIBRARIES})
add_dependencies (wsprd fftw3f)
qt5_use_modules (wsprd Core)

install (
  TARGETS wsprd
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  )
