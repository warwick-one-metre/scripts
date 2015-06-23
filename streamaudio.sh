#! /bin/sh

#
# Connects to an IP via ssh and pipes a USB microphone output through the local speakers
#

ssh $1 "arecord -D plughw:1,0 -f dat -c1" | sox -traw -r48000 -b16 -e signed-integer - -tcoreaudio