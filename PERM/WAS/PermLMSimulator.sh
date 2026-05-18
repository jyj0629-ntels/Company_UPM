#/bin/sh
################################################
# Java Parameter Help
# 1th : ZONE_AVP 
# 2th : device_ip 
# 3th : subscriber count 
# 4th : inser tps (must be below 2000tps) 
# 5th : repeat count (option)
################################################
if [ $# -ne 3 ]; then
	echo "Usage Error] #######################################################"
	echo " - You must input 3 parameter"
	echo "    Ex) ./PermLMSimulator.sh Subscriber_count tps agingtime(hour)"
	echo "####################################################################"
	exit
fi

IDX=0
SUBSCRIBER_CNT=$1
TPS=$2
AGING_TIME=$3

START_TIME=`date '+%Y%m%d%H%M%S'`

while [ true ]
do
# Start / End time during aging hours Check Logic
NOW_TIME=`date +%Y%m%d%H%M%S -d -${AGING_TIME}hours`
if [ $NOW_TIME -gt $START_TIME ]
then
	END_TIME=`date '+%Y%m%d%H%M%S'`
	echo "########################################################" 
	echo " Working Complete for Aging Hour [$AGING_TIME hours]"
	echo " START : $START_TIME ~ END : $END_TIME"
	echo "########################################################"
	exit
fi 
IDX=`expr $IDX + 1`
echo ""
echo "###############################################################################"
echo "### $IDX th - Zone In  ] ######################################################"
java -cp ./*:. PermLMSimulator 91000 127.0.0.1 $SUBSCRIBER_CNT $TPS 1
echo "### $IDX th - Zone Out ] ######################################################"
java -cp ./*:. PermLMSimulator 92000 127.0.0.1 $SUBSCRIBER_CNT $TPS 1
done
