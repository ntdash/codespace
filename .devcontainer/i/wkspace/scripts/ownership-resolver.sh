#! /usr/bin/env bash

USERNAME=${1:-'code'}
OLIST=${@:2}

if [ "$2" == "" ]
then
   exit
fi

OLIST=$(echo ${OLIST} | sed "s/:/ /")

tee /usr/local/share/init.d/ownership-resolver.sh > /dev/null \
<< EOF
#! /usr/bin/env bash

set -e

for arg in $OLIST
do
   if [ -e \$arg ]
   then
      # Add recursive option to command if $arg is a folder ...
      if [ -d \$arg ]
      then
         recursive_opt='-R'
      else
         recursive_opt=""
      fi
      # Apply ownership change
      chown ${username}:root \$recursive_opt \$arg
   fi
done

set +e

EOF

echo "\nDone !\n"