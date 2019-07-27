#!/bin/bash

#### Question goes here
question='Reset the root password to hello123, use the Virtualbox console and edit the boot loader to do this.'


if [ $1 = question ]
then
    echo $question
    exit 
elif [ $1 = result ]
then

#### Test goes here #### 	

if [ $(echo 'hello123' | su -c whoami )  == 'root' ]
    then
        result='correct'
    else
        result='incorrect'
    fi
    echo $result
#### End of test ####

else
    echo 'incorrect input'
fi
