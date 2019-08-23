#!/bin/sh

# install R packages in Rsrc

# source ../POSSE_profile.sh

POSSE_R_LIBS="${1}"

if [ -z ${POSSE_R_LIBS} ]; then
    echo "please give POSSE_R_LIBS in command line"
    exit 1
fi

read -p "I will install new R packages to ${POSSE_R_LIBS}. Are you sure?  yes/no: "
if [ "$REPLY" != "yes" ]; then
   echo "OK, no it is"
   exit
fi
echo "Here we go"

# this has to be done in certain order
RLIBS=""

for f in ./Rsrc/*.tar.gz ; do
    echo R CMD INSTALL -l ${POSSE_R_LIBS} ${f}
done

