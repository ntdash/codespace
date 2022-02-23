#! /usr/bin/env bash


if [ ! -d ${ENTRYPOINT_INIT_D} ]
then 
   bash -c "$@"
   exit
fi

REPORT_FILE="${ENTRYPOINT_INIT_PATH}/report.log"

# create report file
touch "${REPORT_FILE}"

for file in ${ENTRYPOINT_INIT_D}/*.sh
do
   if [ -f $file ]
   then
      echo -e "=======\n[$(date)]: Sourcing report of ($file)...\n=======" >> "${REPORT_FILE}"
      source $file | tee -a "${REPORT_FILE}"
      echo -e "\n\n"
   fi
done

bash -c "$@"
