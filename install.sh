#!/bin/sh
# Install script for a new POSSE_GRID version
# copies current directory to $POSSE_INSTALL/$POSSE_VERSION

# POSSE_INSTALL="/tmp"

POSSE_INSTALL="/lustre/apps/lapsrut/POSSE_GRID"

POSSE_VERSION="${1}"

POSSE_INSTALL_DIR="${POSSE_INSTALL}/${POSSE_VERSION}/"

if [ ! -d ${POSSE_INSTALL} ]; then
    echo "POSSE install directory does not exit"
    exit 1
fi


if [ -z ${POSSE_VERSION} ]; then
    echo "please give POSSE_VERSION in command line"
    exit 1
fi

if [ -d ${POSSE_INSTALL_DIR} -o -f ${POSSE_INSTALL_DIR} ]; then
    echo "posse install dir should not exit"
    echo "Delete ${POSSE_INSTALL_DIR} first"
    exit 1
fi

echo creating "${POSSE_INSTALL_DIR}"
mkdir "${POSSE_INSTALL_DIR}"

echo "copying files to ${POSSE_INSTALL_DIR}"
echo rsync -avn --exclude install.sh --exclude .git  . "${POSSE_INSTALL_DIR}"

