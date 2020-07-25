#!/bin/tcsh

#SBATCH --job-name=composite
#SBATCH --account=P54048000
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=03:00:00
#SBATCH --partition=dav
#SBATCH --output=composite.out.%j
#SBATCH --mem=300G

set label = "ne30pg3.ge.45N"

#MODEL OUTPUT
set data_dir = "/glade/scratch/$USER/archive/"
set case = "cam6_2_022.se_FHIST_ne30pg3_ne30pg3_mg17_1800pes_200507_mg3-Nx5yrs"
set rdir = "/atm/hist/"
set fincl = "h3"

#SCRIP GRID FILE USED IN MODEL OUTPUT
set srcGrid  = "/glade/work/aherring/grids/uniform-res/ne30np4.pg3/grids/ne30pg3_scrip_170611.nc"

#TEMPEST EXPTREMES trajectory.txt file
set tname = "/glade/work/aherring/CESM2/ASP/arctic/tempestextremes/detectnodes/data/trajectories.ne30pg3.ge.45N.nc"

#OUTPUT DIRECTORY
set outdir = ""

ncl 'dir="'$data_dir'"' 'rdir="'$rdir'"' 'fname="'$case'"' 'fincl="'$fincl'"' 'label="'$label'"' 'srcGrid="'$srcGrid'"' 'tname="'$tname'"' 'outdir="'$outdir'"' composite-v6.ncl
