# POSSE GRID 

Scripts to perform POSSE MOS station point forecast gridding using ECMWF forecasts as background.

## Directory structure

The main directory contains `POSSE_profile.sh` which is sourced to set necessary environmental variables.

* `code/` Scripts to run gridding and processing input and output data.
* `code/Rlibs` R packages are installed here and environmental variable `POSSE_R_LIBS` should point here.
* `code/Rsrc` Source code for (some) of the needed R libraries.
* `data/` Contains symbolic liks to actual input and output directories.
* `data/EC` Background ECMWF forecast files.
* `data/stations` MOS POINT estimates for stations.
* `data/output` Output files are put here.

The current location for these in teho is `/lustre/apps/lapsrut/POSSE_GRID/`.

## Gridding by R code

The actual gridding (i.e. interpolation to a regular grid) of point station observations is done by R packages `fastgrid` and `MOSfieldutils`. Fastgrid is in github as https://www.github.com/mjlaine/fastgrid . The master R script is `code/MOStoECgrid_NC.R`.

## authors

Contact Erik (erik.gregow@fmi.fi) about the operational data flow and Marko (marko.laine@fmi.fi) about the R code.
