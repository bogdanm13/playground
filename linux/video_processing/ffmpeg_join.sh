#!/bin/sh

input=""
while [ $# -gt 1 ]; do 
	input="$input $1"
	shift
done 
output=$1

echo "Joining files $input into $output"
echo "Press any key to continue..." && read

tmpfile=tmpfile

for f in $input; do 
	echo file "$f" >> $tmpfile
done

ffmpeg -f concat -i $tmpfile -c copy $output

rm -f ${tmpfile}
