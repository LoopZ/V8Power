#!/bin/bash

IGNORE=';VVIEW;VREADKEY;VCHKBOX;'

function assemble () {

    [[ ! -d BIN ]] && mkdir -p BIN
    local n="${1##*/}"
    n="${n%.*}"
    echo -n ${n}
    if [[ "${IGNORE/${n}}" != "${IGNORE}" ]] ; then
        echo ', ignored'
        return 0
    fi
    local z=$(stat -f '%z' BIN/${n}.COM 2>/dev/null || echo 0)
    nasm -ISOURCE/ SOURCE/${n}.ASM -fbin -O9 -o BIN/${n}.COM || return $?
    [[ ! -e BIN/${n}.COM ]] && return 1
    local x=$(stat -f '%z' BIN/${n}.COM 2>/dev/null || echo 0)

    [[ ${z} -eq ${x} ]] && echo || echo ", ${z} --> ${x}"

    return 0

}

if [[ "${*}" == '' ]] ; then
    for i in SOURCE/*.ASM ; do
        assemble "${i}" || exit 1
    done
else
   while [[ "${*}" != '' ]] ; do
        assemble "${1}" || exit 1
        shift
    done
fi