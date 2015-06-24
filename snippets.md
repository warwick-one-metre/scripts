###### List exposure times for a set of frames
    for i in `ls *.fits`; do tsreduce metadata $i | awk -v i=$i '/EXPTIME/ { print(i, $3); }'; done

###### List frames matching header info
    for i in `ls *.fits`; do tsreduce metadata $i | awk -v i=$i '/$$filter$$/ { print(i, $3); }'; done

###### Convert postscript &rarr; eps &rarr; pdf preserving images data
    ps2eps -f plot.ps -ignoreBB && gs -sDEVICE=pdfwrite -dEncodeColorImages=false -dEPSCrop -o plot.pdf plot.eps

###### Create a running average of 50 frames and resize the output by 800%
    cat ../ordered2.txt | xargs -n 50 sh -c 'convert "$0" "$@" -average -filter box -resize 800% average/"$0"'

###### Convert a list of frames to an animated gif
    convert -delay 1x20 `cat ../../ordered2.txt` -coalesce -layers OptimizeTransparency test.gif
 
###### Convert and label fits images based on a list of <phase, fits image>
    cat ../../sorted.txt | awk '{ printf("\"%02.0f %s\"\n", 1000*$1, $2) }' | sed 's/fits.gz/png/' | xargs -n 50 sh -c 'NAME=`echo $0 | cut -c 4-`; TIME="`echo $0 | cut -c -3` ms"; convert "$NAME" -pointsize 16 -draw "gravity southwest fill red text 10,5 \"${TIME}\" " "labelled_$NAME";'