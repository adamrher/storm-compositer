#take data from Stitchnodes output (textfile) and convert it to a NetCDF

from netCDF4 import Dataset, num2date, date2num
import numpy as np
import datetime as dt
import os


ntimes = []
header_locs = []
nstorms = 0

#reading in the text file and the data
with open("trajectories.ge.45N.txt.f09","r") as f:
    data = f.readlines()#read rest of data line by line and store in variable "data"
    line_count = 0
    for line in data:
        if "start" in line.split():
            ntimes.append(int(line.split()[1])) #save the number of time steps of data for each storm
            nstorms += 1 #counting total number of storms in file based on # of header lines
            header_locs.append(line_count)#find locations of all lines that begin with "start"
        line_count += 1


#create empty numpy arrays of appropriate shape to hold data
iis= np.empty([int(nstorms),max(ntimes)])
jjs= np.empty([int(nstorms),max(ntimes)])
lons = np.empty([int(nstorms),max(ntimes)])
lats = np.empty([int(nstorms),max(ntimes)])
ps = np.empty([int(nstorms),max(ntimes)])
wind_max = np.empty([int(nstorms),max(ntimes)])
year = np.empty([int(nstorms),max(ntimes)],dtype=int)
month = np.empty([int(nstorms),max(ntimes)],dtype=int)
day = np.empty([int(nstorms),max(ntimes)],dtype=int)
hour = np.empty([int(nstorms),max(ntimes)],dtype=int)
dates = np.empty([int(nstorms),max(ntimes)],dtype=int)


#now put actual data from file into the arrays
for i in range(nstorms):
    start = header_locs[i] + 1
    end = start + int(ntimes[i])
    tmp = data[start:end] #only work with subset of data for each individual stormID
    j = 0 
    for row in tmp:
        columns = row.split() #split each line by whitespaces
        iis[i,j] = (int(columns[0]))
        jjs[i,j] = (int(columns[1]))
        lons[i,j] = (float(columns[2]))
        lats[i,j] = (float(columns[3]))
        ps[i,j] = (float(columns[4])/100) #convert from Pa to hPa
        wind_max[i,j] = (float(columns[5]))
        year[i,j] = (int(columns[7]))
        month[i,j] = (int(columns[8]))
        day[i,j] = (int(columns[9]))
        hour[i,j] = (int(columns[10]))
        j+=1

#create new NetCDF file to write
new_file = Dataset('trajectories.f09.ge.45N.nc','w',format='NETCDF4')
new_file.description = 'Results from tempestextremes reformatted to NetCDF'
new_file.author = 'Adam Herrington'
new_file.creation_date = str(dt.date.today())


#create dimensions
stormID = new_file.createDimension('stormID', None) #create dimension based on total number of storms in file
time = new_file.createDimension('time',int(max(ntimes)))

#create variables
ci = new_file.createVariable('ci','i4',('stormID','time'),fill_value = -9999)
cj = new_file.createVariable('cj','i4',('stormID','time'),fill_value = -9999)
clon = new_file.createVariable('clon','f4',('stormID','time'),fill_value = -9999.00)
clat = new_file.createVariable('clat','f4',('stormID','time'),fill_value = -9999.00)
ps_min = new_file.createVariable('ps_min','f4',('stormID','time'),fill_value = -9999.00)
mwind = new_file.createVariable('mwind','f4',('stormID','time'),fill_value = -9999.00)
time = new_file.createVariable('time','i4',('stormID','time'),fill_value = -9999)


#add local attributes to variables
ci.units = 'index'
ci.long_name = 'storm center lon index'

cj.units = 'index'
cj.long_name = 'storm center lat index'

clon.units = 'degrees_east'
clon.long_name = 'storm center longitude'

clat.units = 'degrees_north'
clat.long_name = 'storm center latitude'

ps_min.units = 'hPa'
ps_min.long_name = 'minimum central pressure'

mwind.units = 'm/s'
mwind.long_name = 'maximum wind speed'


#add extracted data into netCDF variables
ci[:,:] = iis
cj[:,:] = jjs
clon[:,:] = lons
clat[:,:] = lats
ps_min[:,:] = ps
mwind[:,:] = wind_max


#storm time variable as integers
for i in range(nstorms):
    for j in range(ntimes[i]):
        time[i,j] = int(str(year[i,j]) + str(month[i,j]).zfill(2) + str(day[i,j]).zfill(2) + str(hour[i,j]).zfill(2))

new_file.close()
