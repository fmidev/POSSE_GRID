#!/bin/sh

MANDTG=/lustre/apps/lapsrut/Projects/POSSE/R/Code/Oper/mandtg

TT=1
DTG=$1
Start_HH=$2 
An_time=$3

####################################################################
#  COPYING FILES TO RIGHT DIRS....
####################################################################


#Set the date for the ECMWF background files
YEAR_EC=`$MANDTG -year $DTG`
MONTH_EC=`$MANDTG -month $DTG`
DAY_EC=`$MANDTG -day $DTG`
Prep_Jul=${YEAR_EC}${MONTH_EC}${DAY_EC}
Ar_JulDat=`date -d ${Prep_Jul} +%y%j`


#Here set the amount of time-steps for the loop...

#Set new ENDDTG
#ENDDTG=`$MANDTG $DTG + 60`
#ENDDTG=`$MANDTG $DTG + 120`
# After 144h use every 6th interval. Run out to 7 days, i.e. 168h
#ENDDTG=`$MANDTG $DTG + 168`
ENDDTG=`$MANDTG $DTG + 240`

LLINT=6
EGSTART=6

#NOTE: Set new starting LL
#LL=$LLINT
#LL=`expr $LLINT + 144`
LL=`expr $LLINT + 168`

EG=$EGSTART

#Set new DTG start
#DTG=`$MANDTG $DTG + $LLINT`
#DTG=`$MANDTG $DTG + 60`
#DTG=`$MANDTG $DTG + 144`
DTG=`$MANDTG $DTG + 168`
DTG=`$MANDTG $DTG + $LLINT`

while [ $DTG -le $ENDDTG ] ; do 

 YEAR=`$MANDTG -year $DTG`
 MONTH=`$MANDTG -month $DTG`
 DAY=`$MANDTG -day $DTG`
 HOUR=`$MANDTG -hour $DTG`
 FCLENGTH=${MONTH}${DAY}${HOUR}


if [ "$MONTH" = "01" ]
then
 MONTH_L=Jan
fi
if [ "$MONTH" = "02" ]
then
 MONTH_L=Feb
fi
if [ "$MONTH" = "03" ]
then
 MONTH_L=Mar
fi
if [ "$MONTH" = "04" ]
then
 MONTH_L=Apr
fi
if [ "$MONTH" = "05" ]
then
 MONTH_L=May
fi
if [ "$MONTH" = "06" ]
then
 MONTH_L=Jun
fi
if [ "$MONTH" = "07" ]
then
 MONTH_L=Jul
fi
if [ "$MONTH" = "08" ]
then
 MONTH_L=Aug
fi
if [ "$MONTH" = "09" ]
then
 MONTH_L=Sep
fi
if [ "$MONTH" = "10" ]
then
 MONTH_L=Oct
fi
if [ "$MONTH" = "11" ]
then
 MONTH_L=Nov
fi
if [ "$MONTH" = "12" ]
then
 MONTH_L=Dec
fi

echo ${MONTH_L}


 START_DATE=${Start_HH}
 This_step=MOS_${START_DATE}_${LL}_${YEAR}${MONTH}${DAY}${HOUR}.csv


#Get the right amount of zeros for the NetCDF files
if [ ${LL} -le 9 ];then
 ZEROS='00000'
fi
if [ ${LL} -gt 9 -a ${LL} -le 99 ];then
 ZEROS='0000'
fi
if [ ${LL} -gt 99 ];then
 ZEROS='000'
fi

 JULIAN_DAY=${Ar_JulDat}${An_time}${ZEROS}
 This_step_ECbg=${JULIAN_DAY}${LL}

echo ${START_DATE}
echo ${This_step}
echo ${LL}
echo ${JULIAN_DAY}
echo ${This_step_ECbg}

#Clean away old files
cd /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/
#rm -rf /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/*.txt
rm -rf /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/*.csv
rm -rf /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/*.nc
#rm -rf /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/*.Rout
rm -rf /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/*.rds
rm -rf /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/*.grib

#Copy right files to right dirs.....

#Copy  CSV-files
echo "Copying:  /lustre/tmp/lapsrut/Projects/POSSE/Station_data/Run_Tmaxmin_dev/${This_step}   to  /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/This_timestep.csv "
# Do QC on input CSV-files..........
SizeCSV=`du -b /lustre/tmp/lapsrut/Projects/POSSE/Station_data/Run_Tmaxmin_dev/${This_step} | awk '{print $1}'`
if [ $SizeCSV -gt 100000 ]
then
cp /lustre/tmp/lapsrut/Projects/POSSE/Station_data/Run_Tmaxmin_dev/${This_step} /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/This_timestep.csv
else 
echo "WARNING input CSV-file is bad sized!!!  ${This_step}  "
#echo $HH | mail -s "Kriging Dev ::::: CSV-FILE SIZE PROBLEM =  ${This_step}   ::::" erik.gregow@fmi.fi
fi


#Copy background ECMWF netcdf files
echo "Copying:  /lustre/tmp/lapsrut/Background_model/Dissemination/Europe/netcdf_kriging_Tmaxmin/${This_step_ECbg}   to  /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/This_timestep_ECbg.nc "
# Do QC on input EC-files
SizeEC=`du -b /lustre/tmp/lapsrut/Background_model/Dissemination/Europe/netcdf_kriging_Tmaxmin/${This_step_ECbg} | awk '{print $1}'`
if [ $SizeEC -gt 5000000 ]
then
cp /lustre/tmp/lapsrut/Background_model/Dissemination/Europe/netcdf_kriging_Tmaxmin/${This_step_ECbg} /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/${An_time}/fc_${LL}/This_timestep_ECbg.nc
else 
echo "WARNING input EC-file is bad sized!!!  ${This_step_ECbg}  "
#echo $HH | mail -s "Kriging Dev ::::: EC-FILE SIZE PROBLEM =  ${This_step_ECbg}   ::::" erik.gregow@fmi.fi
fi



 DTG=`$MANDTG $DTG + $LLINT`
 LL=`expr $LL + $LLINT`
 EG=`expr $EG + $LLINT`
 TT=`expr $TT + 1`


done




####################################################################
#  RUN KRIGING AND REPROJECTION....
####################################################################


cd /lustre/apps/lapsrut/Projects/POSSE/R/Code/Fast_Oper_ML/Kriging_EC_Tmaxmin/

(sleep 1; echo "Kriging_fc_174 Start: `date`"; cd ${An_time}/fc_174; ../../MOStoECgrid_NC.R; echo "Kriging_fc_174 Done: `date`") &
(sleep 1; echo "Kriging_fc_180 Start: `date`"; cd ${An_time}/fc_180; ../../MOStoECgrid_NC.R; echo "Kriging_fc_180 Done: `date`") &
(sleep 1; echo "Kriging_fc_186 Start: `date`"; cd ${An_time}/fc_186; ../../MOStoECgrid_NC.R; echo "Kriging_fc_186 Done: `date`") &
(sleep 1; echo "Kriging_fc_192 Start: `date`"; cd ${An_time}/fc_192; ../../MOStoECgrid_NC.R; echo "Kriging_fc_192 Done: `date`") &
(sleep 1; echo "Kriging_fc_198 Start: `date`"; cd ${An_time}/fc_198; ../../MOStoECgrid_NC.R; echo "Kriging_fc_198 Done: `date`") &
(sleep 1; echo "Kriging_fc_204 Start: `date`"; cd ${An_time}/fc_204; ../../MOStoECgrid_NC.R; echo "Kriging_fc_204 Done: `date`") &
(sleep 1; echo "Kriging_fc_210 Start: `date`"; cd ${An_time}/fc_210; ../../MOStoECgrid_NC.R; echo "Kriging_fc_210 Done: `date`") &
(sleep 1; echo "Kriging_fc_216 Start: `date`"; cd ${An_time}/fc_216; ../../MOStoECgrid_NC.R; echo "Kriging_fc_216 Done: `date`") &
(sleep 1; echo "Kriging_fc_222 Start: `date`"; cd ${An_time}/fc_222; ../../MOStoECgrid_NC.R; echo "Kriging_fc_222 Done: `date`") &
(sleep 1; echo "Kriging_fc_228 Start: `date`"; cd ${An_time}/fc_228; ../../MOStoECgrid_NC.R; echo "Kriging_fc_228 Done: `date`") &
(sleep 1; echo "Kriging_fc_234 Start: `date`"; cd ${An_time}/fc_234; ../../MOStoECgrid_NC.R; echo "Kriging_fc_234 Done: `date`") &
#Timestep +240h has an exception, only do the Temperature, exclude Tmax and Tmin
#(sleep 1; echo "Kriging_fc_240 Start: `date`"; cd ${An_time}/fc_240; ../../MOStoECgrid_NC.R; echo "Kriging_fc_240 Done: `date`") &
(sleep 1; echo "Kriging_fc_240 Start: `date`"; cd ${An_time}/fc_240; ../../MOStoECgrid_NC.R; echo "Kriging_fc_240 Done: `date`") &

wait





#################################################################################
#  DONE..................
#################################################################################


exit
