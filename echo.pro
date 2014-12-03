#-------------------------------------------------
#
# Project created by QtCreator 2011-07-07T08:39:24
#
#-------------------------------------------------

QT       += core gui network widgets
CONFIG   += thread
#CONFIG   += console

TARGET = echox
VERSION = 0.8
TEMPLATE = app
DESTDIR = ../echo_install

F90 = gfortran
gfortran.output = ${QMAKE_FILE_BASE}.o
gfortran.commands = $$F90 -c -O2 -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
gfortran.input = F90_SOURCES
QMAKE_EXTRA_COMPILERS += gfortran

win32 {
DEFINES = WIN32
}

unix {
DEFINES = UNIX
}

SOURCES += main.cpp mainwindow.cpp plotter.cpp about.cpp \
    soundin.cpp soundout.cpp devsetup.cpp \
    widegraph.cpp \
    getdev.cpp displaytext.cpp \
    meterwidget.cpp signalmeter.cpp \
    echospec.cpp astro.cpp

win32 {
SOURCES +=
}

HEADERS  += mainwindow.h plotter.h soundin.h soundout.h \
            about.h devsetup.h widegraph.h \
            displaytext.h meterwidget.h signalmeter.h \
            echospec.h commons.h astro.h

FORMS    += mainwindow.ui about.ui devsetup.ui widegraph.ui astro.ui

RC_FILE = echo.rc

unix {
    LIBS += ../echo/lib/libecho.a
    LIBS += -lportaudio -lgfortran -lfftw3f
}

win32 {
LIBS += ../echo/lib/libecho.a
LIBS += ../echo/libfftw3f_win.a
LIBS += ../echo/palir-02.dll
LIBS += ../map65/libm65/libastro.a
LIBS += libwsock32
LIBS += -lgfortran
#LIBS += -lusb
}
