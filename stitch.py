import astropy.io.fits as fits
import numpy as np

def stitch(infiles, frameshape, outfile):
    if frameshape[0]*frameshape[1] != len(infiles):
        raise Exception('Wrong shape')
    
    # Get the size from the first frame
    testfile = fits.open(infiles[0])
    inshape = np.shape(testfile[0].data)
    shape = inshape * np.array(frameshape)
    testfile.close()
    
    data = np.reshape(np.zeros(np.prod(shape)), shape)

    x = 0
    y = 0
    for f in infiles:
        file = fits.open(f)
        if np.shape(file[0].data) != inshape:
            raise Exception('file ' + f + ' has wrong shape')

        x1 = x * inshape[0]
        x2 = (x + 1) * inshape[0]
        y1 = y * inshape[1]
        y2 = (y + 1) * inshape[1]
        data[x1:x2, y1:y2] = file[0].data

        print x, y, frameshape[0]
        x += 1
        if (x >= frameshape[0]):
            x = 0
            y += 1

    hdu = fits.PrimaryHDU(data)
    hdu.writeto(outfile, clobber=True)

# stitch(['SQT20131111_B_1_1.postage.fits', 'SQT20131111_B_1_2.postage.fits', 'SQT20131111_B_1_3.postage.fits', 'SQT20131111_B_1_4.postage.fits', 'SQT20131111_B_1_5.postage.fits', 'SQT20131111_B_1_5.postage.fits'], [1,6], 'test2.fits')