#! /usr/bin/env bash

resolve_ownership() {

   local username=${1:-'code'}
   local list=${@:2}

tee /usr/local/share/init.d/ownership-resolver.sh > /dev/null \
<< EOF
#! /usr/bin/env bash

set -e

for arg in $list
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
}


if [ "$2" != "" ]
then
   resolve_ownership $@
   echo -e "\nDone"
fi
