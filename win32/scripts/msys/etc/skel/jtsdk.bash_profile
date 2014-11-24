# The copy in your home directory (~/.bash_profile) is yours, please
# feel free to customise it as you see fit, as JTSDK will not change
# it after initial setup.

# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "${HOME}/bin" ] ; then
  PATH="${HOME}/bin:${PATH}"
fi

