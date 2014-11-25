# This file is installed when you first create and account
# by running C:\JTSDK\cyg32-env. Subsequent SVN updates "Will Not"
# Overwrite this file.

# SET LANG
export LANG=$(locale -uU)

# Source bashrc file
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# SET LOCAL USER BINPATH
if [ -d "${HOME}/bin" ] ; then
  PATH="${HOME}/bin:${PATH}"
fi

# SET LOCAL USER MANPATH
if [ -d "${HOME}/man" ]; then
	MANPATH="${HOME}/man:${MANPATH}"
fi

# SET LOCAL USER INFOPATH
if [ -d "${HOME}/info" ]; then
	INFOPATH="${HOME}/info:${INFOPATH}"
fi

# SOURCE MSYS-ENV FUNCTIONS FILE
if [ -f "${HOME}/.bash_functions" ]; then
	source "${HOME}/.bash_functions"
fi

# SOURCE USER ALIAS FILE
if [ -f "${HOME}/.bash_aliases" ]; then
  source "${HOME}/.bash_aliases"
fi

# MSYS-ENV ALIAS FILE
if [ -f /scripts/cyg32-doc-alias.txt ]; then
  source /scripts/cyg32-doc-alias.txt
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