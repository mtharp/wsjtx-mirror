cmake_minimum_required (VERSION 2.8.9)

project (wsprx C CXX Fortran)

set (WSPRX_VERSION_MAJOR 1)
set (WSPRX_VERSION_MINOR 3)

if (POLICY CMP0020)
  cmake_policy (SET CMP0020 NEW) # link to Qt winmain on Windows
endif (POLICY CMP0020)

# make sure that the default is a RELEASE
if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE RELEASE CACHE STRING
    "Choose the type of build, options are: None Debug Release."
    FORCE)
endif (NOT CMAKE_BUILD_TYPE)

# C++ setup

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

set (CXXSRCS
 about.cpp
 devsetup.cpp
 displaytext.cpp
 getdev.cpp
 getfile.cpp
 main.cpp
 mainwindow.cpp
 meterwidget.cpp
 plotter.cpp
 signalmeter.cpp
 soundin.cpp
 soundout.cpp
 widegraph.cpp
 wsprnet.cpp
  )

if (WIN32)
  set (CXXSRCS ${CXXSRCS} killbyname.cpp)
endif (WIN32)

set (CSRCS
  paInputDevice.c
  pa_get_device_info.c
)

set_property (SOURCE ${CXXSRCS} ${CSRCS} APPEND PROPERTY COMPILE_FLAGS "-include wsprx_config.h")

set (UISRCS
 about.ui
 devsetup.ui
 mainwindow.ui
 widegraph.ui
)

#
# sort out pre-requisites
#

#
# libfftw3 setup
#
find_path (fftw3f_INCLUDES fftw3.f)
find_library (fftw3f_LIBRARIES NAMES fftw3f fftw3f-3)
include_directories (${fftw3f_INCLUDES})

#
# libhamlib setup
#
find_path (hamlib_INCLUDES hamlib/rig.h)
find_library (hamlib_LIBRARIES NAMES hamlib hamlib-2 PATH_SUFFIXES msvc gcc)
include_directories (${hamlib_INCLUDES})

if (WIN32)
   find_library (hamlib_RUNTIME NAMES hamlib hamlib-2 PATH_SUFFIXES bin)
   get_filename_component (_hamlib_runtime_path "${hamlib_RUNTIME}" PATH)
   file (GLOB hamlib_BACKENDS ${_hamlib_runtime_path}/hamlib*.dll)
   find_library (usb_RUNTIME NAMES usb0 PATH_SUFFIXES bin)
endif (WIN32)


#
# Qt5 setup
#

# Widgets finds its own dependencies.
find_package (Qt5Widgets REQUIRED)
find_package (Qt5Multimedia REQUIRED)

# Tell CMake to run moc when necessary
set (CMAKE_AUTOMOC ON)

# don't use Qt "keywords" signal, slot, emit in generated files to
# avoid compatability issue with other libraries
#ADD_DEFINITIONS (-DQT_NO_KEYWORDS)

# As moc files are generated in the binary dir, tell CMake to always
# look for includes there:
set (CMAKE_INCLUDE_CURRENT_DIR ON)

# project definitions
add_definitions (-DQT5)
if (CMAKE_HOST_UNIX)
  add_definitions (-DUNIX)
elseif (CMAKE_HOST_WIN32)
  add_definitions (-DWIN32)
endif ()

set_property (DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS_RELEASE QT_NO_DEBUG_OUTPUT QT_NO_WARNING_OUTPUT)


#
# build the subdirectories
#
add_subdirectory (lib)


#
# fetch kvasd
#
if (APPLE)
  set (kvasd_NAME http://svn.berlios.de/wsvn/wsjt/trunk/KVASD_gfortran_Mac${CMAKE_EXECUTABLE_SUFFIX})
else ()
  set (kvasd_NAME http://www.physics.princeton.edu/pulsar/K1JT/kvasd${CMAKE_EXECUTABLE_SUFFIX})
endif ()
file (
  DOWNLOAD ${kvasd_NAME} contrib/kvasd${CMAKE_EXECUTABLE_SUFFIX}
  STATUS kvasd_STATUS
  LOG kvasd_LOG
  SHOW_PROGRESS
  )
message (${kvasd_LOG})
list (GET kvasd_STATUS 0 kvasd_RC)
if (!kvasd_RC)
  message (FATAL_ERROR "${kvasd_STATUS}")
endif (!kvasd_RC)
add_custom_target (kvasd DEPENDS contrib/kvasd${CMAKE_EXECUTABLE_SUFFIX})


# UI generation
qt5_wrap_ui (GENUISRCS ${UISRCS})

add_executable (wsprx ${CXXSRCS} ${CSRCS} ${GENUISRCS} wsprx.rc)
target_link_libraries (wsprx wsprximpl ${hamlib_LIBRARIES} ${fftw3f_LIBRARIES} C:/wsjt-env/src/map65/palir-02.dll )
if (WIN32)
  target_link_libraries (wsprx)
endif (WIN32)
add_dependencies (wsprx kvasd)
qt5_use_modules (wsprx Widgets Multimedia OpenGL)


install (
  TARGETS wsprx
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  )

#install (DIRECTORY Palettes DESTINATION bin PATTERN *.pal)
#install (DIRECTORY samples DESTINATION bin/save)
install (FILES
  DESTINATION bin
  )

install (
  PROGRAMS ${CMAKE_BINARY_DIR}/contrib/kvasd${CMAKE_EXECUTABLE_SUFFIX}
  DESTINATION bin
)

if (WIN32)
  install (
    FILES ${hamlib_RUNTIME} ${hamlib_BACKENDS} ${fftw3f_LIBRARIES} 
    ${usb_RUNTIME} 
    DESTINATION bin COMPONENT Runtime
    )
endif (WIN32)


# a custom target that is always built
ADD_CUSTOM_TARGET (revisiontag ALL)

# creates svnversion.h using cmake script
ADD_CUSTOM_COMMAND (TARGET revisiontag COMMAND ${CMAKE_COMMAND}
  -DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR} 
  -P ${CMAKE_CURRENT_SOURCE_DIR}/getsvn.cmake)

# explicitly say that the executable depends on custom target
add_dependencies(wsprx revisiontag)

#
# versioning
#
configure_file (
  "${PROJECT_SOURCE_DIR}/wsprx_config.h.in"
  "${PROJECT_BINARY_DIR}/wsprx_config.h"
  )

include_directories ("${PROJECT_BINARY_DIR}")
