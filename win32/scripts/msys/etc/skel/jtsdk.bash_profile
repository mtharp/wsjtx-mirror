# This file is installed when you you first create and account
# by running C:\JTSDK\msys-env. Subsequent SVN updates "Will Not"
# Overwrite this file.

# SOURCE USER BASHRC FILE
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# USER ALIAS FILE
if [ -f "${HOME}/.bash_aliases" ]; then
  source "${HOME}/.bash_aliases"
fi

# SOURCE USER PRIVATE
if [ -d "${HOME}/bin" ] ; then
  PATH="${HOME}/bin:${PATH}"
fi