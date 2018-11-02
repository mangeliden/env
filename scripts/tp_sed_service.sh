#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Please provide CamelCase service names and file to convert!"
    exit 2
fi

origservice=$1
replservice=$2
file=$3



## Replace CamelCase stuff
echo "sed -i s/$origservice/$replservice/g $file"
sed -i s/$origservice/$replservice/g $file

## Replace camelCase functions
orig_first_char=`echo $origservice | cut -c1 | tr [A-Z] [a-z]`
orig_rest=`echo $origservice|cut -c2-`
origservice_c=`echo $orig_first_char$orig_rest`
repl_first_char=`echo $replservice | cut -c1 | tr [A-Z] [a-z]`
repl_rest=`echo $replservice|cut -c2-`
replservice_c=`echo $repl_first_char$repl_rest`
echo "sed -i s/$origservice_c/$replservice_c/g $file"
sed -i s/$origservice_c/$replservice_c/g $file

## Replace UPPERCASE stuff
origservice_l=`echo $origservice | awk '{print toupper($0)}'`
replservice_l=`echo $replservice | awk '{print toupper($0)}'`
echo "sed -i s/$origservice_l/$replservice_l/g $file"
sed -i s/$origservice_l/$replservice_l/g $file

## Replace lowercase stuff
origservice_s=`echo $origservice | awk '{print tolower($0)}'`
replservice_s=`echo $replservice | awk '{print tolower($0)}'`
echo "sed -i s/$origservice_s/$replservice_s/g $file"
sed -i s/$origservice_s/$replservice_s/g $file
