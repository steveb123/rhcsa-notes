#!/bin/bash

# copy questions to vm
# scp -P 2201 -i .vagrant/machines/default/virtualbox/private_key -r questions vagrant@127.0.0.1:/home/vagrant/

cat /dev/null > results.html

ssh vagrant@127.0.0.1 -p 2201 -i .vagrant/machines/default/virtualbox/private_key 'for q in questions/question*.sh; do echo -n $(basename $q .sh) && echo ':' $($q result);done' >> results.html

