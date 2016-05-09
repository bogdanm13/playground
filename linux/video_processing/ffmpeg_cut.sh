#!/bin/bash

set +x 
set -e 

_cut_parse_args(){
 input=$1
 ss=$2
 t=$3
 output=$4
}

cut(){
 _cut_parse_args $*
 echo "Cutting from $input starting with $ss upto $t into $output"
 ffmpeg -i $input -ss $ss -t $t -c copy $output 
}

main(){
 cut $*
}

if [[ $0 =~ ffmpeg_cut.sh$ ]];
then 
 main $*
fi

