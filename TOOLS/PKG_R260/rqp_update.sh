#/bin/sh
pmsql1="$MYSQL_HOME/bin/mysql -uupm -pupm?4321? pm -h 50.10.23.128"
pmsql2="$MYSQL_HOME/bin/mysql -uupm -pupm?4321? pm -h 50.10.23.129"

while true; do
NOWTIME=`date`
echo "####################################################################################"
echo " [$NOWTIME]"

$pmsql1 << EOF
UPDATE t_barod_rqp_hist set req_date = '20240411140633' where req_date <> '20240411140633';
EOF
echo " ----- T_BAROD_RQP_HIST Table REQ_DATE update finished"

echo "[ Active ]*******************************************************"
$pmsql1 << EOF
SELECT count(*) AS HFC_SUBSCRIBER_TOTAL_COUNT from t_barod_sub_list;
EOF

echo "[ Standby ]******************************************************"
$pmsql2 << EOF
SELECT count(*) AS HFC_SUBSCRIBER_TOTAL_COUNT from t_barod_sub_list;
EOF

echo " ----- HFC SUBSCRIBER finished -------"
echo " SLEEP 60 sec"
sleep 60

done
