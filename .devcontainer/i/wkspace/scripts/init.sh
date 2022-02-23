#! /usr/bin/env bash

# clean up
[ -d "${STUB_PATH}" ] && rm -rf "${STUB_PATH}"
[ -d "${SCRIPT_PATH}" ] && rm -rf "${SCRIPT_PATH}"



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
