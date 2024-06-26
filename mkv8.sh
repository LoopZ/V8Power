#!/bin/bash

# IGNORE=';VVIEW;VREADKEY;VCHKBOX;'
IGNORE=';;'

if [[ "$(uname)" == "Darwin" ]] ; then
	DARWIN=yes
else
	unset DARWIN
fi
function filesize () {
	if [[ ${DARWIN} ]] ; then
		stat -f '%z' "${1}" 2>/dev/null || echo 0
	else
		stat --format '%s' "${1}" 2>/dev/null || echo 0
	fi
}

function assemble () {

    [[ ! -d BIN ]] && mkdir -p BIN
    local n="${1##*/}"
    n="${n%.*}"
    local o=$(echo ${n} | tr "[:lower:]" "[:upper:]" )

    if [[ "${IGNORE/${n}}" != "${IGNORE}" ]] ; then
        echo "${n}, ignored"
        return 0
    fi
    if [[ ! -f "BIN/${o}.COM" ]] ; then
	local z=$(filesize "../../BIN/${o}.COM")
    else
	local z=$(filesize "BIN/${o}.COM")
    fi
    nasm -ISOURCE/ SOURCE/${n}.ASM -fbin -O9 -o BIN/${o}.COM || {
        echo "error assembling ${n}.ASM"
        return 1
    }
    [[ ! -e BIN/${o}.COM ]] && {
        echo "missing BIN/${o}.COM"
        return 1
    }
    local x=$(filesize "BIN/${o}.COM")
    [[ ${z} -eq ${x} ]] || echo "${n}, ${z} --> ${x}, ${o}"

    return 0

}

if [[ "${*}" == '' ]] ; then
    for i in SOURCE/*.ASM ; do
    	[[ "${i}" == "SOURCE/DEMOPARS.ASM" ]] && continue
        assemble "${i}" || exit 1
    done
else
   while [[ "${*}" != '' ]] ; do
        assemble "${1}" || exit 1
        shift
    done
fi