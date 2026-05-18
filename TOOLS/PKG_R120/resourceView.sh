#/bin/sh
#1) Enviroment Value
RESULT_DATE=`date '+%Y%m%d%H%M%S'`;
APP_LIST="CCMain|STMain|HMMain"
JSTAT="/pm/java/jdk1.8.0_151/bin/jstat"

if [ ! -d "RESULT" ]; then
        mkdir RESULT
fi

PID_FILE="./RESULT/${RESULT_DATE}_PID.log"
GC_RESULT_FILE="./RESULT/${RESULT_DATE}_GC.log"
GCAP_RESULT_FILE="./RESULT/${RESULT_DATE}_GCAP.log"
TOMCAT_THREAD_FD_FILE="./RESULT/${RESULT_DATE}_TOMCAT_THREAD_FD.log"
MEM_RESULT_FILE="./RESULT/${RESULT_DATE}_MEM.log"
CPU_RESULT_FILE="./RESULT/${RESULT_DATE}_CPU.log"
APP_RESULT_FILE="./RESULT/${RESULT_DATE}_APP.log"

#2) TOMCAT PID Get
if [ $# -ne 2 ]; then
        echo "Usage Error] #######################################################"
        echo " - You must input parameter"
        echo "    Ex) ./resourceView.sh agingtime(hour) log_write_time_term(second)"
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

SLEEP_TIME=$2
CNT=0
START_THREAD_COUNT=`ps -eLf | grep java | wc -l`
START_FD_COUNT=`ls -l /proc/${PID}/fd | wc -l`

while [ true ]
do
        #2) For tomcata Thread
        CNT=`expr $CNT + 1`
        SEC=`expr $CNT \* $SLEEP_TIME`
        NOW_THREAD=`ps -eLf | grep java | wc -l`
	NOW_FD=`ls -l /proc/${PID}/fd | wc -l`

        # Start / End time during aging hours Check Logic
        NOW_TIME=`date +%Y%m%d%H%M%S -d -${AGING_TIME}hours`

        if [ $NOW_TIME -gt $START_TIME ]; then
                END_TIME=`date '+%Y%m%d%H%M%S'`
                echo "########################################################"
                echo " Working Complete for Aging Hour [$AGING_TIME hours]"
                echo " START : $START_TIME ~ END : $END_TIME"
                echo "########################################################"
                exit
        fi

        #3) For Tomcat Check (GC / Thread / FD)
        $JSTAT -gc -t $PID  >> $GC_RESULT_FILE
        $JSTAT -gccapacity -t $PID  >> $GCAP_RESULT_FILE
        echo "($CNT) $SEC second ]" >> $TOMCAT_THREAD_FD_FILE
	echo "  1) Tomcat Thread Count - START : ${START_THREAD_COUNT} / NOW : ${NOW_THREAD}"  >> $TOMCAT_THREAD_FD_FILE
        echo "  2) Tomcat FD - START : ${START_FD_COUNT} / NOW : ${NOW_FD}"  >> $TOMCAT_THREAD_FD_FILE

        #4) For Resource check
        sar -r 1 1 | sed -n '4p' >> $MEM_RESULT_FILE
        sar 1 1 | sed -n '4p'  >> $CPU_RESULT_FILE

        #5) For Application memory leack check
        echo "-------------------------------------------------------------------------" >> $APP_RESULT_FILE
        date >> $APP_RESULT_FILE
        ps -eo pcpu,pmem,comm,pid | grep -E ${APP_LIST} >> $APP_RESULT_FILE
        echo "Information) Gathering Start Tomcat Thread : ${START_THREAD_COUNT} / Now Tomcat Thread : ${NOW_THREAD} - FD : ${START_FD_COUNT} / Now FD : ${NOW_FD}"
        sleep $SLEEP_TIME
done
