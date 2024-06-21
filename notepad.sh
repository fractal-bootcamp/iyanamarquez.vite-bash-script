#!/bin/bash

echo "Hello World!" 
# capture input
# read -p "What is your name? " name
# echo $name "is a name"



# gets all shoe ids
call_api(){
    echo 'called'
    response=$(curl --location --request GET 'http://localhost:4000/shoes' \
--header 'Content-Type: application/json' \
)

ids=($(echo "$response" | jq -r '.[].id'))
# Display each ID
echo "IDs:"
for id in "${ids[@]}"; do
  echo "$id"
done
}

call_api