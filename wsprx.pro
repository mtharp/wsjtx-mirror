#-------------------------------------------------
#
# Project created by QtCreator 2011-07-07T08:39:24
#
#-------------------------------------------------

QT       += core gui network widgets
CONFIG   += thread
#CONFIG   += console

TARGET = wsprx
VERSION = 0.8
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
    getdev.cpp displaytext.cpp \
    wsprnet.cpp meterwidget.cpp signalmeter.cpp

win32 {
SOURCES +=
}

HEADERS  += mainwindow.h plotter.h soundin.h soundout.h \
            about.h devsetup.h widegraph.h getfile.h \
            commons.h displaytext.h \
            wsprnet.h meterwidget.h signalmeter.h

FORMS    += mainwindow.ui about.ui devsetup.ui widegraph.ui

RC_FILE = wsprx.rc

unix {
    LIBS += ../wsprx/lib/libwspr.a
    LIBS += -lportaudio -lgfortran -lfftw3f
}

win32 {
LIBS += ../wsprx/lib/libwspr.a
LIBS += ../wsprx/libfftw3f_win.a
LIBS += ../QtSupport/palir-02.dll
LIBS += libwsock32
LIBS += C:/MinGW/lib/libf95.a
#LIBS += -lusb
}
