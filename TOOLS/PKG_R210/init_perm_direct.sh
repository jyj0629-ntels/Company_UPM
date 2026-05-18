#/bin/sh
sqlplus upm/upm1234567@upm << EOF
DELETE FROM T_ZNS_PM_API_REQUEST_LOG;
DELETE FROM T_ZNS_PM_PUSH_HIST;
EOF

su - root -c "/bin/rm -rf /pm/web/apache-2.2.27/logs/access_log*.gz /pm/web/apache-2.2.27/logs/modjk-log/*log*"

if [ -z $1 ]; then
        echo "Error) Please input date time"
        exit
else

/pm/app/odapm/bin/shutdown_odapm.sh --f
sleep 3

if [ "$1" = "--f" ]; then
        echo ">>> Information) Don't Backup WAS Log File"
        /bin/r? -rf /pm/app/odapm/logs/*
else
mkdir /pm/app/odapm/logs_backup/$1
mv /pm/app/odapm/logs/* /pm/app/odapm/logs_backup/$1
ls -ltr /pm/app/odapm/logs_backup/$1
fi

$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? pm << EOF
truncate t_nfw_app_log_hist;
truncate t_nfw_pfm_log_hist;
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
truncate t_pm_push_deal_retry;
truncate t_pg_lf_zero_alarm;
truncate t_pm_api_request_log;
EOF

/pm/app/odapm/bin/startup_odapm.sh

fi

