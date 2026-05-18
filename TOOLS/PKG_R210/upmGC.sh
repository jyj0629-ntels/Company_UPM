#/bin/sh
#1) Enviroment Value
RESULT_DATE=`date '+%Y%m%d%H%M%S'`;
JSTAT="/pm/java/jdk1.8.0_151/bin/jstat"

PID_FILE="./${RESULT_DATE}_PID.log"
GC_RESULT_FILE="./${RESULT_DATE}_GC.log"
GCAP_RESULT_FILE="./${RESULT_DATE}_GCAP.log"

#1) TOMCAT PID Get
if [ $# -ne 2 ]; then
#        echo "[ Usage Error] #######################################################"
#        echo " - You must input parameter"
#        echo "    Ex) ./upmGC.sh AGING_COUNT SLEEP_TIME"
#        echo "####################################################################"
        exit
fi
AGING_COUNT=$1
START_TIME=`date '+%Y%m%d%H%M%S'`

ps -ef | grep tomcat | grep java > $PID_FILE
PID=`awk -F' ' '{print $2}' $PID_FILE`

#if [ -z $PID ]; then
#        echo ""
#        echo "[ Error ] ###################################################################"
#        echo " Tomcat is Down, Please Tomcat running"
#        echo " ###########################################################################"
#        echo ""
#        exit
#else
#        echo ""
#        echo "###################################################################"
#        echo " jstat -gc / jstat -gcccapacity running"
#        echo " You can find log file in 'RESULT' directry"
#        echo " Ex) TIMESTAMS_GC.log file / TIMESTAMS_GCAP.log file"
#        echo " If you want termination this script, you push 'Ctrl+Z'"
#        echo "###################################################################"
#        echo ""
#fi

SLEEP_TIME=$2
CNT=0

while [ true ]
do
        #2) For tomcata Thread
        CNT=`expr $CNT + 1`

        # Start / End time during aging hours Check Logic
        NOW_TIME=`date '+%Y%m%d %H:%M:%S'`

        if [ $CNT -gt $AGING_COUNT ]; then
                END_TIME=`date '+%Y%m%d%H%M%S'`
#                echo "########################################################"
#                echo " Working Complete for Aging Hour [$AGING_COUNT]"
#                echo " START : $START_TIME ~ END : $END_TIME"
#                echo "########################################################"
                exit
        fi

        #3) For Tomcat Check (GC / Thread / FD)
        echo "--------------------------------------------------------------------------------" >> $GC_RESULT_FILE
#        echo "[${NOW_TIME}]" >> $GC_RESULT_FILE
        $JSTAT -gc -t $PID  >> $GC_RESULT_FILE
	
        echo "--------------------------------------------------------------------------------" >> $GCAP_RESULT_FILE
        echo "[${NOW_TIME}]" >> $GCAP_RESULT_FILE
        $JSTAT -gccapacity -t $PID  >> $GCAP_RESULT_FILE

	#echo "[ $CNT / $AGING_COUNT ] --------------------------------------------------------------------------------------------------------"
	#$JSTAT -gc -t $PID
        #$JSTAT -gccapacity -t $PID

        sleep $SLEEP_TIME
done
