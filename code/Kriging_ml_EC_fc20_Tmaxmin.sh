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

ENDDTG=`$MANDTG $DTG + 60`
LLINT=3
EGSTART=6
LL=$LLINT
EG=$EGSTART
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

# Here run the Temperature Kriging

(sleep 1; echo "Kriging_fc_3 Start: `date`"; cd ${An_time}/fc_3; ../../MOStoECgrid_NC.R; echo "Kriging_fc_3 Done: `date`") &
(sleep 1; echo "Kriging_fc_6 Start: `date`"; cd ${An_time}/fc_6; ../../MOStoECgrid_NC.R; echo "Kriging_fc_6 Done: `date`") &
(sleep 1; echo "Kriging_fc_9 Start: `date`"; cd ${An_time}/fc_9; ../../MOStoECgrid_NC.R; echo "Kriging_fc_9 Done: `date`") &
(sleep 1; echo "Kriging_fc_12 Start: `date`"; cd ${An_time}/fc_12; ../../MOStoECgrid_NC.R; echo "Kriging_fc_12 Done: `date`") &
(sleep 1; echo "Kriging_fc_15 Start: `date`"; cd ${An_time}/fc_15; ../../MOStoECgrid_NC.R; echo "Kriging_fc_15 Done: `date`") &
(sleep 1; echo "Kriging_fc_18 Start: `date`"; cd ${An_time}/fc_18; ../../MOStoECgrid_NC.R; echo "Kriging_fc_18 Done: `date`") &
(sleep 1; echo "Kriging_fc_21 Start: `date`"; cd ${An_time}/fc_21; ../../MOStoECgrid_NC.R; echo "Kriging_fc_21 Done: `date`") &
(sleep 1; echo "Kriging_fc_24 Start: `date`"; cd ${An_time}/fc_24; ../../MOStoECgrid_NC.R; echo "Kriging_fc_24 Done: `date`") &
(sleep 1; echo "Kriging_fc_27 Start: `date`"; cd ${An_time}/fc_27; ../../MOStoECgrid_NC.R; echo "Kriging_fc_27 Done: `date`") &
(sleep 1; echo "Kriging_fc_30 Start: `date`"; cd ${An_time}/fc_30; ../../MOStoECgrid_NC.R; echo "Kriging_fc_30 Done: `date`") &
(sleep 1; echo "Kriging_fc_33 Start: `date`"; cd ${An_time}/fc_33; ../../MOStoECgrid_NC.R; echo "Kriging_fc_33 Done: `date`") &
(sleep 1; echo "Kriging_fc_36 Start: `date`"; cd ${An_time}/fc_36; ../../MOStoECgrid_NC.R; echo "Kriging_fc_36 Done: `date`") &
(sleep 1; echo "Kriging_fc_39 Start: `date`"; cd ${An_time}/fc_39; ../../MOStoECgrid_NC.R; echo "Kriging_fc_39 Done: `date`") &
(sleep 1; echo "Kriging_fc_42 Start: `date`"; cd ${An_time}/fc_42; ../../MOStoECgrid_NC.R; echo "Kriging_fc_42 Done: `date`") &
(sleep 1; echo "Kriging_fc_45 Start: `date`"; cd ${An_time}/fc_45; ../../MOStoECgrid_NC.R; echo "Kriging_fc_45 Done: `date`") &
(sleep 1; echo "Kriging_fc_48 Start: `date`"; cd ${An_time}/fc_48; ../../MOStoECgrid_NC.R; echo "Kriging_fc_48 Done: `date`") &
(sleep 1; echo "Kriging_fc_51 Start: `date`"; cd ${An_time}/fc_51; ../../MOStoECgrid_NC.R; echo "Kriging_fc_51 Done: `date`") &
(sleep 1; echo "Kriging_fc_54 Start: `date`"; cd ${An_time}/fc_54; ../../MOStoECgrid_NC.R; echo "Kriging_fc_54 Done: `date`") &
(sleep 1; echo "Kriging_fc_57 Start: `date`"; cd ${An_time}/fc_57; ../../MOStoECgrid_NC.R; echo "Kriging_fc_57 Done: `date`") &
(sleep 1; echo "Kriging_fc_60 Start: `date`"; cd ${An_time}/fc_60; ../../MOStoECgrid_NC.R; echo "Kriging_fc_60 Done: `date`") &


wait





#################################################################################
#  DONE..................
#################################################################################


exit
