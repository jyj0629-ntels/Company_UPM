#/bin/sh
esql="$MYSQL_HOME/bin/mysql -uzone_ems -pskt?321? upm_ems_revision -h 50.10.23.170"

if [ $# != 2 ]; then
        echo "----------------------------------------------------------------------"
        echo "[ERROR] You must input more value!!! "
        echo "   Ex) result_report.sh START_DATE     END_DATE"
        echo "       result_report.sh 20180311033000 20180312010000"
        echo "----------------------------------------------------------------------"
        exit;
fi

echo " "
echo " "

# DATE Input Format Remake
START_DATE=$1
END_DATE=$2
START_DATE1=${START_DATE:0:4}"-"${START_DATE:4:2}"-"${START_DATE:6:2}" "${START_DATE:8:2}":"${START_DATE:10:2}":"${START_DATE:12:2}
END_DATE1=${END_DATE:0:4}"-"${END_DATE:4:2}"-"${END_DATE:6:2}" "${END_DATE:8:2}":"${END_DATE:10:2}":"${END_DATE:12:2}

if [ ${#START_DATE} != 14 ]; then
        echo "----------------------------------------------------------------------"
        echo "[ERROR] START_DATE Parameter must be 14 length!!! "
        echo "----------------------------------------------------------------------"
        exit;
fi

if [ ${#END_DATE} != 14 ]; then
        echo "----------------------------------------------------------------------"
        echo "[ERROR] END_DATE Parameter must be 14 length!!! "
        echo "----------------------------------------------------------------------"
        exit;
fi

echo "***************************************************************************************************"
echo "** [ INFO ] ***************************************************************************************"
echo " START_DATE  : $START_DATE"
echo " END_DATE    : $END_DATE"
echo "***************************************************************************************************"
echo "***************************************************************************************************"
echo "####################################################################################################"
echo "## 1) NRF API Request Statistics (EMS DB)"
$esql << EOF
SELECT SUM(NRF_REG_COUNT) , SUM(NRF_STOP_COUNT) FROM T_EMS_PM_PG_NRF_STATISTICS 
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE';
EOF

echo "####################################################################################################"
echo "## 2-1) Zone Noti. Input/Out Statistics (List) - Traffic Count (EMS DB)"
$esql << EOF
SELECT SYSTEM_ID, MSG_TYPE, TOT_RECV_COUNT, SUCC_RECV_COUNT, FAIL_RECV_COUNT, REG_DATETIME
FROM T_EMS_PM_PG_NOTI_STATISTICS
WHERE reg_datetime BETWEEN "$START_DATE" AND "$END_DATE"
ORDER BY SYSTEM_ID ASC, REG_DATETIME ASC;
EOF

echo "####################################################################################################"
echo "## 2-2) Zone Noti. Input/Out Statistics (Total) - Traffic Count (EMS DB)"
$esql << EOF
SELECT SYSTEM_ID, SUM(TOT_RECV_COUNT), SUM(SUCC_RECV_COUNT), SUM(FAIL_RECV_COUNT)
FROM T_EMS_PM_PG_NOTI_STATISTICS 
WHERE reg_datetime BETWEEN "$START_DATE" AND "$END_DATE"
GROUP BY SYSTEM_ID;
EOF


echo "####################################################################################################"
echo "## 3) PG Input Statistics - MSG_TYPE (EMS DB)"
$esql << EOF
SELECT SYSTEM_ID, MSG_TYPE, SUM(TOT_RECV_COUNT) , SUM(SUCC_RECV_COUNT) , SUM(FAIL_RECV_COUNT)
FROM T_EMS_PM_PG_NOTI_STATISTICS
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY SYSTEM_ID, MSG_TYPE;
EOF

echo "###################################################################################################"
echo "## 4) Push Result Statistics (EMS DB)"
$esql << EOF
SELECT result_code, SUM(result_count) FROM T_EMS_PM_PUSH_RESULT_STATISTICS
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY result_code;
EOF

echo "###################################################################################################"
echo "## 5) API Request Detection - APP API Statistics "
$esql << EOF
SELECT REG_DATETIME, REQ_URL, SUM(result_count) FROM T_EMS_PM_APP_API_STATISTICS
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY STATISTICS_ID, REQ_URL;
EOF

echo "###################################################################################################"
echo "## 6) API Request Detection - APP API Statistics "
$esql << EOF
SELECT result_code , SUM(result_count) FROM T_EMS_PM_APP_API_STATISTICS
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY result_code;
EOF

echo "###################################################################################################"
echo "## 7) API Request Detection - PG API REQUEST Statistics "
$esql << EOF
SELECT result_code , SUM(result_count) FROM T_EMS_PM_PG_API_STATISTICS
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY result_code;
EOF

echo "###################################################################################################"
#echo "## 8) STFile Count Checking "
#echo "## 8-1) API ST File Count "
#cat /APPDATA/upm_file/T_PM_API* | grep 2020 | wc -l 
#echo "## 8-2) Push ST File Count "
#cat /APPDATA/upm_file/T_PG* | grep 2020 | wc -l

echo ""
echo "***************************************************************************************************"
echo "************************************ [ Process Complete ] *****************************************"
echo "***************************************************************************************************"
