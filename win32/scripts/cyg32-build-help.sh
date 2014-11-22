#!/bin/bash.exe

set -e

# Source Color Variables
source /scripts/color-variables

clear
echo -e ${C_Y}"WSJT BUILD HELP MENU\n"${C_NC}
echo 'USAGE: [ build-doc.sh] [ option ]'
echo ''
echo 'OPTION(s): All map65 simjt wsjt wsjtx'
echo '           wspr wsprx wfmt devg qref help clean'
echo ''
echo -e ${C_C} "BUILD LINKED"${C_NC}
echo '  All .....: ./build-doc.sh all'
echo '  WSJT-X...: ./build-doc.sh wsjtx'
echo
echo -e ${C_C} "BUILD DATA-URI - (Stand Alone)"${C_NC}
echo '  All .....: ./build-doc.sh dall'
echo '  WSJT-X...: ./build-doc.sh dwsjtx'
echo
echo -e ${C_C} "CLEAN FOLDERS & FILES"${C_NC}
echo '  All .....: ./build-doc.sh clean'
echo ''
echo -e ${C_C} "NOTE(s)"${C_NC}
echo '  The same method is used for all documentaion.'
echo '  The prefix "d" designates data-uri or a stand'
echo '  alone version of the document.'
echo ''

exit 0
