#!/bin/sh

PRERELEASE='.pre'

RELEASE=0
FORMAT='zip'
PROJECT=$(echo ${PWD##*/})
# VERSION=$(date +'%Y-%m-%d')
VERSION=$(date +'%y.%m.%d')


[[ -d "${HOME}/Downloads/${PROJECT}" ]] && rm -rf "${HOME}/Downloads/${PROJECT}"

mkdir -p "${HOME}/Downloads/${PROJECT}"
cp -r BIN/* "${HOME}/Downloads/${PROJECT}/"
mkdir -p "${HOME}/Downloads/${PROJECT}/DEMOS"
cp -r DEMOS/* "${HOME}/Downloads/${PROJECT}/DEMOS/"
mkdir -p "${HOME}/Downloads/${PROJECT}/EXAMPLES"
cp -r EXAMPLES/* "${HOME}/Downloads/${PROJECT}/EXAMPLES/"

ARCHIVE="${PROJECT}-${VERSION}-${RELEASE}${PRERELEASE}.${FORMAT}"
while [[ -f "${HOME}/Downloads/${ARCHIVE}" ]] ; do
	(( RELEASE++ ))
	ARCHIVE="${PROJECT}-${VERSION}-${RELEASE}${PRERELEASE}.${FORMAT}"
done

if [[ -f 'README.txt' ]] ; then
	cp 'README.txt' "${HOME}/Downloads/${PROJECT}-README.txt"
fi;

CURDIR="$PWD"
cd "${HOME}/Downloads"
if [[ "$FORMAT" == "zip" ]] ; then
	zip -9 -r "${ARCHIVE}" "${PROJECT}/"*
fi;
cd "${CURDIR}"

rm -rf "${HOME}/Downloads/${PROJECT}"

echo
echo "${HOME}/Downloads/${ARCHIVE}"
echo

