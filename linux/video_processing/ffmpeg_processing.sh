#!/bin/bash

# Usage example:
# cut GOPR0050.MP4_30fps.mp4 ss=00:00:00 t=00:00:25 cut1.mp4
# cut GOPR0050.MP4_30fps.mp4 ss=00:01:15 t=00:00:35 cut2.mp4
# join cut1.mp4 cut2.mp4 result.mp4

set +x
set -e

wd=`dirname $0`
source "$wd/ffmpeg_join.sh"
source "$wd/ffmpeg_cut.sh"

_process_input(){
 # read all the lines into an array
 IFS=$'\r\n' GLOBIGNORE='*' command eval 'lines_arr=($(cat))'
 # process each line
 for i in `seq 0 ${#lines_arr[*]}`; do
  arr=(${lines_arr[i]// / })
  cmd=${arr[0]}
  unset arr[0]
  args=${arr[*]}
  echo $cmd : $args
  $cmd $args
 done 
}

main(){
 _process_input  
}

if [[ $0 =~ ffmpeg_processing.sh$ ]];
then
 main $*
fi
