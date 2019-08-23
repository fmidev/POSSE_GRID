#!/bin/sh

MANDTG=${POSSE_CODE}/mandtg

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

ENDDTG=`$MANDTG $DTG + 240`
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
cd ${POSSE_CODE}/${An_time}/fc_${LL}
# Be sure this right dir
rm -rf ${POSSE_CODE}/${An_time}/fc_${LL}/*.*


#Copy right files to right dirs.....

#Copy  CSV-files
echo "Copying:  ${POSSE_STATIONS}/${This_step}   to  ${POSSE_CODE}/${An_time}/fc_${LL}/This_timestep.csv "
# Do QC on input CSV-files..........
SizeCSV=`du -b ${POSSE_STATIONS}/${This_step} | awk '{print $1}'`
if [ $SizeCSV -gt 100000 ]
then
cp ${POSSE_STATIONS}/${This_step} ${POSSE_CODE}/${An_time}/fc_${LL}/This_timestep.csv
else 
echo "WARNING input CSV-file is bad sized!!!  ${This_step}  "
#echo $HH | mail -s "Kriging Dev ::::: CSV-FILE SIZE PROBLEM =  ${This_step}   ::::" erik.gregow@fmi.fi
fi


#Copy background ECMWF netcdf files
echo "Copying:  ${POSSE_EC}/../netcdf_test/${This_step_ECbg}   to  ${POSSE_CODE}/${An_time}/fc_${LL}/This_timestep_ECbg.nc "
# Do QC on input EC-files
SizeEC=`du -b ${POSSE_EC}/../netcdf_test/${This_step_ECbg} | awk '{print $1}'`
if [ $SizeEC -gt 5000000 ]
then
cp ${POSSE_EC}/../netcdf_test/${This_step_ECbg} ${POSSE_CODE}/${An_time}/fc_${LL}/This_timestep_ECbg.nc
else 
echo "WARNING input EC-file is bad sized!!!  ${This_step_ECbg}  "
#echo $HH | mail -s "Kriging Dev ::::: EC-FILE SIZE PROBLEM =  ${This_step_ECbg}   ::::" erik.gregow@fmi.fi
fi



####################################################################
#  RUN KRIGING AND REPROJECTION....
####################################################################


cd ${POSSE_CODE}/

# Here run the Temperature Kriging

  (sleep 1; echo "Kriging_${An_time}/fc_${LL} Start: `date`"; cd ${An_time}/fc_${LL}; ../../MOStoECgrid_NC.R; echo "Kriging_${An_time}/fc_${LL} Done: `date`") &


# After 144 hours steprange change to 6h interval
if [ "$LL" -lt "144" ]
then
 LLINT=3
else
 LLINT=6
fi


 DTG=`$MANDTG $DTG + $LLINT`
 LL=`expr $LL + $LLINT`
 EG=`expr $EG + $LLINT`
 TT=`expr $TT + 1`


done


wait



#################################################################################
#  DONE..................
#################################################################################


exit
