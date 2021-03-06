#!/bin/sh

set +x
set -e 

_join_parse_args(){
 input=""
 while [ $# -gt 1 ]; do 
  input="$input $1"
  shift
 done 
 output=$1
}

join(){
 _join_parse_args $*
 echo "Joining files $input into $output"

 tmpfile=`mktemp`

 for f in $input; do 
  echo file $PWD/"$f" >> $tmpfile
 done

 ffmpeg -safe 0 -f concat -i ${tmpfile} -c copy $output && rm -f ${tmpfile}
}

main(){
 join $*
}

if [[ $0 =~ ffmpeg_join.sh$ ]];
then 
 main $*
fi

