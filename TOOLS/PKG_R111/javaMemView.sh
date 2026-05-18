#/bin/sh
#1) Enviroment Value
RESULT_DATE=`date '+%Y%m%d%H%M%S'`;
PID_FILE="./RESULT/${RESULT_DATE}_PID.log"
GC_RESULT_FILE="./RESULT/${RESULT_DATE}_GC.log"
GCAP_RESULT_FILE="./RESULT/${RESULT_DATE}_GCAP.log"
MEM_RESULT_FILE="./RESULT/${RESULT_DATE}_MEM.log"
CPU_RESULT_FILE="./RESULT/${RESULT_DATE}_CPU.log"

#2) TOMCAT PID Get
if [ $# -ne 1 ]; then
        echo "Usage Error] #######################################################"
        echo " - You must input 1 parameter"
        echo "    Ex) ./javaMemView.sh agingtime(hour)"
        echo "####################################################################"
        exit
fi
AGING_TIME=$1
START_TIME=`date '+%Y%m%d%H%M%S'`

ps -ef | grep tomcat | grep java > $PID_FILE
PID=`awk -F' ' '{print $2}' $PID_FILE`

if [ -z $PID ]; then
	echo ""
	echo " Error ] ###################################################################"
	echo " Tomcat is Down, Please Tomcat running"
	echo " ###########################################################################"
	echo ""
	exit
else
	echo ""
	echo "###################################################################"
	echo " jstat -gc / jstat -gcccapacity running"
	echo " You can find log file in 'RESULT' directry"
	echo " Ex) TIMESTAMS_GC.log file / TIMESTAMS_GCAP.log file"
	echo " If you want termination this script, you push 'Ctrl+Z'"
	echo "###################################################################"
	echo ""
fi

sleep 1

#3) jstat Log running
sar -r 1 1 | grep -v Average | grep -v Linux > $MEM_RESULT_FILE
sar 1 1 | grep -v Average | grep -v Linux > $CPU_RESULT_FILE

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

/pm/java/jdk1.7.0_60/bin/jstat -gc -t $PID  >> $GC_RESULT_FILE
/pm/java/jdk1.7.0_60/bin/jstat -gccapacity -t $PID  >> $GCAP_RESULT_FILE 
sar -r 1 1 | grep Average >> $MEM_RESULT_FILE
sar 1 1 | grep Average >> $CPU_RESULT_FILE
sleep 10 
done
