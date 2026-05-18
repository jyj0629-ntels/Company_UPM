#/bin/sh
pmsql="$MYSQL_HOME/bin/mysql -uupm -pupm?4321? pm -h 127.0.0.1" 
SYNC_PATH='/pm/app/odapm/webapp/upm_file/upm_sync_data'

while true; do
NOWTIME=`date`
echo "####################################################################################"
echo " [$NOWTIME]"
DIR_DATE=$(date +"%Y%m%d")
echo "####################################################################################"
echo $SYNC_PATH/$DIR_DATE
echo "************************************************************************************"
echo " [SYNC FILE List]"
ls -al "$SYNC_PATH/$DIR_DATE"
ls -al "$SYNC_PATH/$DIR_DATE" | wc -l
echo "************************************************************************************"
echo " SLEEP 60 sec"
sleep 60

done