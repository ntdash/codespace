#! /usr/bin/env bash

USERNAME=${1:-'code'}
OLIST=${@:2}

if [ "$2" == "" ]
then
   exit
fi

OLIST=$(echo $OLIST | sed 's/:/ /g')

sed -i -e "s^\#PH_OLIST^$OLIST^" /tmp/scripts/ownership-resolver.stub

# Move processed stub into init.d
mv /tmp/scripts/ownership-resolver.stub /usr/local/share/init.d/ownership-resolver.sh

echo "\nDone !\n"