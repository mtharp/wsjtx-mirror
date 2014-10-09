cmake_minimum_required (VERSION 2.8.9 FATAL_ERROR)

project (wsjt-superbuild)

set (__default_tag branches/wsjtx)

set (WSJTX_TAG ${__default_tag}
  CACHE STRING "WSJT-X tag or branch to build, if unset build the latest trunk.

For a tag use tags/<tag-name> e.g. tags/wsjtx-1.4.0-rc2

For a branch use branches/<branch-name> e.g. branches/wsjtx-1.4
"
  )

#
# work out what we want to build
#
set (hamlib_TAG integration)
string (FIND ${WSJTX_TAG} / __pos REVERSE)
if (__pos EQUAL -1)
  message (FATAL_ERROR "Invalid TAG format.")
endif (__pos EQUAL -1)
string (SUBSTRING ${WSJTX_TAG} 0 ${__pos} __prefix)
if (NOT __prefix STREQUAL branches)
  # assume we have a tag so find matching hamlib tag
  math (EXPR __pos "${__pos} + 1")
  string (SUBSTRING ${WSJTX_TAG} ${__pos} -1 hamlib_TAG)
  message (STATUS "Building WSJT-X tag: ${WSJTX_TAG}")
  message (STATUS "hamlib tag: ${hamlib_TAG}")
else (NOT __prefix STREQUAL branches)
  message (STATUS "Building WSJT-X branch: ${WSJTX_TAG}")
  message (STATUS "hamlib branch: ${hamlib_TAG}")
endif (NOT __prefix STREQUAL branches)

Find_library (USB_LIBRARY NAMES libusb.a usb)
Find_program (MAKE_EXECUTABLE NAMES make mingw32_make gmake)
Find_program (SVN_EXECUTABLE svn)

if (NOT APPLE)
  set (EXTRA_FLAGS "CFLAGS=-fdata-sections -ffunction-sections" "LDFLAGS=-Wl,--gc-sections")
endif (NOT APPLE)

include (ExternalProject)

ExternalProject_Add (hamlib
  GIT_REPOSITORY git://git.code.sf.net/u/bsomervi/hamlib
  GIT_TAG ${hamlib_TAG}
  CONFIGURE_COMMAND <SOURCE_DIR>/autogen.sh --prefix=<INSTALL_DIR> --disable-shared --enable-static --without-cxx-binding ${EXTRA_FLAGS} # LIBUSB_LIBS=${USB_LIBRARY}
  BUILD_COMMAND ${MAKE_EXECUTABLE} all
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install-strip
#  LOG_UPDATE 1
#  LOG_CONFIGURE 1
#  LOG_BUILD 1
#  LOG_INSTALL 1
  )

ExternalProject_Get_Property (hamlib INSTALL_DIR)
ExternalProject_Add (wsjtx
  DEPENDS hamlib
  SVN_REPOSITORY svn://svn.code.sf.net/p/wsjt/wsjt/branches/wsjtx
  UPDATE_COMMAND ${SVN_EXECUTABLE} switch ^/${WSJTX_TAG}
  CMAKE_ARGS
  -D CMAKE_PREFIX_PATH=${INSTALL_DIR}
  -D CMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
#  LOG_UPDATE 1
#  LOG_CONFIGURE 1
#  LOG_BUILD 1
#  LOG_INSTALL 1
  STEP_TARGETS build install package
  )
ExternalProject_Get_Property (wsjtx BINARY_DIR)
ExternalProject_Add_Step (wsjtx package
  COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target package
  COMMAND echo "Built hamlib from branch/tag: ${hamlib_TAG}"
  COMMAND echo "Built WSJT-X from: ${WSJTX_TAG}"
  COMMAND echo "Package(s) generated in ${BINARY_DIR}."
  COMMENT "Generating package."
  DEPENDEES build
  )
