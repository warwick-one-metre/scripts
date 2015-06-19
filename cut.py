# Cut a section out of a fits file

import astropy.io.fits as fits
import numpy as np

def cut(infile, outfile, x, y, r):
    file = fits.open(infile)
    head = file[0].header.copy()
    data = file[0].data

    img = data[y-r:y+r, x-r:x+r]
    head['NAXIS1'] = 2*r
    head['NAXIS2'] = 2*r

    newfile = fits.PrimaryHDU(data=img,header=head)
    newfile.writeto(outfile, clobber=True)
    file.close()

# cut("./SQT20131111_B_1_1.fits", "SQT20131111_B_1_1.postage.fits", 769, 524, 50)