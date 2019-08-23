#!/bin/bash
# Profile for POSSE GRID processing
# Version 1.0 2019-08-19

#XC30 needed
. /opt/modules/3.2.6.7/init/sh

# variables for POSSE gridding
#export POSSE_VERSION="TEST"
#export POSSE_MAIN="/lustre/apps/lapsrut/POSSE_GRID/${POSSE_VERSION}"

export POSSE_MAIN="$(realpath "$(dirname "$BASH_SOURCE")")"

export POSSE_EC="${POSSE_MAIN}/data/EC"
export POSSE_STATIONS="${POSSE_MAIN}/data/stations"
export POSSE_OUTPUT="${POSSE_MAIN}/data/output"
export POSSE_CODE="${POSSE_MAIN}/code"
export POSSE_R_LIBS="${POSSE_CODE}/Rlibs"


#Load modules
module load gdal
module load proj
module load cray-netcdf
module load cray-hdf5
module load cray-R
module swap PrgEnv-cray/6.0.4 PrgEnv-gnu/6.0.4
module load cdo
module load eccodes

#Uncomment when installing fastgrid
export LD_LIBRARY_PATH="/opt/cray/pe/libsci/default/GNU/5.1/x86_64/lib":$LD_LIBRARY_PATH
export LIBRARY_PATH="/opt/cray/pe/libsci/default/GNU/5.1/x86_64/lib"

#And set this environement to find right "epsg": 
export PROJ_LIB=/opt/fmi/proj/4.9.3/share/proj/

# R libraries areinstalled here
export R_LIBS_USER="${POSSE_CODE}/Rlibs"


#NetCDF and Grib conversion libs
export ODSDIR=/data/users/lapsrut/Grib2NetCDF_XC30/grib2nc_ver1.2/ods
export GRIB_TABLES=/data/users/lapsrut/Grib2NetCDF_XC30/grib2nc_ver1.2/ods/base/Grib/grib_tables
export GRIB_TEMPLATES=/data/users/lapsrut/Grib2NetCDF_XC30/grib2nc_ver1.2/ods/base/Grib2/templates
export NCGEN=/opt/fmi/netcdf/4.3.0/bin/ncgen
export bin_dir=/data/users/lapsrut/GRIB_API_CRAY_ver1.9.9/grib_api_dir/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/fmi/netcdf/4.3.0/lib:/lustre/apps/lapsrut/Projects/POSSE/R/Erik/:/opt/fmi/udunits/2.1.9/lib/
