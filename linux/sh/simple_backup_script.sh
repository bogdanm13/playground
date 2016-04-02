#!/bin/bash

backup_folder=/backup
tmp_file=/tmp/simple_backup_script_sh.tmp

help(){
cat << EOF
$0 [option]

Options:
apply - moves the vulnerable files to ${backup_folder}
EOF
}

check_applied(){
test -e ${backup_folder} && echo "Already applied" && exit 1
}

prepare_file_list(){
rm -f ${tmp_file}
cat <<EOF |
/absolute/file/path
/path/with/*/in/it
EOF
# note, placing a command here breaks the pipe
# expand * with find and save them for processing
while read file;
do
    find $file >> ${tmp_file}
done
}

backup(){
# finally do the move
while read file;
do
    dest=${backup_folder}/`dirname $file`
    mkdir -p $dest
    test -e $file && mv -f -v $file $dest
done < $1
}

_apply(){
check_applied

mkdir -p ${backup_folder}
echo Moving files to $backup_folder

prepare_file_list
backup ${tmp_file}
}


if [ $# -lt 1 ]; then
    help
else
    _$1
fi
