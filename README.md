# STORM-COMPOSITER by Adam Herrington, July 2020 (aherring@ucar.edu)

storm-compositer takes in a .txt file from DetectNodes,StitchNodes from TempestExtremes
(https://github.com/ClimateGlobalChange/tempestextremes)

Creates 2D composite on a grid with a 20degree great circle distance about the storm center,
and generates a PDF. Currently only works for model output on unstructured grids

INSTALLATION

Create wrapper to wrap Fortran90 routine rotate2d.F90 into NCL:
WRAPIT rotate2d.stub rotate2d.f90

Original Fortran90 routine modified from:
Peter H. Lauritzen, Christiane Jablonowski, Mark Taylor and Ramachandran D. Nair, 2010: Rotated versions of the Jablonowski steady-state and baroclinic wave test cases: A dynamical core intercomparison. J. Adv. Model. Earth Syst., Vol. 2, Art. #15, 34 pp.

INSTRUCTIONS

1. Run python script to convert .txt TempestExtremes files to compact 2D variables (stormID,ntrack) and convert to netcdf

	Modify the input and output files in the script. Load libraries and run::

	module load python
	ncar_pylib (this is to load the netcdf4 module used by python script)
	python convert_traj_file.py

	python script courtesy of Alyssa Stansfield (alyssa.stansfield@stonybrook.edu)

2. Modify composite.sh

	Need to specify location of model output, the netcdf from previous step, and the SCRIP grid file for the model output grid

3. Modify composite-v6.ncl

	Set the variable to be compsited and the parameters of the PDF, e.g.:

	VAR = "PRECT";
	sfactor = secpday*1000;

	nbins = 500;
	binmin = 0.;
	binmax = 500.;

	Set the month to composite over, e.g.,

	monthNam = "JAN";
	imonth = 0;
	monthstr = "01";

4. Submit compsite.sh as batch job, e.g., for casper:

	sbatch composite.sh

5. Plot composite (scripts available in plot-scripts directory)


