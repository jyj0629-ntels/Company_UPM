#/bin/sh

if [ -z $1 ];then
	echo "####################################################"
	echo "ERROR) Please Input Parameter sleep time (second)"
	echo "      ./java_thread_view.sh 10 "
	echo "####################################################"
	exit
fi

SLEEP_TIME=$1
CNT=0
START_THREAD_COUNT=`ps -eLf | grep java | wc -l`

echo "******************************************"
echo "START Tomcat thread count: $START_THREAD_COUNT"
echo "******************************************"

while [ true ]
do
CNT=`expr $CNT + 1`
SEC=`expr $CNT \* $SLEEP_TIME`

NOW_THREAD=`ps -eLf | grep java | wc -l`

echo "($CNT) $SEC second ] Java Thread Count - START : ${START_THREAD_COUNT} / NOW : ${NOW_THREAD} "
sleep $SLEEP_TIME
done
