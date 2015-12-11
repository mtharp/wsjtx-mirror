cmake_minimum_required (VERSION 2.8.10 FATAL_ERROR)

project (wsjt-superbuild)

set (__default_tag branches/wsjtx)

set (WSJTX_TAG ${__default_tag}
  CACHE STRING "WSJT-X tag or branch to build, if unset build the latest trunk.

For a tag use tags/<tag-name> e.g. tags/wsjtx-1.4.0-rc2

For a branch use branches/<branch-name> e.g. branches/wsjtx-1.4

The  WSJTX_TAG option  is  only used  if the  directory  'src' is  not
present.   If the  'src' directory  is present  the build  expects the
sources to be found in it consisting of the two files 'hamlib.tgz' and
'wsjtx.tgz'.  This 'src' directory is to  be used where build hosts do
not allow  source downloads using Subversion,  git or cURL as  part of
the build.  See the  'source' target  for how  to generate  a suitable
source tarball." )


#
# find prerequisites
#
# Find_library (USB_LIBRARY NAMES libusb.a usb)
Find_program (PATCH_EXECUTABLE patch REQUIRED)


#
# extra C flags to minimize hamlib excutable sizes
#
if (NOT APPLE)
  set (EXTRA_FLAGS "CFLAGS=-fPIC -fdata-sections -ffunction-sections" "LDFLAGS=-Wl,--gc-sections")
endif (NOT APPLE)


#
# function to read and extract MD5 hashes from a file
#
function (read_md5sum file result_variable)
  file (READ ${file}.md5sum md5sum)
  string (REGEX REPLACE "^([^ ]+).*$" "\\1" md5sum ${md5sum})
  set (${result_variable} ${md5sum} PARENT_SCOPE)
endfunction (read_md5sum)


#
# work out what we want to build
#
if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src")
  # one day this needs to change to the hamlib git master
  set (hamlib_repo git://git.code.sf.net/u/bsomervi/hamlib)

  set (wsjtx_repo svn://svn.code.sf.net/p/wsjt/wsjt/${WSJTX_TAG})

  string (FIND ${WSJTX_TAG} / __pos REVERSE)

  # validate tag, not rigorous but git/svn will error out if
  # calculated tags or branches don't exist
  if (__pos EQUAL -1)
    message (FATAL_ERROR "Invalid TAG format.")
  endif (__pos EQUAL -1)

  # one day this needs to change to master or some agreed stable SHA
  set (hamlib_TAG integration)

  # split the WSJTX_TAG variable
  string (SUBSTRING ${WSJTX_TAG} 0 ${__pos} __prefix)
  math (EXPR __pos "${__pos} + 1")
  string (SUBSTRING ${WSJTX_TAG} ${__pos} -1 __suffix)

  # decide if we want to build from a branch or a tag
  if (NOT __prefix STREQUAL branches)
    # assume we have a tag so find matching hamlib tag
    #
    # this assumed that a tag exists in the hamlib repository that is
    # exactly the same as the WSJT-X repository tag we intend to build
    # from
    set (hamlib_TAG "${__suffix}")
    message (STATUS "Building WSJT-X tag: ${WSJTX_TAG}")
    message (STATUS "hamlib tag: ${hamlib_TAG}")
  else (NOT __prefix STREQUAL branches)
    message (STATUS "Building WSJT-X branch: ${WSJTX_TAG}")
    message (STATUS "hamlib branch: ${hamlib_TAG}")
  endif (NOT __prefix STREQUAL branches)
else (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src")
  read_md5sum (src/hamlib.tgz hamlib_md5sum)
  read_md5sum (src/wsjtx.tgz wsjtx_md5sum)
endif (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src")


include (ExternalProject)


#
# build and install hamlib locally so it can be referenced by the
# WSJT-X build
#
ExternalProject_Add (hamlib
  GIT_REPOSITORY ${hamlib_repo}
  GIT_TAG ${hamlib_TAG}
  URL ${CMAKE_CURRENT_SOURCE_DIR}/src/hamlib.tgz
  URL_HASH MD5=${hamlib_md5sum}
  PATCH_COMMAND ${PATCH_EXECUTABLE} -p1 -N < ${CMAKE_CURRENT_SOURCE_DIR}/hamlib.patch
  CONFIGURE_COMMAND <SOURCE_DIR>/autogen.sh --prefix=<INSTALL_DIR> --disable-shared --enable-static --without-cxx-binding ${EXTRA_FLAGS} # LIBUSB_LIBS=${USB_LIBRARY}
  BUILD_COMMAND $(MAKE) all V=1 # $(MAKE) is ExternalProject_Add() magic to do recursive make
  INSTALL_COMMAND $(MAKE) install-strip V=1 DESTDIR=""
  STEP_TARGETS update install
  )

#
# custom target to make a hamlib source tarball
#
ExternalProject_Get_Property (hamlib SOURCE_DIR)
ExternalProject_Get_Property (hamlib TMP_DIR)
add_custom_target (hamlib_sources
  COMMAND ${CMAKE_COMMAND} -E make_directory hamlib
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR} hamlib
  COMMAND ${CMAKE_COMMAND} -E remove_directory hamlib/.git
  COMMAND ${CMAKE_COMMAND} -E tar czf ${CMAKE_CURRENT_BINARY_DIR}/hamlib.tgz hamlib
  COMMAND ${CMAKE_COMMAND} -E remove_directory hamlib
  WORKING_DIRECTORY ${TMP_DIR}
  DEPENDS hamlib-update
  COMMENT "Generating the hamlib upstream source tarball"
  )


#
# build a list of command line argumenst to pass on to the WSJT-X
# build
#
get_cmake_property (CACHE_VARS CACHE_VARIABLES)
foreach (CACHE_VAR ${CACHE_VARS})
  get_property (CACHE_VAR_HELPSTRING CACHE ${CACHE_VAR} PROPERTY HELPSTRING)
  if (CACHE_VAR_HELPSTRING STREQUAL "No help, variable specified on the command line.")
    get_property (CACHE_VAR_TYPE CACHE ${CACHE_VAR} PROPERTY TYPE)
    if (CACHE_VAR_TYPE STREQUAL "UNINITIALIZED")
      set (CACHE_VAR_TYPE)
    else ()
      set (CACHE_VAR_TYPE :${CACHE_VAR_TYPE})
    endif ()
    list (APPEND CMAKE_ARGS "-D${CACHE_VAR}${CACHE_VAR_TYPE}=${${CACHE_VAR}}")
  endif ()
endforeach ()

#
# build and optionally install WSJT-X using the hamlib package built
# above
#
ExternalProject_Get_Property (hamlib INSTALL_DIR)
ExternalProject_Add (wsjtx
  SVN_REPOSITORY ${wsjtx_repo}
  URL ${CMAKE_CURRENT_SOURCE_DIR}/src/wsjtx.tgz
  URL_HASH MD5=${wsjtx_md5sum}
  PATCH_COMMAND ${PATCH_EXECUTABLE} -p1 -N < ${CMAKE_CURRENT_SOURCE_DIR}/wsjtx.patch
  CMAKE_ARGS
  ${CMAKE_ARGS}
  -DCMAKE_PREFIX_PATH=${INSTALL_DIR}
  -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  ${WSJTX_EXTRA_CMAKE_OPTIONS}
  INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
  STEP_TARGETS update configure build install
  )
ExternalProject_Add_Step (wsjtx package
  COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target package
  COMMAND echo "Built hamlib from branch/tag: ${hamlib_TAG}"
  COMMAND echo "Built WSJT-X from: ${WSJTX_TAG}"
  COMMAND echo "Package(s) generated in ${BINARY_DIR}."
  COMMENT "Generating WSJT-X package."
  DEPENDEES build
  )

set_target_properties (hamlib PROPERTIES EXCLUDE_FROM_ALL 1)
set_target_properties (wsjtx PROPERTIES EXCLUDE_FROM_ALL 1)

add_dependencies (wsjtx-configure hamlib-install)
add_dependencies (wsjtx-build hamlib-install)
add_dependencies (wsjtx-install hamlib-install)

# export traditional targets
add_custom_target (build ALL DEPENDS wsjtx-build)
add_custom_target (install DEPENDS wsjtx-install)
add_custom_target (package DEPENDS wsjtx-package)


#
# custom target to make WSJT-X source tarball
#
ExternalProject_Get_Property (wsjtx SOURCE_DIR)
ExternalProject_Get_Property (wsjtx TMP_DIR)
add_custom_target (wsjtx_sources
  COMMAND ${CMAKE_COMMAND} -E make_directory wsjtx
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR} wsjtx
  COMMAND ${CMAKE_COMMAND} -E remove_directory wsjtx/.svn
  COMMAND ${CMAKE_COMMAND} -E tar czf ${CMAKE_CURRENT_BINARY_DIR}/wsjtx.tgz wsjtx
  COMMAND ${CMAKE_COMMAND} -E remove_directory wsjtx
  WORKING_DIRECTORY ${TMP_DIR}
  DEPENDS wsjtx-update
  COMMENT "Generating the WSJT-X upstream source tarball"
  )


#
# custom target to build a self-contained source tarball suitable for
# a local build
#
add_custom_target (source
  COMMAND ${CMAKE_COMMAND} -E make_directory ${__suffix}
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR} ${__suffix}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${__suffix}/.svn
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${__suffix}/.git
  COMMAND ${CMAKE_COMMAND} -E make_directory ${__suffix}/src
  COMMAND ${CMAKE_COMMAND} -E rename hamlib.tgz ${__suffix}/src/hamlib.tgz
  COMMAND ${CMAKE_COMMAND} -E rename wsjtx.tgz ${__suffix}/src/wsjtx.tgz
  COMMAND ${CMAKE_COMMAND} -E md5sum ${__suffix}/src/hamlib.tgz > ${__suffix}/src/hamlib.tgz.md5sum
  COMMAND ${CMAKE_COMMAND} -E md5sum ${__suffix}/src/wsjtx.tgz > ${__suffix}/src/wsjtx.tgz.md5sum
  COMMAND ${CMAKE_COMMAND} -E tar czf ${__suffix}.tgz ${__suffix}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${__suffix}
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  DEPENDS hamlib_sources wsjtx_sources
  COMMENT "

Generating the WSJT-X superbuild self-contained source tarball ${__suffix}.tgz

To use this  tarball, transfer it to the target  build host, un-tar it
and, configure  it including  a CMAKE_INSTALL_PREFIX if  required (the
default is /usr/local), then build and install. For example:

    $ tar xzf ${__suffix}.tgz
    $ mkdir build
    $ cd build
    $ cmake <extra-args> ../${__suffix}
    $ cmake --build .
    $ sudo cmake --build . --target install

where <extra-args>  are CMake  command line arguments  that are  to be
passed  onto  the  WSJT-X  CMake  configuration.  The  sort  of  extra
arguments you might want to pass are for example:

  -D WSJT_MANPAGE_DESTINATION=.

which   changes    the   install   path   for    the   manpages   from
<install-prefix>/share to  <install-prefix>.  This  particular example
might be useful on FreeBSD where manpages are expected to reside under
/usr/local/man.

A test install may be carried out in a local user directory by passing
the DESTDIR variable to the build step e.g.:

    $ cmake --build . --target install -- -j2 DESTDIR=$HOME/local

which would install into ~/local/usr/local.

" )
