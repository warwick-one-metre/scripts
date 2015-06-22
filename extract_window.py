#!/usr/bin/env python

#
# Script to extract a windowed region inside a set of fits images.
# Frames are correlated with a refererence frame (using tsreduce)
# to correct for telescope drift between frames.
#

import os
import re
import subprocess
import astropy.io.fits as fits
import numpy as np

# Define reference frame and extraction window
ref_frame = "SQT20131111_B_1_2.fits"
ref_window = [769, 524, 50]

# Suffix to insert between the filename and extension
output_suffix = '.window'

# Shell command listing the frames to extract
frame_command = 'ls *.fits | grep -v "' + output_suffix + '" | grep "_B_1"'

# Fetch the frames to extract
p = subprocess.Popen(frame_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
frames = map(lambda s: s.strip(), p.stdout.readlines())
retval = p.wait()

for frame_in in frames:
    # Find frame offsets
    p = subprocess.Popen('tsreduce translation ' + ref_frame + ' ' + frame_in, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    translation = re.search('Translation: (-?[0-9]+) (-?[0-9]+)', ''.join(p.stdout.readlines()))
    retval = p.wait()

    x = ref_window[0] - int(translation.group(1))
    y = ref_window[1] - int(translation.group(2))
    r = ref_window[2]

    # Create the output filename
    split = os.path.splitext(frame_in)
    frame_out = split[0] + output_suffix + split[1]

    print "extracting {0} -> {1} with window ({2},{3},{4})".format(frame_in, frame_out, x, y, r)

    file = fits.open(frame_in)
    head = file[0].header.copy()
    data = file[0].data

    img = data[y-r:y+r, x-r:x+r]
    head['NAXIS1'] = 2*r
    head['NAXIS2'] = 2*r

    newfile = fits.PrimaryHDU(data=img,header=head)
    newfile.writeto(frame_out, clobber=True)
    file.close()