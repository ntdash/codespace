#! /usr/bin/env bash

USERNAME=${1:-'code'}
OLIST=${@:2}

if [ "$2" == "" ]
then
   exit
fi

OLIST=$(echo ${OLIST} | sed "s/:/ /")

sed "s/#OLIST/${OLIST}/" /tmp/ownership-resolver.stub

# Move stub into init.d
mv /tmp/ownership-resolver.stub /usr/local/share/init.d/ownership-resolver.sh

echo "\nDone !\n"