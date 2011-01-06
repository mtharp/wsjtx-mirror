g95 -o hftoa.exe -Wall -fno-second-underscore -Wno-precision-loss -ftrace=full hftoa.f90 write_wav.f90 sound.o libportaudio.a c:\MinGW\lib\libwinmm.a 
