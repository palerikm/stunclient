#!/bin/bash

output_file="out.csv"

filename=server_list.conf

interface="eth0"
ip=""
runs=2
output_file="out.json"
test_name="test"

tmp_csv="tmp.csv"
post_server="http://ec2-35-166-234-254.us-west-2.compute.amazonaws.com/discovery-result"
server_list="http://ec2-35-166-234-254.us-west-2.compute.amazonaws.com/discovery-config.json"
while getopts "h?i:f:r:o:t:p:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    r)  runs=$OPTARG
        ;;
    i)  interface=$OPTARG
        ;;
    f)  output_file=$OPTARG
        ;;
    t)  test_name=$OPTARG
        ;;
    p)  post_server=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

ip=$@

curl -s $server_list | jq -r '.[] | [.ip, .port] |@csv' > $filename
#cat discovery-config | jq -r '.[] | .[] | [.candidateIP, .candidatePort] |@csv' > $filename

rm $tmp_csv
printf "Start,Stop,transactionID,ServerAddr,ClientAddr,RFLXAddr,RTT,retries,clientsent,serversent\n" > $tmp_csv
while IFS=, read ip_q port
do
  ip=$(echo "$a" | sed -e 's/^"//' -e 's/"$//' <<<"$ip_q")
  echo "Pinging $ip at $port"
  for (( i=1; i<=$runs; i++ ))
  do
   echo "  Run $i"
   build/dist/bin/stunclient -i $interface $ip -p $port -j 5 --csv >> $tmp_csv
  done
  #./nattorture.sh -i en7 -r 2 -f tmp.csv -p $port $ip
  #cat tmp.csv >> $output_file
done < "$filename"

csv2json $tmp_csv $output_file

echo "Posting to $post_server"
curl -H "Content-Type: application/json" -X POST --data @$output_file $post_server
