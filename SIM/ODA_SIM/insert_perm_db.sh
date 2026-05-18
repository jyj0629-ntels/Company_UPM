#/bin/bash
START_NUM=1010000001
#END_NUM=1010000011
#HELP : insert subscriber number ex) 3,500,000 subscriber --> 1013500000
END_NUM=1013500001
 
echo "#####################################################################################"
echo " Starting for Test, Start MDN : 0${START_NUM} ~ End MDN : 0${END_NUM}      "
echo " Insert DB Data About t_pm_lm_if"
echo "#####################################################################################"
sleep 1
START_TIME=`date '+%C%y%m%d %H:%M:%S'`
#IF_ID=`date '+%C%y%m%d'`
#IF_ID=${IF_ID}'00000000'
IF_ID=`$MYSQL_HOME/bin/mysql -h127.0.0.1 -sN -uupm -pupm?4321? -e "SELECT IFNULL(MAX(IF_ID), CONCAT(DATE_FORMAT(NOW(), '%Y%m%d'), '00000000')) AS IF_ID FROM pm.T_PM_LM_IF WHERE IF_ID > CONCAT( DATE_FORMAT(NOW(), '%Y%m%d'), '00000000')"`

for ((i=$START_NUM;i<$END_NUM;i++)); do
MDN="0${i}"
IF_ID=`expr $IF_ID + 1`
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
INSERT INTO t_pm_lm_if VALUES ('LI01','${IF_ID}',DATE_FORMAT(NOW(),'%Y%m%d'),DATE_FORMAT(NOW(), '%H%i%s'),'LM10','${MDN}','  ','10000001','SUBWAYFREE','I','A','172.28.87.92','L','3', '', '   22603:3','   LM02',1,'1464852244.194245000','10.242.128.221','SC0000',NOW());
COMMIT;
EOF
 
echo "[${MDN} Subscriber inserted!!!]"
done
 
END_TIME=`date '+%C%y%m%d %H:%M:%S'`
echo "#####################################################################################"
echo " Compelte!! TIME : ${START_TIME}[S] ~ ${END_TIME}[E]      "
echo "#####################################################################################"
