#!/bin/bash

output_file="out.csv"

filename=server_list.conf
curl -s https://osaf70665k.execute-api.us-west-2.amazonaws.com/prd/discovery-config | jq -r '.[] | .[] | [.candidateIP, .candidatePort] |@csv' > $filename

rm $output_file
printf "Start,Stop,transactionID,ServerAddr,ClientAddr,RFLXAddr,RTT,retries,clientsent,serversent\n" > $output_file
while IFS=, read ip_q port
do
  ip=$(echo "$a" | sed -e 's/^"//' -e 's/"$//' <<<"$ip_q")
  echo "I got:$ip on port $port"
  ./nattorture.sh -i en7 -r 2 -f tmp.csv -p $port $ip
  cat tmp.csv >> $output_file
done < "$filename"

csv2json out.csv -o $@
