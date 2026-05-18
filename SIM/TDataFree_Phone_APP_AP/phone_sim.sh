#/bin/sh
START_TIME=`date '+%C%y%m%d %H:%M:%S'`

if [ $# -ne 3 ]
then
	echo "############################################################################################"
	echo " ERROR] Please Must Input 3 Prameter [MDN_RANGE, API CALL TPS, Aging Douration(Hour)]"
	echo " - API CALL TPS Mean that Smartphone APP receive Push Terminal Count by UPM Server"
	echo " Ex) ./phone_sim.sh 100000 74 24"		
	echo "############################################################################################"
	exit
fi

MDN_RANGE=$1
TPS=$2
AGING_TIME=$3

START_TIME=`date '+%Y%m%d%H%M%S'`

echo ""
echo "## MOBILE APP API CALL SIMULATOR START ] ####################"

while [ true ]
do 
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
	java -cp . PermAPISimulator 50.10.23.128 $MDN_RANGE 10 $TPS
done

END_TIME=`date '+%C%y%m%d %H:%M:%S'`
echo "## $START_TIME [S] ~ $END_TIME [E] ####################"
echo ""
