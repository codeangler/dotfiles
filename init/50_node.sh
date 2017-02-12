# Full installation only
[ "$(get_install_type)" -lt "1" ] && return 1

# Load nave- and npm-related functions.
source $DOTFILES/source/50_node.sh

# Set a specific version of node as the "default" for "nave use default"
function nave_default() {
  local version
  local default=${NAVE_DIR:-$HOME/.nave}/installed/default
  [[ ! "$1" ]] && echo "Specify a node version or \"stable\"" && return 1
  [[ "$1" == "stable" ]] && version=$(nave stable) || version=${1#v}
  rm "$default" 2>/dev/null
  ln -s $version "$default"
  echo "Nave default set to $version"
}

# Install a version of node, set as default, install npm modules, etc.
function nave_install() {
  local version
  [[ ! "$1" ]] && echo "Specify a node version or \"stable\"" && return 1
  [[ "$1" == "stable" ]] && version=$(nave stable) || version=${1#v}
  if [[ ! -d "${NAVE_DIR:-$HOME/.nave}/installed/$version" ]]; then
    e_header "Installing Node.js $version"
    nave install $version
  fi
  [[ "$1" == "stable" ]] && nave_default stable && npm_install
}

# Update npm and install global modules.
function npm_install() {
  local installed modules
  e_header "Updating npm"
  npm update -g npm
  { pushd "$(npm config get prefix)/lib/node_modules"; installed=(*); popd; } >/dev/null
  modules=($(setdiff "${npm_globals[*]}" "${installed[*]}"))
  if (( ${#modules[@]} > 0 )); then
    e_header "Installing Npm modules: ${modules[*]}"
    npm install -g "${modules[@]}"
  fi
}

l0=()

l1=(
  babel-cli
  bower
  grunt-cli
  grunt-init
  linken
  node-inspector
  phantomjs-prebuilt
  pushstate-server
  serverless
  yo
)

# Compile array of packages to install based on installation level
for i in $(seq "$(get_install_type)" -1 0); do
  eval arr=("\${"l"$i[@]}")
  npm_global=("${npm_global[@]}" "${arr[@]}")
done

# Install latest stable Node.js, set as default, install global npm modules.
nave_install stable
