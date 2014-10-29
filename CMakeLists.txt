cmake_minimum_required (VERSION 2.8.9 FATAL_ERROR)

project (wsjt-superbuild)

set (__default_tag branches/wsjtx)

set (WSJTX_TAG ${__default_tag}
  CACHE STRING "WSJT-X tag or branch to build, if unset build the latest trunk.

For a tag use tags/<tag-name> e.g. tags/wsjtx-1.4.0-rc2

For a branch use branches/<branch-name> e.g. branches/wsjtx-1.4

The special value of 'LOCAL' is also accepted, if set the build expects the
sources to be found in a directory src in the three files 'hamlib.tgz',
'wsjtx.tgz' and, 'wsjtx-main.html'. This value is to be used where build hosts
do not allow source downloads using Subversion, git or cURL as part of the build.
"
  )


#
# find prerequisites
#
# Find_library (USB_LIBRARY NAMES libusb.a usb)
Find_program (MAKE_EXECUTABLE NAMES make mingw32_make gmake)
Find_program (SVN_EXECUTABLE svn)


#
# extra C flags to minimize hamlib excutable sizes
#
if (NOT APPLE)
  set (EXTRA_FLAGS "CFLAGS=-fdata-sections -ffunction-sections" "LDFLAGS=-Wl,--gc-sections")
endif (NOT APPLE)


#
# work out what we want to build
#
if (NOT WSJTX_TAG STREQUAL "LOCAL")
  # one day this needs to change to the hamlib git master
  set (hamlib_repo git://git.code.sf.net/u/bsomervi/hamlib)

  set (wsjtx_repo svn://svn.code.sf.net/p/wsjt/wsjt/branches/wsjtx)
  set (wsjtx_update_command ${SVN_EXECUTABLE} switch ^/${WSJTX_TAG})

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
else (NOT WSJTX_TAG STREQUAL "LOCAL")
  # location of downloaded User Guide in LOCAL build source tree
  set (wsjtx_user_guide_directory_url -D WSJT_MANUAL_DIRECTORY:STRING=file://${CMAKE_CURRENT_SOURCE_DIR}/src)
endif (NOT WSJTX_TAG STREQUAL "LOCAL")

include (ExternalProject)


#
# build aand install hamlib locally so it can be referenced by the
# WSJT-X build
#
ExternalProject_Add (hamlib
  GIT_REPOSITORY ${hamlib_repo}
  GIT_TAG ${hamlib_TAG}
  URL ${CMAKE_CURRENT_SOURCE_DIR}/src/hamlib.tgz
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND <SOURCE_DIR>/autogen.sh --prefix=<INSTALL_DIR> --disable-shared --enable-static --without-cxx-binding ${EXTRA_FLAGS} # LIBUSB_LIBS=${USB_LIBRARY}
  BUILD_COMMAND ${MAKE_EXECUTABLE} all
  INSTALL_COMMAND ${MAKE_EXECUTABLE} install-strip
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  LOG_INSTALL 1
  )

#
# custom target to make a hamlib source tarball
#
ExternalProject_Get_Property (hamlib SOURCE_DIR)
add_custom_target (hamlib_sources
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/hamlib
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/hamlib
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/hamlib/.git
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/src
  COMMAND ${CMAKE_COMMAND} -E tar czf ${CMAKE_CURRENT_SOURCE_DIR}/src/hamlib.tgz ${CMAKE_CURRENT_BINARY_DIR}/hamlib
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/hamlib
  DEPENDS hamlib
  COMMENT "Generating and embedding the hamlib upstream source tarball"
  )


#
# build and optionally install WSJT-X using the hamlib package built
# above
#
ExternalProject_Get_Property (hamlib INSTALL_DIR)
ExternalProject_Add (wsjtx
  DEPENDS hamlib
  SVN_REPOSITORY ${wsjtx_repo}
  UPDATE_COMMAND ${wsjtx_update_command}
  URL ${CMAKE_CURRENT_SOURCE_DIR}/src/wsjtx.tgz
  CMAKE_ARGS
  -D CMAKE_PREFIX_PATH=${INSTALL_DIR}
  -D CMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  ${wsjtx_user_guide_directory_url}
  INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
  LOG_UPDATE 1
  LOG_CONFIGURE 1
  LOG_BUILD 1
  STEP_TARGETS build install package
  )
ExternalProject_Get_Property (wsjtx BINARY_DIR)
ExternalProject_Add_Step (wsjtx package
  COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target package
  COMMAND echo "Built hamlib from branch/tag: ${hamlib_TAG}"
  COMMAND echo "Built WSJT-X from: ${WSJTX_TAG}"
  COMMAND echo "Package(s) generated in ${BINARY_DIR}."
  COMMENT "Generating WSJT-X package."
  DEPENDEES build
  )

set_target_properties (wsjtx PROPERTIES EXCLUDE_FROM_ALL 1)

# export traditional targets
add_custom_target (build ALL DEPENDS wsjtx-build)
add_custom_target (install DEPENDS wsjtx-install)
add_custom_target (package DEPENDS wsjtx-package)


#
# custom target to make WSJT-X source tarball
#
ExternalProject_Get_Property (wsjtx SOURCE_DIR)
add_custom_target (wsjtx_sources
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/wsjtx
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/wsjtx
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/wsjtx/.svn
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/src
  COMMAND ${CMAKE_COMMAND} -E tar czf ${CMAKE_CURRENT_SOURCE_DIR}/src/wsjtx.tgz ${CMAKE_CURRENT_BINARY_DIR}/wsjtx
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/wsjtx
  COMMAND ${CMAKE_COMMAND} -E copy ${BINARY_DIR}/contrib/wsjtx-main.html ${CMAKE_CURRENT_SOURCE_DIR}/src
  DEPENDS wsjtx-build
  COMMENT "Generating and embedding the WSJT-X upstream source tarball"
  )


#
# custom target to build a self-contained source tarball suitable for
# a local build
#
add_custom_target (source
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/${__suffix}
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/${__suffix}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/${__suffix}/.svn
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/${__suffix}/.git
  COMMAND ${CMAKE_COMMAND} -E tar czf ${__suffix}.tgz ${CMAKE_CURRENT_BINARY_DIR}/${__suffix}
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/${__suffix}
  DEPENDS hamlib_sources wsjtx_sources
  COMMENT "
Generating the WSJT-X superbuild self-contained source tarball ${__suffix}.tgz

To use this tarball, transfer it to the target build host, un-tar it, configure with
the CMake option WSJTX_TAG=LOCAL and CMAKE_INSTALL_PREFIX if required (default is /usr),
then build and install. For example:

    $ tar xzf ${__suffix}.tgx
    $ mkdir build
    $ cd build
    $ cmake -D WSJTX_TAG=LOCAL ../${__suffix}
    $ cmake --build .
    $ sudo cmake --build . --target install

"
  )
