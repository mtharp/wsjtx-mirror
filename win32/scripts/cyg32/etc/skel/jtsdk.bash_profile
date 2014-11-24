# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# Source JTSDK-DOC Bash Alias files if exist
# Some people use a different file for aliases
if [ -f "${HOME}/.bash_aliases" ]; then
  source "${HOME}/.bash_aliases"
fi

# Source bashrc file
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# Document Alias File
if [ -f /scripts/cyg32-doc-alias.txt ]; then
  source /scripts/cyg32-doc-alias.txt
fi

# Reserved for later use in JTSDK
if [ -d "${HOME}/bin" ] ; then
  PATH="${HOME}/bin:${PATH}"
fi

# Reserved for later use in JTSDK
if [ -d "${HOME}/man" ]; then
	MANPATH="${HOME}/man:${MANPATH}"
fi

# Reserved for later use in JTSDK
if [ -d "${HOME}/info" ]; then
	INFOPATH="${HOME}/info:${INFOPATH}"
fi

# Reserved for later use in JTSDK
if [ -f "${HOME}/.bash_functions" ]; then
	source "${HOME}/.bash_functions"
fi

# Display JTSDK header
if [ -f "$HOME/.initial-setup" ]
then 
	rm -f "$HOME/.initial-setup"
else
	/scripts/cyg32-header.sh
fi

# Setup the prompt
export PS1='\[\033]0;JTSDK Documentation Development Environment\007\033[32m\]\u@\h\[\033[33m\w\033[0m\]$ '