#!/bin/bash
# Acquire a run of frames using a single camera

basedir=/home/testnuc/OBS_DATA/20150831/test-
cam=andor0
exp_count=1
#exp_start=0
exp_time=1
exp_shutter_close=1
solve_wcs=1

# How much do we trust the telescope pointing (in degrees)?
pointing_uncertainty=0.5

if [[ (${exp_shutter_close} -eq 1) ]]; then
  setINDI ${cam}.shutter.close="On"
  setINDI ${cam}.shutter.auto="Off"
else
  setINDI ${cam}.shutter.auto="On"
fi

setINDI ${cam}.image_exposure.time=${exp_time}
setINDI ${cam}.archive.base_name=${basedir}
# setINDI ${cam}.image.number=${exp_start}

# To acquire multiple frames without the bash loop
# setINDI ${cam}.acquire.single=Off
# setINDI ${cam}.acquire.multi=On
# setINDI ${cam}.sequence.run=On

# Acquiring individual frames in a loop so we can
# process them as they come in
setINDI ${cam}.acquire.single=On

setINDI ${cam}.fits_script.file="ssh saft@192.168.0.101 getshm"
setINDI ${cam}.fits_script.run=On

setINDI ${cam}.image_binning.x=1
setINDI ${cam}.image_binning.y=1

setINDI ${cam}.image_region_control.option=Off
#setINDI ${cam}.image_region.y=768
#setINDI ${cam}.image_region.h=512

for i in `seq 1 1 ${exp_count}`; do
    setINDI ${cam}.sequence.run=On
    echo "start"

    sleep 1
    run=1
    while [[ (${run} -eq 1) ]]; do
        sleep 1
        run=`getINDI ${cam}.sequence.run | cut -f 2,2 -d "=" | grep -c "On"`
    done
    saved=`getINDI ${cam}.file.name | cut -f 2,2 -d "="`
	
	if [[ (${solve_wcs} -eq 1) ]]; then
		solvedname="$(basename ${saved} .fits).solved.fits"
		wcsname="$(basename ${saved} .fits).wcs"
		ra=$(tsreduce metadata ${saved} | grep RAEOD | cut -d' ' -f3)
		dec=$(tsreduce metadata ${saved} | grep DECEOD | cut -d' ' -f3)
		echo $FILENAME $RA $DEC $SOLVEDNAME $WCSNAME

		/usr/local/astrometry/bin/solve-field --no-fits2fits --overwrite --no-plots --axy "none" --rdls "none" --match "none" --corr "none" --index-xyls "none" --solved "none" --new-fits ${solvedname} --scale-units "arcminwidth" --scale-high 13.4 --ra ${ra} --dec ${dec} --radius ${pointing_uncertainty} ${saved}
		rm "${wcsname}"
		
		if [[ (-e ${solvedname}) ]]; then
	    	tsreduce preview ${solvedname} Online_Preview
		else
			echo "Failed to solve WCS for" ${saved}
	    	tsreduce preview ${saved} Online_Preview
		fi
	else
    	tsreduce preview ${saved} Online_Preview
	fi
#    ./guide.sh
#    ./reduce.sh
    echo "Saved " ${saved}
done
