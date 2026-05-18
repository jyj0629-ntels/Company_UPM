#/bin/bash
#HELP : insert subscriber number ex) 3,500,000 subscriber --> 1013500000
START_NUM=$1
END_NUM=$2

if [ $# -ne 2 ]; then 
        echo " ERROR ] ######################################################################################"
        echo "  Please 2 input parameter "
        echo "      : insert_subscriber.sh START_MDN END_MDN"
        echo "  ex) ./insert_subscriber.sh 10000001  99999999"
        echo " ##############################################################################################"
        exit
fi

echo "#####################################################################################"
echo " Starting for Test, Start MDN : 0${START_NUM} ~ End MDN : 0${END_NUM}      "
echo " Insert DB Data About t_pm_subscriber and t_pm_device_conf"
echo " HELP) This is for B2C, Therefore if you want B2B, You must operate manual type"
echo "#####################################################################################"
sleep 1
START_TIME=`date '+%C%y%m%d %H:%M:%S'` 
 
for ((i=$START_NUM;i<=$END_NUM;i++)); do
MDN="010${i}"
TYPE_DIV=`expr $MDN % 4` 
if [ $TYPE_DIV -eq 0 ]; then
	OS="ANDROID5.1"
	OS_TYPE="A"
elif [ $TYPE_DIV -eq 1 ]; then
	OS="ANDROID5.1"
	OS_TYPE="T"
elif [ $TYPE_DIV -eq 2 ]; then
	OS="IOS6.1"
	OS_TYPE="I"
elif [ $TYPE_DIV -eq 3 ]; then
	OS="IOS6.1"
	OS_TYPE="P"
fi

$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF 
INSERT INTO t_pm_subscriber values('${MDN}','Y','N','Y','N','Y','N','N','N','N','N',DATE_FORMAT(NOW(), '%Y%m%d'),'180256',NOW(),'Y','N');
INSERT INTO t_pm_device_conf VALUES ('${MDN}','B2C', 'Y',NOW(),'${OS_TYPE}','Y', NOW(),'${OS}',NOW(),NULL,NULL,'Y',NOW(),NOW(),NOW(),NULL);
INSERT INTO t_pm_device_conf VALUES ('${MDN}','B2B', 'Y',NOW(),'ANDROID5.1','Y', NOW(),'A',NOW(),NULL,NULL,'Y',NOW(),NOW(),NOW(),NULL);
COMMIT;
EOF
 
echo "[${MDN} / OS Type : ${OS_TYPE} - Subscriber inserted!!!]"
sleep 0.01
done
 
END_TIME=`date '+%C%y%m%d %H:%M:%S'` 
echo "#####################################################################################"
echo " Compelte!! TIME : ${START_TIME}[S] ~ ${END_TIME}[E]      "
echo "#####################################################################################"
