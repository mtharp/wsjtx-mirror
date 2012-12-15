#-------------------------------------------------
#
# Project created by QtCreator 2011-07-07T08:39:24
#
#-------------------------------------------------

QT       += core gui network
CONFIG   += qwt thread
#CONFIG   += console

TARGET = wsprx
VERSION = 0.5
TEMPLATE = app

win32 {
DEFINES = WIN32
DESTDIR = ../wsprx_install
F90 = g95
g95.output = ${QMAKE_FILE_BASE}.o
g95.commands = $$F90 -c -O2 -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
g95.input = F90_SOURCES
QMAKE_EXTRA_COMPILERS += g95
}

unix {
DEFINES = UNIX
DESTDIR = ../wsprx_install
F90 = gfortran
gfortran.output = ${QMAKE_FILE_BASE}.o
gfortran.commands = $$F90 -c -O2 -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
gfortran.input = F90_SOURCES
QMAKE_EXTRA_COMPILERS += gfortran
}

SOURCES += main.cpp mainwindow.cpp plotter.cpp about.cpp \
    soundin.cpp soundout.cpp devsetup.cpp \
    widegraph.cpp getfile.cpp \
    getdev.cpp displaytext.cpp

win32 {
SOURCES +=
}

HEADERS  += mainwindow.h plotter.h soundin.h soundout.h \
            about.h devsetup.h widegraph.h getfile.h \
            commons.h sleep.h displaytext.h

DEFINES += __cplusplus

FORMS    += mainwindow.ui about.ui devsetup.ui widegraph.ui

RC_FILE = wsprx.rc

unix {
INCLUDEPATH += $$quote(/usr/include/qwt-qt4)
LIBS += -lfftw3f /usr/lib/libgfortran.so.3
LIBS += ../wsprx/lib/libwspr.a
LIBS += /usr/lib/libqwt-qt4.so
LIBS += -lportaudio
}

win32 {
INCLUDEPATH += c:/qwt-6.0.1/include
LIBS += ../wsprx/lib/libwspr.a
LIBS += ../wsprx/libfftw3f_win.a
LIBS += ../QtSupport/palir-02.dll
LIBS += libwsock32
LIBS += C:/MinGW/lib/libf95.a
CONFIG(release) {
   LIBS += C:/qwt-6.0.1/lib/qwt.dll
} else {
   LIBS += C:/qwt-6.0.1/lib/qwtd.dll
}
LIBS += -lusb
}
