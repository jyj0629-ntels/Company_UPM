#/bin/sh
RESULT_DATE=`date '+%Y%m%d%H%M%S'`
WAS_RUNNING_REPORT_FILE="./RESULT/${RESULT_DATE}_WAS_STOP_RUN_REPORT.log"

if [ ! -d "RESULT" ]; then
        mkdir RESULT
fi

# random seed
RANDOM=`date "+%N"`

function randomSecond {
	min_val=$1
	max_val=$2
	mod_val=`echo "$max_val - $min_val + 1" | bc`
	random_val=`echo "($RANDOM % $mod_val) + $min_val" | bc`

	echo "$random_val"
}

while [ true ]
do 
RUNNING_TIME=$(randomSecond "300" "600")
WAITTIME=$(randomSecond "30" "50")
echo "#####################################################################################" | tee -a $WAS_RUNNING_REPORT_FILE
echo ">> Running wait time : ${RUNNING_TIME} [sec] / After wait time : ${WAITTIME} [sec] "   | tee -a $WAS_RUNNING_REPORT_FILE
echo "#####################################################################################" | tee -a $WAS_RUNNING_REPORT_FILE

echo "*************************************************************************************" | tee -a $WAS_RUNNING_REPORT_FILE
/pm/app/odapm/bin/shutdown_odapm.sh 							     | tee -a $WAS_RUNNING_REPORT_FILE
sleep $WAITTIME

echo "-------------------------------------------------------------------------------------" | tee -a $WAS_RUNNING_REPORT_FILE
echo ">> Starting WAS!!!"								     | tee -a $WAS_RUNNING_REPORT_FILE
/pm/app/odapm/bin/startup_odapm.sh                                                           | tee -a $WAS_RUNNING_REPORT_FILE
sleep $RUNNING_TIME

pid=`ps -ef | grep tomcat | grep odapm | grep -v 'grep' | awk '{print $2}'`

if [ -z $pid ]; then
echo ">> ERROR) TOMCAT is not Running!! One more Startup tomcat!!! "			     | tee -a $WAS_RUNNING_REPORT_FILE
/pm/app/odapm/bin/shutdown_odapm.sh 							     | tee -a $WAS_RUNNING_REPORT_FILE
fi

echo "-------------------------------------------------------------------------------------" | tee -a $WAS_RUNNING_REPORT_FILE
echo " One turn Completed!!!!!"								     | tee -a $WAS_RUNNING_REPORT_FILE
echo "*************************************************************************************" | tee -a $WAS_RUNNING_REPORT_FILE
done
