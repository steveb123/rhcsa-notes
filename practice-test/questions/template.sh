#!/bin/bash

#### Question goes here
question='text for the question, eg "Create a user called spiderman"'


if [ $1 = question ]
then
    echo $question
    exit 
elif [ $1 = result ]
then

#### Test goes here #### 	
    if id spiderman &> /dev/null
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
