#!/bin/sh

set +x 

echo "will process: $*"
sleep 2
for video in $*; do 
	echo "processing $video"
	sleep 2
	video_out=`basename "$video"`
	ffmpeg -y -i ${video} -r 30 -c:v libx264 -b:v 2M -strict -2 -movflags faststart ${video_out}_30fps.mp4 2>&1 | tee ${video_out}_to30fps.log
done
