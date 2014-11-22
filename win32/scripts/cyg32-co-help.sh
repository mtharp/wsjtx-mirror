#!/bin/bash.exe

set -e
source /scripts/color-variables

clear
echo -e ${C_Y}"DOCUMENT CHECKOUT HELP"${C_NC}
echo ''
echo ' In order to build WSJT Documentation, you'
echo ' must first perform a checkout from'
echo ' WSJT @ SourceForge'
echo ''
echo -e ${C_C} "ANONYMOUS CHECKOUT"${C_NC}
echo ' -------------------'
echo ' svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/doc'
echo ''
echo -e ${C_C} "DEVELOPER CHECKOUT"${C_NC}
echo ' ------------------'
echo " svn co https://$USER@svn.code.sf.net/p/wsjt/wsjt/branches/doc"
echo ''
echo -e " Replace [ ${C_Y}$USER${C_NC} ] with your SorceForge User Name."
echo ''

exit 0