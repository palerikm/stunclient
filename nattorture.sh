#!/bin/bash

#usage ./nattorture.sh [interface[] [ip] [port] [number of runs] [outfile]

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:

interface="eth0"
ip=""
runs=10
output_file="out.csv"
test_name="test"
port=3478

lockfile=nattorture.lock

touch $lockfile

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
    p)  port=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

ip=$@
echo "interface=$interface, output_file='$output_file',runs='$runs', port: '$port'", ip: $ip,

rm $output_file
#printf "Start, Stop, transaction ID, failed, Server Addr, Client Addr, RFLX Addr, RTT (micro sec), retries, client sent, server sent\n" > $output_file
for (( i=1; i<=$runs; i++ ))
do
  echo "Run $i"
 build/dist/bin/stunclient -i $interface $ip -p $port -j 60 --csv >> $output_file
done

rm $lockfile
