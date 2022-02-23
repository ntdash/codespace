#! /usr/bin/env bash

USERNAME=${1:-'code'}
OLIST=${@:2}

if [ "$2" == "" ]
then
   exit
fi

OLIST=$(echo $OLIST | sed 's/:/ /g')

sed -i -e "s^\#PH_OLIST^$OLIST^" "${STUB_PATH}/ownership-resolver.stub"

# Move processed stub into init.d
mv "${STUB_PATH}/ownership-resolver.stub" "${ENTRYPOINT_INIT_D}/ownership-resolver.sh"

echo -e "\nDone!\n"