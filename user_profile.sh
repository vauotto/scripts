#!/bin/bash

# Tasy-interfaces url "http://localhost:50001/tasy-interfaces/resources/api/user/profile?maxResults=50&page=$i"


TOKEN='K7mxr2U3SmT5khFkbpJtMmVAHMTeMiL6axTMJb2tEm1bSHnKRmWxlIPI9fPdy1yo'
API_URL='http://bifrostdev.whebdc.com.br:9090/api/user/profile'
OUTPUT_DIRECTORY='tie_user_profile'

# pagination logic
payload=$(curl --request GET --url "$API_URL?maxResults=1&page=1" --header "Authorization: Bearer $TOKEN")
total=$(echo "$payload" | grep -o '"totalElements":[[:space:]]*[0-9]*' | sed 's/[^0-9]//g')
maxResults=50
numPages=$(((total/$maxResults) + 1))

rm -rf $OUTPUT_DIRECTORY || true
mkdir -p $OUTPUT_DIRECTORY

for i in $(seq 1 $numPages); do
    echo "Requisição $i: "
    curl --request GET --url "$API_URL?maxResults=50&page=$i" --header "Authorization: Bearer $TOKEN"  -o $OUTPUT_DIRECTORY/user_profile_$i.json
done
