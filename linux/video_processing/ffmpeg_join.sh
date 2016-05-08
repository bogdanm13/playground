#!/bin/sh

_parse_args(){
 input=""
 while [ $# -gt 1 ]; do 
  input="$input $1"
  shift
 done 
 output=$1
}

join(){
 tmpfile=tmpfile

 for f in $input; do 
  echo file "$f" >> $tmpfile
 done

 ffmpeg -f concat -i $tmpfile -c copy $output

 rm -f ${tmpfile}
}

main(){
 _parse_args $*
 echo "Joining files $input into $output"
 echo "Press any key to continue..." && read
 join
}

if [[ $0 =~ ffmpeg_join.sh$ ]];
then 
 main $*
fi

