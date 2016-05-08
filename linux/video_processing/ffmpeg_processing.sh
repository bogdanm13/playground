#!/bin/bash

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
