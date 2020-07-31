#!/bin/bash -l

TEMPESTEXTREMESDIR=/glade/u/home/aherring/tempestextremes-v1.1

UQSTR="f09"
CASE=cam6_2_022.se_FHIST_f09_f09_mg17_1800pes_200507_mg3-Nx5yrs

TOPOFILE=/glade/work/aherring/grids/uniform-res/f09/topo/fv_0.9x1.25_nc3000_Co060_Fi001_MulG_PF_Nsw042.nc

#FILESDIR=/glade/campaign/cgd/amp/aherring/archive/${CASE}/atm/hist
FILESDIR=/glade/scratch/aherring/archive/${CASE}/atm/hist

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

STR_DETECT="--verbosity 0 --timestride 1 --out cyclones_tempest.${UQSTR} --closedcontourcmd PSL,100.0,6.0,0 --mergedist 8.0 --searchbymin PSL --outputcmd PSL,min,0;_VECMAG(UBOT,VBOT),max,2;PHIS,max,0 --minlat 45.0 --maxlat 90.0"

${TEMPESTEXTREMESDIR}/bin/DetectNodes --in_data_list "${FILELISTNAME}" ${STR_DETECT} 

rm -f cyclones_list.${UQSTR}
cat cyclones_tempest.${DATESTRING}* >> cyclones_list.${UQSTR}
rm cyclones_tempest.${DATESTRING}*

### ### ### ### ### ### ### ###

STR_STITCH="--format i,j,lon,lat,slp,wind,phis --range 8.0 --minlength 5 --maxgap 0 --min_endpoint_dist 10.0 --threshold wind,>=,10.0,6."

echo "Executing StitchNodes..."
${TEMPESTEXTREMESDIR}/bin/StitchNodes ${STR_STITCH} --in cyclones_list.${UQSTR} --out trajectories.ge.45N.txt.${UQSTR}

rm log*
rm cyclones_list.${UQSTR}

exit
