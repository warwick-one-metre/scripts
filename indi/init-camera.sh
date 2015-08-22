# First start indi using `indiserver andor0`

cam=andor0
temperature=-30
DS9_STARTUP_TIMEOUT=10;
DS9_WINDOW_WIDTH=550;
DS9_WINDOW_HEIGHT=600;
DS9_WINDOW_ZOOM=0.25

setINDI ${cam}.temperature_control.setting=${temperature}

# Called at program startup to initialize ds9
if [[ "$(xpaaccess Online_Preview)" == 'no' ]]; then
	echo "Opening ds9"
    ds9 -title Online_Preview &> /dev/null &
fi

# Wait for ds9 to open then resize the window
for i in $(seq 1 1 ${DS9_STARTUP_TIMEOUT}); do
	if [[ "$(xpaaccess Online_Preview)" == 'yes' ]]; then
		xpaset -p Online_Preview view filename no
		xpaset -p Online_Preview view object no
		xpaset -p Online_Preview view wcs no
		xpaset -p Online_Preview view physical no
		xpaset -p Online_Preview view frame no
		xpaset -p Online_Preview view buttons no
		xpaset -p Online_Preview view colorbar no
		xpaset -p Online_Preview scale mode zscale
		xpaset -p Online_Preview width ${DS9_WINDOW_WIDTH}
		xpaset -p Online_Preview height ${DS9_WINDOW_HEIGHT}
		xpaset -p Online_Preview background black
		xpaset -p Online_Preview regions shape annulus
		xpaset -p Online_Preview view layout vertical
		xpaset -p Online_Preview zoom ${DS9_WINDOW_ZOOM}
		exit 0
	fi
	sleep 1
done

echo "Waiting for ds9 timed out after ${DS9_STARTUP_TIMEOUT} seconds"
exit 1