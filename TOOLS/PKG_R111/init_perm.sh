#/bin/sh
#1) tomcat down & log delete
echo "###########################################"
echo "## 1) Tomcat Stop & Log Delete"
/pm/app/odapm/bin/shutdown_odapm.sh
curl -k "http://127.0.0.1/ems/stopTomcat"
sleep 10
rm -rf /pm/app/odapm/logs/*.log
rm -rf /pm/app/odapm/logs/*.txt
rm -rf /pm/app/odapm/logs/*.out
rm -rf /APPDATA/PM/ZONE_VOC/*
rm -rf /APPDATA/PM/PCIS/*
rm -rf /APPDATA/PM/LM_STAT/*
 
#2) process down & log delete
echo ""
echo "## 2) Process Down - ncn, zone, pfm"
stopMP ncn
sleep 1
stopMP zone
sleep 1
stopMP pfm
# ZONE LOG Delete
rm -rf /APPDATA/PM/LOG/*2017*
rm -rf /APPDATA/PM/LOG/TR/*
# NCN LOG Delete
rm -rf /APPDATA/NCN/LOG/*2017*
 
 
#3) MySQL data delete & stop, start
echo ""
echo "## 3-1) MySQL Zone Service Data Delete (t_pm_lm_if, t_pm_push_deal, t_pm_push_deal_status, t_um_oda_radius_01~04)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
truncate t_pm_lm_if;
truncate t_pm_lm_zero_alarm;
truncate t_pm_push_deal;
truncate t_pm_push_deal_status;
truncate t_pm_api_request_log;
truncate t_um_oda_radius_01;
truncate t_um_oda_radius_02;
truncate t_um_oda_radius_03;
truncate t_um_oda_radius_04;
EOF
echo ""
echo "## 3-2) MySQL Zone Service Performance Test Data Delete (t_pm_lm_if_00 ~ 09, t_pm_push_deal_00 ~ 09)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
truncate t_pm_lm_if_00;
truncate t_pm_lm_if_01;
truncate t_pm_lm_if_02;
truncate t_pm_lm_if_03;
truncate t_pm_lm_if_04;
truncate t_pm_lm_if_05;
truncate t_pm_lm_if_06;
truncate t_pm_lm_if_07;
truncate t_pm_lm_if_08;
truncate t_pm_lm_if_09;
truncate t_pm_push_deal;
truncate t_pm_push_deal_retry;
truncate t_pm_push_deal_hist;
truncate t_um_push_deal_status;
truncate t_pm_noti_push_deal;
truncate t_pm_api_request_log;
truncate t_pm_lm_zero_alarm;
EOF
 
echo "## 3-3) MySQL NCN Service Data Delete (t_push_aom_hist_00 ~ 09,  t_pg_if_hist)"
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? ncn << EOF
truncate t_push_aom_hist_00;
truncate t_push_aom_hist_01;
truncate t_push_aom_hist_02;
truncate t_push_aom_hist_03;
truncate t_push_aom_hist_04;
truncate t_push_aom_hist_05;
truncate t_push_aom_hist_06;
truncate t_push_aom_hist_07;
truncate t_push_aom_hist_08;
truncate t_push_aom_hist_09;
truncate t_pg_if_hist;
EOF
 
echo ""
echo "## 4) MySQL Restart, Please Input root password" 
su - root -c "/etc/init.d/mysqld stop;/etc/init.d/mysqld start"
sleep 20
#4) tomcat start
echo ""
echo "## 5) Tomcat start" 
/pm/app/odapm/bin/startup_odapm.sh
sleep 10
 
#5) process start
echo ""
echo "## 6) Process Start (pfm -> zone -> ncn)" 
startMP pfm
sleep 20
startMP zone
sleep 20
startMP fi
startMP nc
startMP ai
startMP ti
startMP ncn_pi
sleep 10
startMP ncn_hm
disMP all
exit
