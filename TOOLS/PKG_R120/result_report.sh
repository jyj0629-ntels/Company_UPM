#/bin/sh
esql="$MYSQL_HOME/bin/mysql -uupm_ems -pupm?4321? upm_ems -h 127.0.0.1"

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
SELECT SUM(NRF_REG_COUNT) , SUM(NRF_STOP_COUNT) FROM t_ems_pm_pg_nrf_statistics
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE';
EOF

echo "####################################################################################################"
echo "## 2-1) Zone Noti. Input/Out Statistics (List) - Traffic Count (EMS DB)"
$esql << EOF
SELECT SYSTEM_ID, MSG_TYPE, TOT_RECV_COUNT, SUCC_RECV_COUNT, FAIL_RECV_COUNT, REG_DATETIME
FROM t_ems_pm_pg_noti_statistics
WHERE reg_datetime BETWEEN "$START_DATE" AND "$END_DATE"
ORDER BY SYSTEM_ID ASC, REG_DATETIME ASC;
EOF

echo "####################################################################################################"
echo "## 2-2) Zone Noti. Input/Out Statistics (Total) - Traffic Count (EMS DB)"
$esql << EOF
SELECT SYSTEM_ID, SUM(TOT_RECV_COUNT), SUM(SUCC_RECV_COUNT), SUM(FAIL_RECV_COUNT)
FROM t_ems_pm_pg_noti_statistics
WHERE reg_datetime BETWEEN "$START_DATE" AND "$END_DATE"
GROUP BY SYSTEM_ID;
EOF


echo "####################################################################################################"
echo "## 3) PG Input Statistics - MSG_TYPE (EMS DB)"
$esql << EOF
SELECT SYSTEM_ID, MSG_TYPE, SUM(TOT_RECV_COUNT) , SUM(SUCC_RECV_COUNT) , SUM(FAIL_RECV_COUNT)
FROM t_ems_pm_pg_noti_statistics
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY SYSTEM_ID, MSG_TYPE;
EOF

echo "###################################################################################################"
echo "## 4) Push Result Statistics (EMS DB)"
$esql << EOF
SELECT result_code, SUM(result_count) FROM t_ems_pm_push_result_statistics
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY result_code;
EOF

echo "###################################################################################################"
echo "## 5) API Request Detection - APP API Statistics "
$esql << EOF
SELECT result_code , SUM(result_count) FROM t_ems_pm_app_api_statistics
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY result_code;
EOF


echo "###################################################################################################"
echo "## 6) API Request Detection - PG API REQUEST Statistics "
$esql << EOF
SELECT result_code , SUM(result_count) FROM t_ems_pm_pg_api_statistics
WHERE reg_datetime BETWEEN '$START_DATE' AND '$END_DATE'
GROUP BY result_code;
EOF

echo ""
echo "***************************************************************************************************"
echo "************************************ [ Process Complete ] *****************************************"
echo "***************************************************************************************************"

