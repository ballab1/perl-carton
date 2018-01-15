#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose

declare -r CONTAINER='PERL'

export TZ=America/New_York
declare -r TOOLS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  


# Alpine Packages
declare -r BUILDTIME_PKGS="build-base expat expat-dev file g++ gcc gcc-objc git gnutls-utils libc6-compat libtool make shadow tar"
declare -r CORE_PKGS="bash ca-certificates curl openssl sudo tzdata wget"
declare -r PERL_PKGS="perl perl-utils"


# global exceptions
declare -i dying=0
declare -i pipe_error=0


#----------------------------------------------------------------------------
# Exit on any error
function catch_error() {
    echo "ERROR: an unknown error occurred at $BASH_SOURCE:$BASH_LINENO" >&2
}

#----------------------------------------------------------------------------
# Detect when build is aborted
function catch_int() {
    die "${BASH_SOURCE[0]} has been aborted with SIGINT (Ctrl-C)"
}

#----------------------------------------------------------------------------
function catch_pipe() {
    pipe_error+=1
    [[ $pipe_error -eq 1 ]] || return 0
    [[ $dying -eq 0 ]] || return 0
    die "${BASH_SOURCE[0]} has been aborted with SIGPIPE (broken pipe)"
}

#----------------------------------------------------------------------------
function die() {
    local status=$?
    [[ $status -ne 0 ]] || status=255
    dying+=1

    printf "%s\n" "FATAL ERROR" "$@" >&2
    exit $status
}  

#############################################################################
function cleanup()
{
    printf "\nclean up\n"
    apk del .buildDepedencies 
}

#############################################################################
function header()
{
    local -r bars='+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
    printf "\n\n\e[1;34m%s\nBuilding container: \e[0m%s\e[1;34m\n%s\e[0m\n" $bars $CONTAINER $bars
}
 
#############################################################################
function install_CUSTOMIZATIONS()
{
    printf "\nAdd configuration and customizations\n"

    declare -a DIRECTORYLIST="/etc /usr /opt /var"
    for dir in ${DIRECTORYLIST}; do
        [[ -d "${TOOLS}/${dir}" ]] && cp -r "${TOOLS}/${dir}/"* "${dir}/"
    done

    ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh
}

#############################################################################
function install_PERL()
{
    local -r file="PERL"

    printf "\nprepare and install %s\n" "${file}"

}

#############################################################################
function installAlpinePackages()
{
    apk update
    apk add --no-cache $CORE_PKGS $PERL_PKGS
    apk add --no-cache --virtual .buildDepedencies $BUILDTIME_PKGS
}

#############################################################################
function installTimezone()
{
    echo "$TZ" > /etc/TZ
    cp /usr/share/zoneinfo/$TZ /etc/timezone
    cp /usr/share/zoneinfo/$TZ /etc/localtime
}

#############################################################################
function setPermissions()
{
    printf "\nmake sure that ownership & permissions are correct\n"

    chmod u+rwx /usr/local/bin/docker-entrypoint.sh

    declare -a DIRECTORYLIST="/usr/local/bin /usr/bin"
    for dir in ${DIRECTORYLIST}; do
        mkdir -p ${dir} && chmod -R 777 ${dir}
    done
}

#############################################################################

trap catch_error ERR
trap catch_int INT
trap catch_pipe PIPE 

set -o verbose

header
installAlpinePackages
installTimezone
install_PERL
install_CUSTOMIZATIONS
setPermissions
cleanup
exit 0
