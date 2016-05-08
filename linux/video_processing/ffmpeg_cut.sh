#!/bin/bash

set -x 

_parse_args(){
 input=$1
 ss=$2
 t=$3
 output=$4
}

cut(){
 ffmpeg -i $1 -ss $2 -t $3 -c copy $4
}

main(){
 _parse_args $*
 echo "Cutting from $input starting with $ss upto $t into $output"
 echo "Press any key to continue..." && read
 cut $input $ss $t $output
}

if [[ $0 =~ ffmpeg_cut.sh$ ]];
then 
 main $*
fi

