#/bin/sh

if [ $# -lt 1 ]; then
	echo "ERROR) Please Input Parameter"
	echo "       ./init_perm.sh --f (Don't Backup WAS Log File)"
	echo "       ./init_perm.sh --f --debug(Don't Backup WAS Log File & Debug Level log writing)"
	echo "       ./init_perm.sh 20180418 (Backup /pm/app/odapm/logs_backup/20180418)"
	echo "       ./init_perm.sh 20180418 --debug (Backup /pm/app/odapm/logs_backup/20180418 & Debug Level log writing)"
	exit
fi

#1) tomcat down & log delete
echo "###########################################"
echo "## 1) Tomcat Stop & Tomcat Log Delete"
echo ""
curl -k "http://127.0.0.1/ems/stopTomcat"
/pm/app/odapm/bin/shutdown_odapm.sh
sleep 3
ps -ef | grep tomcat
sleep 5

if [ "$!" = "--f" ];then
	echo "****************************************"
	echo " INFO.) Don't Backup WAS Log File!!!!!!"
	echo "****************************************"
	rm -rf /pm/app/odapm/logs/*
else
	mkdir /pm/app/odapm/logs_backup/$1 
	mv /pm/app/odapm/logs/* /pm/app/odapm/logs_backup/$1 
	ls -ltr /pm/app/odapm/logs_backup/$1
fi

echo "############################################"
echo "## 2) Process Down & Process Log Delete- ncn, zone, pfm"
echo ""
stopMP ncn
sleep 3
stopMP zone
sleep 3
stopMP pfm
sleep 3
# ZONE LOG Delete
rm -rf /APPDATA/PM/LOG/*
rm -rf /APPDATA/PM/PCIS/*
# NCN LOG Delete
rm -rf /APPDATA/NCN/LOG/*
 
echo "############################################"
echo "## 3-1) MySQL Zone Service Data Delete"
echo "##     (t_pg_if,t_pg_if_xx, t_pm_push_deal and so on)"
echo ""
$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
truncate t_nfw_app_log_hist;
truncate t_nfw_pfm_log_hist;
truncate t_nfw_resource_status_hist;
truncate t_nrf_request_log;
truncate t_pg_if;
truncate t_pg_if_00;
truncate t_pg_if_01;
truncate t_pg_if_02;
truncate t_pg_if_03;
truncate t_pg_if_04;
truncate t_pg_if_05;
truncate t_pg_if_06;
truncate t_pg_if_07;
truncate t_pg_if_08;
truncate t_pg_if_09;
truncate t_pm_push_deal;
truncate t_pg_lf_zero_alarm;
truncate t_pm_api_request_log;
EOF
echo ""

echo "############################################"
echo "## 3-2) MySQL NCN Service Data Delete (t_push_aom_hist_00 ~ 09,  t_pg_if_hist)"
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
truncate t_pi_stat;
truncate t_fi_stat;
truncate t_nc_stat;
EOF
 
echo "############################################"
echo "## 3-3) MySQL Restart, Please Input root password" 
echo ""
su - root -c "/etc/init.d/mysqld stop;/etc/init.d/mysqld start"
sleep 5
echo ""

echo "############################################"
echo "## 4) WAS config reload & Start" 

if [ "$2" = "--debug" ]; then
	echo "## 4-1) debug mode on" 
	tar -xvf /APPDATA/PM/SIM/PERM/TOOLS/PKG_R120/web_info_conf.tar -C /pm/app/odapm/webapp/WEB-INF/classes
	cp -rf /pm/app/odapm/webapp/WEB-INF/classes/conf/log4j2/log4j2.debug /pm/app/odapm/webapp/WEB-INF/classes/conf/log4j2/log4j2.xml
fi
/pm/app/odapm/bin/startup_odapm.sh
sleep 10
 
echo "############################################"
echo "## 5) PFM & Process Start" 
startMP pfm
sleep 10
startMP zone
#sleep 5
#startMP fi
#startMP nc
#startMP ai
#startMP ti
#startMP ncn_pi
#sleep 5
#startMP ncn_hm
disMP all
sleep 5

echo "#################################################"
echo "#################################################"
echo ">>> Complete Initialize For Performance Test"
echo "#################################################"
echo "#################################################"
exit
