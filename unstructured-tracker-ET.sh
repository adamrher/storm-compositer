#!/bin/bash -l

TEMPESTEXTREMESDIR=/glade/u/home/aherring/tempestextremes-v1.1

UQSTR="ARCTICGRIS"
CASE=cam6_2_022.se_FHIST_ne0np4.ARCTICGRIS.ne30x8_mt12_7680pes_200510_mg3-Nx1yrs

TOPOFILE=/glade/p/cesmdata/cseg/inputdata/atm/cam/topo/se/ne30x8_ARCTICGRIS_nc3000_Co060_Fi001_MulG_PF_RR_Nsw042_c200428.nc
#TOPOFILE=/glade/p/cesmdata/cseg/inputdata/atm/cam/topo/se/ne30x4_ARCTIC_nc3000_Co060_Fi001_MulG_PF_RR_Nsw042_c200428.nc
#TOPOFILE=/glade/p/cesmdata/cseg/inputdata/atm/cam/topo/se/ne30pg3_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171014.nc
#TOPOFILE=/glade/p/cesmdata/cseg/inputdata/atm/cam/topo/se/ne30pg2_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171014.nc

#FILESDIR=/glade/campaign/cgd/amp/aherring/archive/${CASE}/atm/hist
FILESDIR=/glade/scratch/aherring/archive/${CASE}/atm/hist

CONNECTFLAG="--in_connect /glade/work/aherring/CESM2/ASP/arctic/tempestextremes/connectdats/connect_${UQSTR}.dat"
#CONNECTFLAG="--in_connect /glade/work/aherring/CESM2/ASP/arctic/tempestextremes/connectdats/connect_ne30pg3.dat"

### ### ### ### ### ### ### ###

FILELISTNAME=filelist.txt
rm -f $FILELISTNAME
touch $FILELISTNAME

for FILE in ${FILESDIR}/${CASE}.cam.h3.*; do    
  echo "${FILE};${TOPOFILE}" >> $FILELISTNAME
done

### ### ### ### ### ### ### ###
### END USER DEFINE SECTION ###
### ### ### ### ### ### ### ###

STR_DETECT="--verbosity 0 --timestride 1 ${CONNECTFLAG} --out cyclones_tempest.${UQSTR} --closedcontourcmd PSL,100.0,6.0,0 --mergedist 8.0 --searchbymin PSL --outputcmd PSL,min,0;_VECMAG(UBOT,VBOT),max,2;PHIS,max,0 --minlat 45.0 --maxlat 90.0"

${TEMPESTEXTREMESDIR}/bin/DetectNodes --in_data_list "${FILELISTNAME}" ${STR_DETECT} 


rm -f cyclones_list.${UQSTR}
cat cyclones_tempest.${DATESTRING}* >> cyclones_list.${UQSTR}
rm cyclones_tempest.${DATESTRING}*

### ### ### ### ### ### ### ###

#STR_STITCH="--format ncol,lon,lat,slp,wind,phis --range 8.0 --minlength 5 --maxgap 0 --min_endpoint_dist 10.0 --threshold wind,>=,10.0,6.;lat,>,25,3;lon,>,270,3;lat,<,90,3;lon,<,360,3"

STR_STITCH="--format ncol,lon,lat,slp,wind,phis --range 8.0 --minlength 5 --maxgap 0 --min_endpoint_dist 10.0 --threshold wind,>=,10.0,6."

echo "Executing StitchNodes..."
${TEMPESTEXTREMESDIR}/bin/StitchNodes ${STR_STITCH} --in cyclones_list.${UQSTR} --out trajectories.ge.45N.txt.${UQSTR}

rm log*
rm cyclones_list.${UQSTR}

exit
