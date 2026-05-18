#/bin/sh
DB_IP="127.0.0.1"
DATABASE_NAME="pm"

pmsql="$MYSQL_HOME/bin/mysql -uupm -pupm?4321? pm -h ${DB_IP}"

# 첫 번째 파라미터 확인
if [ "$1" = "PG" ]; then
echo "PG 환경으로 설정을 변경합니다."
echo "##################################################################################################################"
echo " 1) PG Connection 설정 변경"
$pmsql << EOF
update t_pm_configuration set conf_value = '60.30.133.50' where conf_id = 'BAROD_PG_SEND_PRIMARY';
update t_pm_configuration set conf_value = '60.30.133.120' where conf_id = 'BAROD_PG_SEND_SECONDARY';
update t_pm_configuration set conf_value = '60.30.133.50|10506' where conf_id = 'BAROD_PG_SOCKET_INFO_SS1';
update t_pm_configuration set conf_value = '60.30.133.120|10506' where conf_id = 'BAROD_PG_SOCKET_INFO_SS2';
update t_pm_configuration set conf_value = '' where conf_id = 'BAROD_PG_SOCKET_INFO_DS1';
EOF
echo "##################################################################################################################"
echo " 2-1) T_BAROD_CELL_LIST에 기지국 추가"
$pmsql << EOF
INSERT INTO t_barod_cell_list (lon, lat, cell_info, zone_id, eqp_type, ta_code, create_dt) VALUES (127.066945, 37.543119, '10:0', '10000004', 'REPEATER', '123456', '2025-06-10 14:51:21');
EOF
echo "##################################################################################################################"
echo " 2-1) T_BAROD_CELL_LIST_1에 기지국 추가"
$pmsql << EOF
INSERT INTO t_barod_cell_list_1 (lon, lat, cell_info, zone_id, eqp_type, ta_code, create_dt) VALUES (127.066945, 37.543119, '10:0', '10000004', 'REPEATER', '123456', '2025-06-10 14:51:21');
EOF
echo "********************************************************************************************************************"
echo " 3) 설정 및 추가 정보 확인"  
$pmsql << EOF
select * from t_pm_configuration where conf_id = 'BAROD_PG_SEND_PRIMARY' or conf_id = 'BAROD_PG_SEND_SECONDARY' or conf_id = 'BAROD_PG_SOCKET_INFO_SS1' or conf_id = 'BAROD_PG_SOCKET_INFO_SS2' or conf_id = 'BAROD_PG_SOCKET_INFO_DS1';
select * from t_barod_cell_list where cell_info = '10:0';
select * from t_barod_cell_list_1 where cell_info = '10:0';
EOF
echo "********************************************************************************************************************"
echo "[END] ############################################################################################################"
elif [ "$1" = "UPM" ]; then
echo "UPM 환경으로 설정을 변경합니다."
$pmsql << EOF
update t_pm_configuration set conf_value = '50.10.23.129' where conf_id = 'BAROD_PG_SEND_PRIMARY';
update t_pm_configuration set conf_value = '50.10.23.128' where conf_id = 'BAROD_PG_SEND_SECONDARY';
update t_pm_configuration set conf_value = '50.10.23.129|11080' where conf_id = 'BAROD_PG_SOCKET_INFO_SS1';
update t_pm_configuration set conf_value = '50.10.23.128|11080' where conf_id = 'BAROD_PG_SOCKET_INFO_SS2';
update t_pm_configuration set conf_value = '50.10.23.183' where conf_id = 'BAROD_PG_SOCKET_INFO_DS1';
EOF
echo "##################################################################################################################"
$pmsql << EOF
select * from t_pm_configuration where conf_id = 'BAROD_PG_SEND_PRIMARY' or conf_id = 'BAROD_PG_SEND_SECONDARY' or conf_id = 'BAROD_PG_SOCKET_INFO_SS1' or conf_id = 'BAROD_PG_SOCKET_INFO_SS2' or conf_id = 'BAROD_PG_SOCKET_INFO_DS1';
select * from t_barod_cell_list where cell_info = '10:0';
select * from t_barod_cell_list_1 where cell_info = '10:0';
EOF
echo "##################################################################################################################"
else
    echo "#########################################################"
    echo " ERROR) 첫번째 인자를 입력 하지 않았습니다."
    echo " 사용법: ./HFC_PG_Conn_Config_chg.sh [PG|UPM]"
    echo "#########################################################"
    exit 1
fi

