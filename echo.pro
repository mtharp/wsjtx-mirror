QT       += core gui network widgets
CONFIG   += thread
#CONFIG   += console

TARGET = emecho
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

SOURCES += f90/avecho.f90 f90/pctile.f90 f90/sort.f90 f90/ssort.f90 \
           f90/smo121.f90 f90/fil4.f90 f90/four2a.f90 f90/commons.f90

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
LIBS += ../echo/libfftw3f_win.a
LIBS += ../echo/palir-02.dll
LIBS += ../map65/libm65/libastro.a
LIBS += libwsock32
LIBS += -lgfortran
#LIBS += -lusb
}
