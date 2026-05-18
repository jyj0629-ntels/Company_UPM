#!/bin/sh
if [ $# != 2 ]; then
        echo "##############################################"
        echo "ERROR>>>> Please input parameter PID and NID"
        echo "##############################################"
        exit;
fi

P_PID=$1
P_NID=$2

if [ "$P_SLEEP" == "" ]; then
        P_SLEEP=0.5
fi

if [ "$P_CNT" == "" ]; then
        P_CNT=10
fi

echo Sampling PID=$P_PID every $P_SLEEP seconds for $P_CNT samples

if [ "$P_NID" == "" ]; then
        CMD="awk '//'"
else
        CMD="awk '/ nid='"$(printf '%#x' $P_NID)"' /,/^$/'"
fi

for i in `seq $P_CNT`
do
jstack $P_PID | eval $CMD
sleep $P_SLEEP;
done |
awk ' BEGIN { x = 0; s = "" }
/nid=/ { x = 1; }
// {if (x == 1) {s = s ", "gensub(/<\w*>/, "<address>", "g") } }
/^$/ { if ( x == 1) { print s; x = 0; s = ""; } }' |
sort | uniq -c | sort -n -r | head -10 |
sed -e 's/$/\n/g' -e 's/\t/\n\t/g' -e 's/,//g'

