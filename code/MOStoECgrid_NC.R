#!/usr/bin/env Rscript
# grid MOS point stations values to EC background grid
# reads netcdf file and writes grib file
# default variables c('temperature','minimumtemperature','maximumtemperature')

# usage: script MOSstations.csv ECfg.nc variable1 variable2

# marko.laine@fmi.fi

a<-commandArgs(TRUE)
if (length(a)>1) {
  MOSfile <- a[[1]] # MOS stations file name
  ECfile <- a[[2]]  # EC forecast file
} else {
  MOSfile  <- 'This_timestep.csv'
  ECfile   <- 'This_timestep_ECbg.nc'
# stop('give MOS and EC nc file names in the command line')
}

outputdir <- '.'
outputfile <- 'MOSgrid'
failfile <- paste0(outputdir,'/','GRIDFAILED')

# maybe not needed here
if (file.exists(failfile)) file.remove(failfile) 

# rest of the command line are variable names
if (length(a)>2) {
  variables <- a[3:length(a)]
} else {
  # default variable names:
#  variables <- c('temperature','minimumtemperature','maximumtemperature')
  variables <- c('temperature','minimumtemperature','maximumtemperature','dewpoint')
}
nvars <- length(variables)

gridding_failed <- FALSE

# teho library locations
.libPaths(Sys.getenv("POSSE_R_LIBS"))
#.libPaths("/lustre/apps/lapsrut/POSSE_GRID/v1.0.0/code/Rlibs")

# needs a lot of packages, partial list here
# install.packages(c('sp','ncdf4','spatstat','spatstat.utils','spatstat.data','polyclip'),
#  lib=Sys.Getenv("POSSE_R_LIBS"))


# load the packeges needed
library('fastgrid')
library('MOSfieldutils')
library('geogrid')
library('Rgrib2')
library('methods') # needed for command line call at some environments

# grib names
gnames <- MOSget('varnames')[variables,'gribname']
if (any(is.na(gnames))) {
  stop('do not know the grib names of the variables')
}

# netcdf names
ncnames <- MOSget('varnames')[variables,'ncname']
tocelsius <- gnames %in% MOSget('gribtemperatures')

# read the variables from NC file,
# convert to Celsius, and create SpatialGrid with correct MOS names
# names are defined in MOS.options$varnames
# extra = TRUE means that we load LSM and geopotential too
ECfc <- ECMWF_bg_load(file = ECfile,variables = ncnames, varnames = variables, tocelsius = tocelsius, extra=TRUE)

# read station MOS data and add distance to sea for LSM calculation
stations <- MOSstation_csv_load(file=MOSfile,skipmiss = FALSE)
if (is.null(stations$distance)) {
  stations <- MOS_stations_add_dist(indata = stations)
}

# grid the data to the background EC grid
# loop over variable names
for (ivar in 1:nvars) {
  
  # gridding options PLEASE CHECK THESE!
  if (variables[ivar] == "temperature") {
    MOSset('cov.pars',c(2.5^2, 1.0 , 0.0)) # sigmasq, clen, nugget 
    MOSset('altlen',150) # altitude correlation range (m)
  }
  else if (variables[ivar] == "dewpoint") {
    MOSset('cov.pars',c(2.5^2, 1.0 , 0.0)) # sigmasq, clen, nugget 
    MOSset('altlen',150) # altitude correlation range (m)
  } else { # minimum and maximum temperature
    MOSset('cov.pars',c(2.5^2, 1.0 , 0.0)) # sigmasq, clen, nugget 
    MOSset('altlen',150) # altitude correlation range (m)
  }

  # complete cases only, check the number of cases
  stations2 <- stations[complete.cases(stations@data[,variables[ivar]]),]
  nobs <- dim(stations2)[1]
  # if there is less that 2 stations with data, then just return the EC field
  if (nobs < 2) {
    out2 <- ECfc[variables[ivar]]
    attr(out2,paste0(variables[ivar],'_failed')) <- 2
    attr(out2,paste0(variables[ivar],'_nobs')) <- nobs
    gridding_failed <- TRUE
  }  else {
    out2 <- MOSgrid(stations = stations2, bgfield = ECfc, variable = variables[ivar], fitpars=FALSE)
  }
  
  if (ivar == 1) {
    out <- out2
  } else {
    out@data[,variables[ivar]] <- out2@data[,variables[ivar]]
  }
}
# copy the date attributes (not available in the NC file)
#attr(out,'dataDate') <- attr(ECfc,'dataDate')
#attr(out,'dataTime') <- attr(ECfc,'dataTime')

# add geopotential to the output (should not break even if there is no such variable in the input)
out$geopotential <- ECfc$geopotential
variables <- c(variables,'geopotential')
gnames <- c(gnames,'z')

# save output in R format
rsavefile <- paste0(outputdir,'/',outputfile,'.rds')
saveRDS(out,rsavefile)

# save to GRIB file, convert to Kelvin
gsavefile <- paste0(outputdir,'/',outputfile,'.grib')
sptogrib(out,gsavefile,variables=variables,varnames=gnames,tokelvin=TRUE)

# if there is any problems, write info to a file (NEEDS SOME WORK STILL)
# now writes *_nobs attributes of the output
if (gridding_failed) {
  l<-paste0(variables,'_nobs')
  writeLines(text = paste(l,lapply(l,function(x)attr(out,x))),con=failfile)
}

# plot to file
#psavefile <- paste0(outputdir,'/',outputfile,'.png')
#MOSplotting::MOS_plot_field(out,layer = 1, zoom=MOS.options$finland.zoom,pngfile = psavefile)
