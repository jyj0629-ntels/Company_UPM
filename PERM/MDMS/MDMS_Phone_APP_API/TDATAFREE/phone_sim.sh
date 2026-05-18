#/bin/sh
START_TIME=`date '+%C%y%m%d %H:%M:%S'`
#SERVER_IP="192.168.10.85"
SERVER_IP="127.0.0.1"


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
echo "## MOBILE APP API CALL SIMULATOR START ] ###############################################"
echo "   SERVER_IP : $SERVER_IP --> Please Check this! if wrong, please change shell script"
echo "########################################################################################"

# RESULT FILENAME
RESULT_FILE="RESULT/API_LOG_${TPS}tps_${AGING_TIME}hour-${START_TIME}.log"
# RESULT Directory Check
if [ ! -d "RESULT" ]; then
        mkdir RESULT
fi

while [ true ]
do 
NOW_TIME=`date +%Y%m%d%H%M%S -d -${AGING_TIME}hours`
if [ $NOW_TIME -gt $START_TIME ]
then
        END_TIME=`date '+%Y%m%d%H%M%S'`
        echo "########################################################" | tee -a $RESULT_FILE
        echo " Working Complete for Aging Hour [$AGING_TIME hours]"     | tee -a $RESULT_FILE
        echo " START : $START_TIME ~ END : $END_TIME"                   | tee -a $RESULT_FILE
        echo "########################################################" | tee -a $RESULT_FILE
        exit
fi
        java -cp . PermAPISimulator $SERVER_IP $MDN_RANGE 10 $TPS | tee -a $RESULT_FILE
done

END_TIME=`date '+%C%y%m%d %H:%M:%S'`
echo "## $START_TIME [S] ~ $END_TIME [E] ####################" | tee -a $RESULT_FILE
echo ""
