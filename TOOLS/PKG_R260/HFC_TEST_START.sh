#!/bin/sh
# PG SImulator Path
PG_SIM_PATH="/APPDATA/PM/SIM/HFC_PG/"

# 분당 UPM 시험기
SIM_IP_A='50.10.23.128'
SIM_IP_B='50.10.23.129'
# 사내 개발기 
#SIM_IP_A='192.168.10.85'
#SIM_IP_B='192.168.10.85'

pmsql="$MYSQL_HOME/bin/mysql -uupm -pupm?4321? pm -h 127.0.0.1" 

# 유효성 체크 : 입력변수 3개 받아야 함.
if [ $# -ne 3 ]; then
  echo "#####################################################################################################"
  echo "에러: 변수 2개를 입력해야 합니다."
  echo "사용법: <변수 1 : ( A / S : Active/Standby) > <변수2 (1 ~ 5)> <변수2 (1 or 2 : CMSWEB/PG API, Only CMSWEB)>"
  echo "#####################################################################################################"
  echo " SIMULATOR IP : ${SIM_IP_A}"
  echo "-------------------------------------------"
  echo "HELP :파라미터 첫번째값을 선택해 주세요."
  echo " A : Active"
  echo " S : Standby"
  echo "-------------------------------------------"
  echo "HELP :파라미터 두번째값을 선택해 주세요."
  echo " 1 : 96,000 Subscriber"
  echo " 2 : 120,000 Subscriber"
  echo " 3 : 140,000 Subscriber"
  echo " 4 : 160,000 Subscriber"
  echo " 5 : 180,000 Subscriber"
  echo "-------------------------------------------"
  echo "HELP : 파라미터 두번째 값을 선택해 주세요."
  echo " 1 : CMSWEB 및 PG 가입/해지/기기변경 전문 전송 시험"
  echo " 2 : CMSWEB 변경 기지국 처리만 (PG전문 미포함)"
  echo "##############################################"
  exit 1
fi

# 유효성 체크 : 첫번째 파라미터가 A or S 가 아니면 에러
if [[ "$1" != "A" && "$1" != "S" ]]; then
  echo "Error: 첫번째 입력 값은 'A' 또는 'S'여야 합니다.(Active / Standby)"
  exit 1
fi

# 유효성 체크 :  파라미터2 입력값
if [ -z "$2" ]; then
  echo "##############################################"
  echo "HELP :파라미터 첫번째값을 선택해 주세요."
  echo " 1 : 96,000 Subscriber"
  echo " 2 : 120,000 Subscriber"
  echo " 3 : 140,000 Subscriber"
  echo " 4 : 160,000 Subscriber"
  echo " 5 : 180,000 Subscriber"
  exit 1
fi

# 유효성 체크 :  파라미터3 입력값
if [ -z "$3" ]; then
  echo "##############################################"
  echo "HELP : 파라미터 두번째 값을 선택해 주세요."
  echo " 1 : CMSWEB 및 PG 가입/해지/기기변경 전문 전송 시험"
  echo " 2 : CMSWEB 변경 기지국 처리만 (PG전문 미포함)"
  exit 1
fi

NOWTIME=`date`
echo "####################################################################################"
echo " TIME : [$NOWTIME]"
echo " HWAS STOP "
/pm/app/odapm/bin/shutdown_odapm.sh
echo " MWAS STOP "
/pm/app/mdms/bin/shutdown_mdms.sh
echo "####################################################################################"


###############################################
echo  "  1) t_barod_rqp_hist truncate"
$pmsql << EOF
truncate t_barod_rqp_hist;
EOF

###############################################
echo  "  2-1) t_barod_msg_hist truncate"
$pmsql << EOF
truncate t_barod_msg_hist;
EOF

###############################################
echo  "  3) HFC Subscriber Reset $2"
case "$2" in
  1)
    echo "     96,000 HFC Subscriber Test"
    $pmsql < ./SUBLIST_DUMP/t_barod_sub_list_96000_dump.sql
    ;;
  2)
    echo "     120,000 HFC Subscriber Test"
    $pmsql < ./SUBLIST_DUMP/t_barod_sub_list_120000_dump.sql
    ;;
  3)
    echo "     140,000 HFC Subscriber Test"
    $pmsql < ./SUBLIST_DUMP/t_barod_sub_list_140000_dump.sql
    ;;
  4)
    echo "     160,000 HFC Subscriber Test"
    $pmsql < ./SUBLIST_DUMP/t_barod_sub_list_160000_dump.sql
    ;;
  5)
    echo "     180,000 HFC Subscriber Test"
    $pmsql < ./SUBLIST_DUMP/t_barod_sub_list_180000_dump.sql
    ;;
  *)
    echo "에러: 유효하지 않은 파라미터입니다. (1 또는 2만 허용)"
    exit 1
    ;;
esac

$pmsql << EOF
SELECT count(*) AS HFC_SUBSCRIBER_TOTAL_COUNT from t_barod_sub_list;
EOF

sleep 5

###############################################
if [ $1 == "A" ] ; then
echo "   4) Cell List update & change"
$pmsql << EOF
update t_barod_sub_list set cell_list = '[{\"cell_info\":\"3819:18\",\"ta_code\":\"2121\"},{\"cell_info\":\"28235:9\",\"ta_code\":\"ABAD\"},{\"cell_info\":\"2sdfs:1\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:11\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:21\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:31\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:41\",\"ta_code\":\"3104\"},{\"cell_info\":\"6900:1\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:11\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:14\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:21\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:24\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:31\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:34\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:4\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:41\",\"ta_code\":\"101E\"},{\"cell_info\":\"6900:44\",\"ta_code\":\"101E\"},{\"cell_info\":\"28816:9\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:12\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:2\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:22\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:32\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:42\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:1\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:11\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:21\",\"ta_code\":\"1136\"},{\"cell_info\":\"28654:16\",\"ta_code\":\"3104\"},{\"cell_info\":\"28654:6\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:12\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:2\",\"ta_code\":\"3104\"},{\"cell_info\":\"28787:1\",\"ta_code\":\"2121\"},{\"cell_info\":\"28787:11\",\"ta_code\":\"2121\"},{\"cell_info\":\"28787:31\",\"ta_code\":\"2121\"},{\"cell_info\":\"28787:41\",\"ta_code\":\"2121\"},{\"cell_info\":\"28787:21\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:14\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:24\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:34\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:4\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:44\",\"ta_code\":\"2121\"},{\"cell_info\":\"28827:31\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:41\",\"ta_code\":\"1136\"},{\"cell_info\":\"28652:32\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:42\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:22\",\"ta_code\":\"3104\"},{\"cell_info\":\"12368:17\",\"ta_code\":\"1136\"},{\"cell_info\":\"3920:13\",\"ta_code\":\"1136\"},{\"cell_info\":\"3920:3\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:27\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:7\",\"ta_code\":\"1136\"},{\"cell_info\":\"28766:14\",\"ta_code\":\"1136\"},{\"cell_info\":\"28766:34\",\"ta_code\":\"1136\"},{\"cell_info\":\"28766:44\",\"ta_code\":\"1136\"},{\"cell_info\":\"25980:7\",\"ta_code\":\"2121\"},{\"cell_info\":\"28784:35\",\"ta_code\":\"3104\"},{\"cell_info\":\"28651:17\",\"ta_code\":\"3104\"},{\"cell_info\":\"28651:7\",\"ta_code\":\"3104\"},{\"cell_info\":\"25980:1\",\"ta_code\":\"2121\"},{\"cell_info\":\"25980:4\",\"ta_code\":\"2121\"},{\"cell_info\":\"28827:5\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:15\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:18\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:25\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:28\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:35\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:38\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:45\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:48\",\"ta_code\":\"1136\"},{\"cell_info\":\"28827:8\",\"ta_code\":\"1136\"},{\"cell_info\":\"28651:37\",\"ta_code\":\"3104\"},{\"cell_info\":\"28651:47\",\"ta_code\":\"3104\"},{\"cell_info\":\"26104:35\",\"ta_code\":\"2121\"},{\"cell_info\":\"26104:45\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:15\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:25\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:35\",\"ta_code\":\"2121\"},{\"cell_info\":\"28789:45\",\"ta_code\":\"2121\"},{\"cell_info\":\"26104:15\",\"ta_code\":\"2121\"},{\"cell_info\":\"1010:3\",\"ta_code\":\"2121\"},{\"cell_info\":\"12368:5\",\"ta_code\":\"1136\"},{\"cell_info\":\"12368:8\",\"ta_code\":\"1136\"},{\"cell_info\":\"28635:17\",\"ta_code\":\"3104\"},{\"cell_info\":\"28635:37\",\"ta_code\":\"3104\"},{\"cell_info\":\"28635:47\",\"ta_code\":\"3104\"},{\"cell_info\":\"26600:17\",\"ta_code\":\"3104\"},{\"cell_info\":\"28635:27\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:4\",\"ta_code\":\"3104\"},{\"cell_info\":\"16988:15\",\"ta_code\":\"3104\"},{\"cell_info\":\"16988:25\",\"ta_code\":\"3104\"},{\"cell_info\":\"16988:35\",\"ta_code\":\"3104\"},{\"cell_info\":\"16988:45\",\"ta_code\":\"3104\"},{\"cell_info\":\"16988:5\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:14\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:24\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:34\",\"ta_code\":\"3104\"},{\"cell_info\":\"28652:44\",\"ta_code\":\"3104\"},{\"cell_info\":\"28783:12\",\"ta_code\":\"2121\"},{\"cell_info\":\"28783:2\",\"ta_code\":\"2121\"},{\"cell_info\":\"323:12\",\"ta_code\":\"2AAA\"},{\"cell_info\":\"28783:22\",\"ta_code\":\"2121\"}]';
EOF
fi

###############################################
echo "   4-1-1) hwas log delete "
rm -rf /pm/app/odapm/logs/*
echo "   4-1-2) HFC Subscriber DB Sync Data 및 ERROR 폴더의 쓰레기 File delete"
rm -rf /pm/app/odapm/webapp/upm_file/upm_sync_data/20*
rm -rf /pm/app/odapm/webapp/upm_file/upm_sync_data/ERROR/*
echo "   4-1-3) HFC Subscriber RQP Data File delete"
rm -rf /pm/app/odapm/webapp/upm_file/rqp_conn_cells_request/*
rm -rf /pm/app/odapm/webapp/upm_file/rqp_conn_cells_response/*
rm -rf /pm/app/odapm/webapp/upm_file/rqp_conn_cells_batch_request/*
rm -rf /pm/app/odapm/webapp/upm_file/rqp_conn_cells_batch_response/*
echo "   4-1-4) mwas log delete "
rm -rf /pm/app/mdms/logs/*
sleep 1 

###############################################
echo "   4-2-1) hwas Start"
/pm/app/odapm/bin/startup_odapm.sh

sleep 3

echo "   4-2-2) mwas Start"
/pm/app/mdms/bin/startup_mdms.sh
sleep 30

###############################################
# Standby 장비는 기지국 재조회를 돌리지 않음
if [ "$1" = "A" ] ; then
###############################################
echo "   5) ZC API Request"
curl -k "http://localhost/barod/getCellFromAllUser?pmr=AL"
echo
sleep 10
fi

# 첫번째 파라미터, A인 경우 : SIM_IP_B 치환, S인 경우 : SIM_IP_A 로 치환
case "$3" in
  1)
if [ $1 == "A" ] ; then
  SIM_IP=$SIM_IP_B
else
  SIM_IP=$SIM_IP_A
fi

##############################################################################################
# HELP : UPM 2대 에서 상용과 같이 연동 하게 함으로 2초에 하나씩 보냄으로 결국 1TPS 됨 / 나머지도 절반씩 쏘면 됨
echo "   6-1) PG JOIN API Request"
curl "http://${SIM_IP}:10099/sim/scenario3?type=1&mdnCount=140000&repeat=1&interval=2000"
echo
sleep 5

###############################################
echo "   6-2) PG DELETE API Request"
curl "http://${SIM_IP}:10099/sim/scenario3?type=3&mdnCount=140000&repeat=1&interval=200000"
echo
sleep 5

###############################################
echo "   6-3) PG MDN CHANGE API Request"
curl "http://${SIM_IP}:10099/sim/scenario4?startMdn=01000000001&changeMdn=01100000001&mdnCount=140000&repeat=1&interval=200000"
echo
sleep 5
    ;;
  *)
    echo "전문 발송은 하지 않고 CMSWEB에 의한 기지국 변경 REQ만 시험"
    ;;
esac

STARTTIME=`date`
echo "************************************************************************************"
echo "[ INITIAL END - TEST Start ]" 
echo " TEST START TIME : [$STARTTIME]"
echo "************************************************************************************"

tail -f /pm/app/odapm/logs/catalina.out | grep -E "messageType|Exception"