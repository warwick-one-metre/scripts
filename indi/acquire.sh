#!/bin/bash
# Acquire a run of frames using a single camera

basedir=/home/testnuc/OBS_DATA/20150831/test-
cam=andor0
exp_count=1
#exp_start=0
exp_time=1
exp_shutter_close=1

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
    tsreduce preview ${saved} Online_Preview
#    ./guide.sh
#    ./reduce.sh
    echo "Saved " ${saved}
done