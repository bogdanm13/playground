#!/bin/sh

set +x 
set +e

convert(){
 video=$1 # like file/path 
 framerate=$2 # like 30
 bitrate=$3 # like 2M

 video_out=`basename "$video"`_${framerate}fps_${bitrate}.mp4
 echo "Processing $video into $video_out at $framerate fps with $bitrate bitrate"

 ffmpeg -y -i ${video} -r $framerate -c:v libx264 -b:v $bitrate -strict -2 -movflags faststart ${video_out} 2>&1
}

main(){
 convert $*
}

if [[ $0 =~ ffmpeg_convert.sh$ ]];
then 
 main $*
fi

