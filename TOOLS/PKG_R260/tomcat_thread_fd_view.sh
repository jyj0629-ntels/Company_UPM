#/bin/sh
pid=`ps -ef | grep tomcat | grep $USER | grep -v 'grep' | awk '{print $2}'`

if [ -z $1 ];then
        echo "####################################################"
        echo "ERROR) Please Input Parameter sleep time (second)"
        echo "      ./tomcat_thread_fd_view.sh 10 "
        echo "####################################################"
        exit
fi

SLEEP_TIME=$1
CNT=0
START_TIME=`date`
START_THREAD=`ps -eLf | grep java | wc -l`
START_FD=`ls -l /proc/${pid}/fd | wc -l`

echo "######################################################################"
echo "  Start Time : $START_TIME"
echo "  START Tomcat thread count: $START_THREAD"
echo "  START Tomcat FD count    : $START_FD"
echo "######################################################################"

while [ true ]
do
CNT=`expr $CNT + 1`
SEC=`expr $CNT \* $SLEEP_TIME`

NOW_THREAD=`ps -eLf | grep java | wc -l`
NOW_FD=`ls -l /proc/${pid}/fd | wc -l`

echo "($CNT) $SEC second (Start time - $START_TIME) *********************************** "
echo "  1) Tomcat Thread Count         - START : ${START_THREAD} / NOW : ${NOW_THREAD} "
echo "  2) Tomcat FD(File Description) - START : ${START_FD} / NOW : ${NOW_FD}"
echo ""
sleep $SLEEP_TIME
done
