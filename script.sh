#!/usr/bin/env bash

#
# bash boilerplate.
#

##################################################
# General functions, initializing and etc..
# You probably should not edit this section.
##################################################
set -e

READLINK=$(type -p greadlink readlink | head -1)
if [ -z "$READLINK" ]; then
  echo "cannot find readlink - are you missing GNU coreutils?" >&2
  exit 1
fi

resolve_link() {
  $READLINK "$1"
}

# get absolute path.
abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [ -n "$path" ]; do
    # cd "${path%/*}" does not work in "$ bash script.sh"
    # cd "${path%/*}"
    dirname $path
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd -P
  cd "$cwd"
}

# inspired by https://github.com/heroku/heroku-buildpack-php
# Usage:
#   echo "message" | indent
indent() {
  # if an arg is given it's a flag indicating we shouldn't indent the first line, so use :+ to tell SED accordingly if that parameter is set, otherwise null string for no range selector prefix (it selects from line 2 onwards and then every 1st line, meaning all lines)
  local c="${1:+"2,999"} s/^/      /"
  case $(uname) in
    Darwin) sed -l "$c";; # mac/bsd sed: -l buffers on line boundaries
    *)      sed -u "$c";; # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
  esac
}

# inspired by http://stackoverflow.com/questions/3231804/in-bash-how-to-add-are-you-sure-y-n-to-any-command-or-alias
# Usage:
#   confirm "message"
confirm() {
    local response
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]:} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# Usage:
#   var=$(ask "message")
ask() {
    local response
    # call with a prompt string or use a default
    read -r -p "${1:->} " response
    echo $response
}

# write a horizontal line
# http://wiki.bash-hackers.org/snipplets/print_horizontal_line
# Usage:
#   hr
#   hr "="
#   hr "=" 10
hr() {
    printf '%*s\n' "${2:-$(tput cols)}" '' | tr ' ' "${1:--}"
}

# inspired by http://dharry.hatenablog.com/entry/20110122/1295681180
# Usage:
#   sleep 3 & progress
progress() {
  local _bar=$1; _bar=${_bar:=.}
  while :
  do
    jobs %1 > /dev/null 2>&1
    [ $? = 0 ] || break
    echo -n ${_bar}
    sleep 0.2
  done;
}

# Usage:
#   sleep 3 & loading
loading() {
  local _ptn=0
  while :
  do
    jobs %1 > /dev/null 2>&1
    [ $? = 0 ] || break
    if [ ${_ptn} -eq 0 ]; then
        _ptn=1
        echo -ne '-\r'
    elif [ ${_ptn} -eq 1 ]; then
        _ptn=2
        echo -ne '\\\r'
    elif [ ${_ptn} -eq 2 ]; then
        _ptn=3
        echo -ne '|\r'
    else
        _ptn=0
        echo -ne '/\r'
    fi
    sleep 0.1
  done;
}

# bold and color text utility
# https://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/
# http://stackoverflow.com/questions/2924697/how-does-one-output-bold-text-in-bash
# usage:
#   ${txtred}foobar${txtreset}
txtunderline=$(tput sgr 0 1)     # Underline
txtbold=$(tput bold)             # Bold

txtred=$(tput setaf 1)           # red
txtgreen=$(tput setaf 2)         # green
txtyellow=$(tput setaf 3)        # yellow
txtblue=$(tput setaf 4)          # blue
txtreset=$(tput sgr0)            # Reset

##################################################
# set useful variables
##################################################
script_dir="$(abs_dirname "$0")"
progname=$(basename $0)
progversion="0.1.0"

##################################################
# Actions.
##################################################
usage() {
    echo "Usage: $progname [OPTIONS] ${txtunderline}COMMAND${txtreset}"
    echo
    echo "Options:"
    echo "  -h, --help       show help."
    echo "  -v, --version    print the version."
    echo
    echo "Commands:"
    echo "  help   show help."
    echo "  hello  say helloworld!"
    echo
}

printversion() {
    echo "${progversion}"
}

do_hello() {
    echo "${txtyellow}helloworld!${txtreset}"
}

##################################################
# Main logic.
##################################################
cd $script_dir

# parse arguments and options.
# inspired by http://qiita.com/b4b4r07/items/dcd6be0bb9c9185475bb
declare -a params=()

for OPT in "$@"
do
    case "$OPT" in
        '-h'|'--help' )
            usage
            exit 0
            ;;
        '-v'|'--version' )
            printversion
            exit 0
            ;;
        '--'|'-' )
            shift 1
            params+=( "$@" )
            break
            ;;
        -*)
            echo "$progname: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                params+=( "$1" )
                shift 1
            fi
            ;;
    esac
done

sub_command=${params[0]}
case $sub_command in
    'help' )
        usage
        exit 0
        ;;
    'hello' )
        do_hello
        exit 0
        ;;
    '' )
        usage
        exit 0
        ;;
    *)
        echo "$progname: illegal command '$sub_command'" 1>&2
        exit 1
        ;;
esac
