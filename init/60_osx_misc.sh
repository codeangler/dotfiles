# OSX-only stuff. Abort if not OSX.
is_osx || return 1

if [[ "$(type -P pip)" ]]; then
  pip install --user powerline-status
  pip install psutil
fi