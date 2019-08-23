#!/bin/sh

# install R packages in Rsrc
# does not work correctly yet, so has to be done by hand

# partial list of the packeges
# install.packages(c('sp','ncdf4','spatstat','spatstat.utils','spatstat.data','polyclip'),
#  lib=Sys.getenv("POSSE_R_LIBS"))

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

RLIBS="geogrid_3.5.2.tar.gz  Rgrib2_1.2.8_ml.tar.gz fastgrid_0.9.10.tar.gz  MOSfieldutils_0.4.0.tar.gz"

for f in $RLIBS ; do
    echo R CMD INSTALL -l ${POSSE_R_LIBS} ./Rsrc/${f}
done

