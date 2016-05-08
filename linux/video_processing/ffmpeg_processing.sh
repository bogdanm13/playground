#!/bin/bash

wd=`dirname $0`
source $wd/ffmpeg_join.sh
source $wd/ffmpeg_cut.sh

_process_input(){
 while read line; do
  arr=(${line// / })
  cmd=${arr[0]}
  unset arr[0]
  args=${arr[*]}
  echo $cmd : $args
  # have to process input otherwise ffmpeg takes it
  #$cmd $args
 done
}

main(){
 _process_input  
}

if [[ $0 =~ ffmpeg_processing.sh$ ]];
then
 main $*
fi
