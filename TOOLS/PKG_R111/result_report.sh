#/bin/sh
if [ $# != 2 ]; then
        echo "----------------------------------------------------------------------" 
        echo "[ERROR] You must input more value!!! " 
        echo "   Ex) result_report.sh START_DATE     END_DATE"
        echo "       result_report.sh 20180311033000 20170312010000"
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

echo "DEBUG] ##############################################################" 
echo " START_DATE  : $START_DATE" 
echo " START_DATE1 : $START_DATE1" 
echo " END_DATE    : $END_DATE" 
echo " END_DATE1   : $END_DATE1" 
echo "#####################################################################"
echo " "
echo " "

echo "####################################################################################################"
echo "## 1) ODA Input Statistics (EMS DB)"
$MYSQL_HOME/bin/mysql -uupm_ems -pupm?4321? upm_ems -h 127.0.0.1 << EOF
select sum(radius_lte_count), sum(radius_wcdma_count) from t_ems_lm_statistics
where CREATE_DATE between '$START_DATE' and '$END_DATE';
EOF

echo "###################################################################################################"
echo "## 2) Push Result Statistics (EMS DB)"
$MYSQL_HOME/bin/mysql -uupm_ems -pupm?4321? upm_ems -h 127.0.0.1 << EOF
select result_code, sum(result_count) from t_ems_pm_push_result_statistics 
where reg_datetime between '$START_DATE1' and '$END_DATE1'
group by result_code;
EOF

echo "###################################################################################################"
echo "## 3) ODA Input - T_PM_LM_IF (PM DB)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
select sum(cnt) from (
select count(*) as cnt from t_pm_lm_if_00 union all
select count(*) as cnt from t_pm_lm_if_01 union all
select count(*) as cnt  from t_pm_lm_if_02 union all
select count(*) as cnt  from t_pm_lm_if_03 union all
select count(*) as cnt  from t_pm_lm_if_04 union all
select count(*) as cnt  from t_pm_lm_if_05 union all
select count(*) as cnt  from t_pm_lm_if_06 union all
select count(*) as cnt  from t_pm_lm_if_07 union all
select count(*) as cnt  from t_pm_lm_if_08 union all
select count(*) as cnt  from t_pm_lm_if_09 
) a;
EOF

echo "###################################################################################################"
echo "## 4) PUSH Result - T_PM_PUSH_DEAL (PM DB)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
select sum(cnt) from (
select count(*) as cnt from t_pm_lm_if_00 where DUP_YN = 'N' union all
select count(*) as cnt from t_pm_lm_if_01 where DUP_YN = 'N' union all
select count(*) as cnt  from t_pm_lm_if_02 where DUP_YN = 'N' union all
select count(*) as cnt  from t_pm_lm_if_03 where DUP_YN = 'N' union all
select count(*) as cnt  from t_pm_lm_if_04 where DUP_YN = 'N' union all
select count(*) as cnt  from t_pm_lm_if_05 where DUP_YN = 'N' union all
select count(*) as cnt  from t_pm_lm_if_06 where DUP_YN = 'N' union all
select count(*) as cnt  from t_pm_lm_if_07 where DUP_YN = 'N' union all
select count(*) as cnt  from t_pm_lm_if_08 where DUP_YN = 'N' union all
select count(*) as cnt  from t_pm_lm_if_09 where DUP_YN = 'N' 
 ) a; 
EOF

echo "###################################################################################################"
echo "## 5) ZONE_VOC FILE"
/APPDATA/PM/SIM/PERM/TOOLS/zone_voc_count.sh

echo "###################################################################################################"
echo "## 6) ZONE_VOC ZONE INF Result - T_PM_PUSH_DEAL (PM DB)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
select count(*) from t_pm_push_deal where zone_in_out ='I';
EOF


echo "###################################################################################################"
echo "## 7) ZONE_VOC ZONE INF Result - T_PM_PUSH_DEAL (PM DB)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
select result_code, count(*) from t_pm_push_deal group by result_code order by result_code asc;
EOF

echo "###################################################################################################"
echo "## 8) RE-SEND Packet Detection - T_PM_PUSH_DEAL_RETRY (PM DB)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
select count(*) from t_pm_push_deal_retry;
EOF

echo "###################################################################################################"
echo "## 9) API Request Detection - T_PM_API_REQUEST_LOG (PM DB)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
select count(*) from t_pm_api_request_log;
EOF


echo ""
echo ""
echo "##################################### [ Process Complete ] #########################################"
