#-------------------------------------------------
#
# Project created by QtCreator 2011-07-07T08:39:24
#
#-------------------------------------------------

QT       += core gui network
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
CONFIG   += thread
#CONFIG   += console

TARGET = map65
VERSION = 2.3.0
TEMPLATE = app
DEFINES = QT5

win32 {
DEFINES = WIN32
DESTDIR = ../map65_install
F90 = g95
g95.output = ${QMAKE_FILE_BASE}.o
g95.commands = $$F90 -c -O2 -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
g95.input = F90_SOURCES
QMAKE_EXTRA_COMPILERS += g95
}

unix {
DEFINES = UNIX
DESTDIR = ../map65_install
F90 = gfortran
gfortran.output = ${QMAKE_FILE_BASE}.o
gfortran.commands = $$F90 -c -O2 -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
gfortran.input = F90_SOURCES
QMAKE_EXTRA_COMPILERS += gfortran
}

SOURCES += main.cpp mainwindow.cpp plotter.cpp about.cpp \
    soundin.cpp soundout.cpp devsetup.cpp \
    widegraph.cpp getfile.cpp messages.cpp bandmap.cpp \
    astro.cpp displaytext.cpp getdev.cpp \
    txtune.cpp meterwidget.cpp signalmeter.cpp

win32 {
SOURCES += killbyname.cpp     set570.cpp
}

HEADERS  += mainwindow.h plotter.h soundin.h soundout.h \
            about.h devsetup.h widegraph.h getfile.h messages.h \
            bandmap.h commons.h sleep.h astro.h displaytext.h \
            txtune.h meterwidget.h signalmeter.h

FORMS    += mainwindow.ui about.ui devsetup.ui widegraph.ui \
    messages.ui bandmap.ui astro.ui \
    txtune.ui

RC_FILE = map65.rc

unix {
LIBS += ../map65/libm65/libm65.a
LIBS += -lfftw3f -lportaudio -lgfortran
#LIBS +- -lusb
}

win32 {
LIBS += ../map65/libm65/libm65.a
LIBS += ../map65/libfftw3f_win.a
LIBS += /users/joe/wsjt/QtSupport/palir-02.dll
LIBS += libwsock32
LIBS += C:/MinGW/lib/libf95.a
#LIBS += -lusb
LIBS += /users/joe/linrad/3.37/libusb.a
LIBS += -lQt5Concurrent
#LIBS += c:\wsjt-env\Qt5\Tools\mingw48_32\i686-w64-mingw32\lib\libmingwex.a
}
