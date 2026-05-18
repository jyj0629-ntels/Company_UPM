#/bin/sh
#1) Enviroment Value
RESULT_DATE=`date '+%Y%m%d%H%M%S'`;
APP_LIST="CCMain|STMain|HMMain"
JSTAT="/pm/java/jdk1.8.0_151/bin/jstat"

if [ ! -d "RESULT" ]; then
        mkdir RESULT
fi

HTWAS_PID_FILE="./RESULT/${RESULT_DATE}_HTWAS_PID.log"
HTWAS_GC_RESULT_FILE="./RESULT/${RESULT_DATE}_HTWAS_GC.log"
HTWAS_GC_PERCENT_FILE="./RESULT/${RESULT_DATE}_HTWAS_GC_PERCENT.log"
HTWAS_GCAP_RESULT_FILE="./RESULT/${RESULT_DATE}_HTWAS_GCAP.log"
HTWAS_TOMCAT_THREAD_FD_FILE="./RESULT/${RESULT_DATE}_HTWAS_TOMCAT_THREAD_FD.log"

MWAS_PID_FILE="./RESULT/${RESULT_DATE}_MWAS_PID.log"
MWAS_GC_RESULT_FILE="./RESULT/${RESULT_DATE}_MWAS_GC.log"
MWAS_GC_PERCENT_FILE="./RESULT/${RESULT_DATE}_MWAS_GC_PERCENT.log"
MWAS_GCAP_RESULT_FILE="./RESULT/${RESULT_DATE}_MWAS_GCAP.log"
MWAS_TOMCAT_THREAD_FD_FILE="./RESULT/${RESULT_DATE}_MWAS_TOMCAT_THREAD_FD.log"

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

ps -ef | grep tomcat | grep java | grep odapm > $HTWAS_PID_FILE
HTWAS_PID=`awk -F' ' '{print $2}' $HTWAS_PID_FILE`
ps -ef | grep tomcat | grep java | grep mdms > $MWAS_PID_FILE
MWAS_PID=`awk -F' ' '{print $2}' $MWAS_PID_FILE`

if [ -z $HTWAS_PID ] && [ -z $MWAS_PID ]; then
        echo ""
        echo " Error ] ###################################################################"
        echo " HTWAS and MWAS Tomcat are Down, Please Tomcat running"
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


if [ -z $HTWAS_PID ]; then
	echo ">>> BTWAS IS DOWN! Not operation >>"
else
	HTWAS_START_THREAD_COUNT=`ps -eLf | grep java | grep odapm | wc -l`
	HTWAS_START_FD_COUNT=`ls -l /proc/${HTWAS_PID}/fd | wc -l`
	HTWAS_START_MYSQL_FD_COUNT=`lsof -p ${HTWAS_PID} | grep mysql | wc -l`
fi

if [ -z $MWAS_PID ]; then
	echo ">>> MWAS IS DOWN! Not operation >>"
else 
	MWAS_START_THREAD_COUNT=`ps -eLf | grep java | grep mdms | wc -l`
	MWAS_START_FD_COUNT=`ls -l /proc/${MWAS_PID}/fd | wc -l`
	MWAS_START_MYSQL_FD_COUNT=`lsof -p ${MWAS_PID} | grep mysql | wc -l`
fi

START_MYSQL_COUNT=`netstat -n |grep 3306|grep ESTABLISHED | wc -l`

while [ true ]
do
        # Start / End time during aging hours Check Logic
        NOW_TIME=`date '+%Y%m%d %H:%M:%S'`
        LIMITED_DATE=`date +%Y%m%d%H%M%S -d -${AGING_TIME}hours`

        if [ $LIMITED_DATE -gt $START_TIME ]; then
                END_TIME=`date '+%Y%m%d%H%M%S'`
                echo "########################################################"
                echo " Working Complete for Aging Hour [$AGING_TIME hours]"
                echo " START : $START_TIME ~ END : $END_TIME"
                echo "########################################################"
                exit
        fi

        #2) For tomcata Thread
        CNT=`expr $CNT + 1`
        SEC=`expr $CNT \* $SLEEP_TIME`
        NOW_MYSQL_COUNT=`netstat -n |grep 3306|grep ESTABLISHED | wc -l`

	if [ -z $HTWAS_PID ]; then
		echo ">>> BTWAS IS DOWN! Not operation >>" 
	else
        	HTWAS_NOW_THREAD=`ps -eLf | grep java | grep odapm |  wc -l`
        	HTWAS_NOW_FD=`ls -l /proc/${HTWAS_PID}/fd | wc -l`
        	HTWAS_NOW_MYSQL_FD_COUNT=`lsof -p ${HTWAS_PID} | grep mysql | wc -l`

        	#3) For Tomcat Check (GC / Thread / FD)
        	echo "--------------------------------------------------------------------------------" >> $HTWAS_GC_RESULT_FILE
        	echo "[${NOW_TIME}]" >> $HTWAS_GC_RESULT_FILE
        	$JSTAT -gc -t $HTWAS_PID  >> $HTWAS_GC_RESULT_FILE
        	echo "--------------------------------------------------------------------------------" >> $HTWAS_GC_PERCENT_FILE
        	echo "[${NOW_TIME}]"     >> $HTWAS_GC_PERCENT_FILE 
		$JSTAT -gcutil -t $HTWAS_PID   >> $HTWAS_GC_PERCENT_FILE
        	echo "--------------------------------------------------------------------------------" >> $HTWAS_GCAP_RESULT_FILE
        	echo "[${NOW_TIME}]" >> $HTWAS_GCAP_RESULT_FILE
        	$JSTAT -gccapacity -t $HTWAS_PID  >> $HTWAS_GCAP_RESULT_FILE
        	echo "--------------------------------------------------------------------------------" >> $HTWAS_TOMCAT_THREAD_FD_FILE
        	echo "[${NOW_TIME}]" >> $HTWAS_TOMCAT_THREAD_FD_FILE
        	echo "($CNT) $SEC second ]" >> $HTWAS_TOMCAT_THREAD_FD_FILE
        	echo "  1) Tomcat Thread Count - START : ${HTWAS_START_THREAD_COUNT} / NOW : ${HTWAS_NOW_THREAD}"  >> $HTWAS_TOMCAT_THREAD_FD_FILE
        	echo "  2) Tomcat FD - START : ${HTWAS_START_FD_COUNT} / NOW : ${HTWAS_NOW_FD}"  >> $HTWAS_TOMCAT_THREAD_FD_FILE
        	echo "  3) MySQL connection Count : ${START_MYSQL_COUNT} - BTWAS, MWAS is same : ${NOW_MYSQL_COUNT}" >> $HTWAS_TOMCAT_THREAD_FD_FILE
        	echo "  4) MySQL FD Count : ${HTWAS_START_MYSQL_FD_COUNT} : ${HTWAS_NOW_MYSQL_FD_COUNT}" >> $HTWAS_TOMCAT_THREAD_FD_FILE
        	echo "Information) Gathering Start HTWAS Tomcat Thread : ${HTWAS_START_THREAD_COUNT} / Now Tomcat Thread : ${HTWAS_NOW_THREAD} - FD : ${HTWAS_START_FD_COUNT} / Now FD : ${HTWAS_NOW_FD} / MYSQL_CONNECTION : ${START_MYSQL_COUNT} : ${NOW_MYSQL_COUNT} / MYSQL_FD_CONN : ${HTWAS_START_MYSQL_FD_COUNT} : ${HTWAS_NOW_MYSQL_FD_COUNT}"

	fi

	if [ -z $MWAS_PID ]; then
		echo ">>> MWAS IS DOWN! Not operation >>"
	else 
        	MWAS_NOW_THREAD=`ps -eLf | grep java | grep mdms |  wc -l`
        	MWAS_NOW_FD=`ls -l /proc/${MWAS_PID}/fd | wc -l`
        	MWAS_NOW_MYSQL_FD_COUNT=`lsof -p ${MWAS_PID} | grep mysql | wc -l`

        	#3) For Tomcat Check (GC / Thread / FD)
        	echo "--------------------------------------------------------------------------------" >> $MWAS_GC_RESULT_FILE
        	echo "[${NOW_TIME}]" >> $MWAS_GC_RESULT_FILE
        	$JSTAT -gc -t $MWAS_PID  >> $MWAS_GC_RESULT_FILE
        	echo "--------------------------------------------------------------------------------" >> $MWAS_GC_PERCENT_FILE
        	echo "[${NOW_TIME}]"     >> $MWAS_GC_PERCENT_FILE 
		$JSTAT -gcutil -t $MWAS_PID   >> $MWAS_GC_PERCENT_FILE
        	echo "--------------------------------------------------------------------------------" >> $MWAS_GCAP_RESULT_FILE
        	echo "[${NOW_TIME}]" >> $MWAS_GCAP_RESULT_FILE
        	$JSTAT -gccapacity -t $MWAS_PID  >> $MWAS_GCAP_RESULT_FILE
        	echo "--------------------------------------------------------------------------------" >> $MWAS_TOMCAT_THREAD_FD_FILE
        	echo "[${NOW_TIME}]" >> $MWAS_TOMCAT_THREAD_FD_FILE
        	echo "($CNT) $SEC second ]" >> $MWAS_TOMCAT_THREAD_FD_FILE
        	echo "  1) Tomcat Thread Count - START : ${MWAS_START_THREAD_COUNT} / NOW : ${MWAS_NOW_THREAD}"  >> $MWAS_TOMCAT_THREAD_FD_FILE
        	echo "  2) Tomcat FD - START : ${MWAS_START_FD_COUNT} / NOW : ${MWAS_NOW_FD}"  >> $MWAS_TOMCAT_THREAD_FD_FILE
        	echo "  3) MySQL connection Count : ${START_MYSQL_COUNT} - BTWAS, MWAS is same : ${NOW_MYSQL_COUNT}" >> $MWAS_TOMCAT_THREAD_FD_FILE
        	echo "  4) MySQL FD Count : ${MWAS_START_MYSQL_FD_COUNT} : ${MWAS_NOW_MYSQL_FD_COUNT}" >> $MWAS_TOMCAT_THREAD_FD_FILE
        	echo "Information) Gathering Start MWAS Tomcat Thread : ${MWAS_START_THREAD_COUNT} / Now Tomcat Thread : ${MWAS_NOW_THREAD} - FD : ${MWAS_START_FD_COUNT} / Now FD : ${MWAS_NOW_FD} / MYSQL_CONNECTION : ${START_MYSQL_COUNT} : ${NOW_MYSQL_COUNT} / MYSQL_FD_CONN : ${MWAS_START_MYSQL_FD_COUNT} : ${MWAS_NOW_MYSQL_FD_COUNT}"
	fi

        #4) For Resource check
        sar -r 1 1 | sed -n '4p' >> $MEM_RESULT_FILE
        sar 1 1 | sed -n '4p'  >> $CPU_RESULT_FILE


        #5) For Application memory leack check
        echo "-------------------------------------------------------------------------" >> $APP_RESULT_FILE
        date >> $APP_RESULT_FILE
        ps -eo pcpu,pmem,comm,pid | grep -E ${APP_LIST} >> $APP_RESULT_FILE

        sleep $SLEEP_TIME
done
