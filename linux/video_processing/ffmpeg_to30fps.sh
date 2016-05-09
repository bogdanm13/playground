#!/bin/sh

set +x 
set -e

list=`ls $1`
echo "will process: $list"
for video in $list; do 
	echo "processing $video"
	ffmpeg -y -i ${video} -r 30 -c:v libx264 -b:v 2M -strict -2 -movflags faststart ${video}_30fps.mp4
done
