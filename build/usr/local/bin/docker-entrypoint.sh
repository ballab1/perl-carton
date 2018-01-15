#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose


cd /scripts
if [ "$1" = 'perl' ]; then       # regular app start

    shift
    exec perl $@

elif [ "$1" = 'perl_debug' ]; then     # debugging line

    shift
    exec perl -d $@

else
    exec $@
fi
