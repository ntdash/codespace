#! /usr/bin/env bash

[ -d "/tmp/scripts" ] && rm -rf "/tmp/scripts"


fpath="/usr/local/share"
report_fpath="${fpath}/report"

# create report file
touch "${report_fpath}"

for file in $fpath/init.d/*.sh
do
   if [ -f $file ]
   then
      echo -e "=======\n[$(date)]: Sourcing report of ($file)...\n=======" >> "${report_fpath}"
      source $file | tee -a "${report_fpath}"
      echo -e "\n\n"
   fi
done

bash -c "$@"
