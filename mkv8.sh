#!/bin/bash

IGNORE=';VVIEW;VREADKEY;VCHKBOX;'

function assemble () {

    [[ ! -d BIN ]] && mkdir -p BIN
    local n="${1##*/}"
    n="${n%.*}"
    local o=$(echo ${n} | tr "[:lower:]" "[:upper:]" )

    if [[ "${IGNORE/${n}}" != "${IGNORE}" ]] ; then
        echo "${n}, ignored"
        return 0
    fi
    local z=$(stat -f '%z' BIN/${o}.COM 2>/dev/null || echo 0)
    nasm -ISOURCE/ SOURCE/${n}.ASM -fbin -O9 -o BIN/${o}.COM || {
        echo "error assembling ${n}.ASM"
        return 1
    }
    [[ ! -e BIN/${o}.COM ]] && {
        echo "missing BIN/${o}.COM"
        return 1
    }
    local x=$(stat -f '%z' BIN/${o}.COM 2>/dev/null || echo 0)
    [[ ${z} -eq ${x} ]] || echo "${n}, ${z} --> ${x}, ${o}"

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