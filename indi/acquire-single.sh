#!/bin/bash
# Acquire a run of frames using a single camera

basedir=/home/saft/OBS_DATA/20150316/flat-10s-
cam=andor0
exp_count=10
exp_start=0
exp_time=10
exp_shutter_close="Off"
exp_shutter_auto="On"
# Make sure that these has been issued first
# indiserver ${cam}
# setINDI ${cam}.temperature_control.setting=-60 # for the red camera
# setINDI ${cam}.temperature_control.setting=-30 # for the blue camera
setINDI ${cam}.shutter.close=${exp_shutter_close}
setINDI ${cam}.shutter.auto=${exp_shutter_auto}
setINDI ${cam}.image_exposure.time=${exp_time}
setINDI ${cam}.archive.base_name=${basedir}
setINDI ${cam}.image.number=${exp_start}
setINDI ${cam}.frame.multi=${exp_count}
setINDI ${cam}.acquire.single=Off
setINDI ${cam}.acquire.multi=On
setINDI ${cam}.sequence.run=On
sleep 1
run=1
while [[ (${run} -eq 1) ]]; do
sleep 1
    run=‘getINDI ${cam}.sequence.run | cut -f 2,2 -d "=" | grep -c "On"‘
done
echo "Run Complete"