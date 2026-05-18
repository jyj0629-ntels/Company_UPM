# FileName : readmetest.txt
# made by Mr.Music
# System Name : IPMDN
# Date : 2024-06-10
# Version : 1.0
#######################################################################################
# 시험을 위한 Alias 및 디렉토리, Tool 설명 (Guide)
#######################################################################################
[1] Alias 설명 
cdsim   : Simulator들이 있는 상위 디렉토리 /APP/simul
cdftest : PKG 시험을 위한 기능호 Simulator directory
cdltest : 최대성능 및 장기 Aging Simulator directory
cdperm  : 최대성능 및 장기 Aging시, CPU/MEM/프로세스 메모리 누수 점검을 위한 Log 생성
          시험완료 후, 통계를 보는 Script 존재
emssql  : EMS MySQL 접속 alias
비고) cdftest 의 경우, 하위 디렉토리는 app01/app02가 다름 
(app01 서버로 쏘는 경우, app02 서버로 쏘는 경우를 의미함)

[2] 기능 시험의 경우, 하위는 PKG Number로 디렉토리를 관리.
 - 모든 기능 시험은 SVT시에 성능호를 쏴 두고 기능호를 쏘는 시험한다.
 - PCF SESSION Data는 약 4,700만건을 넣어 두고 시험 시작.
 
[3] Tool 및 EMS 통계 등등 확인 방법 
  1) Config 설정 정보 확인 
    - ipmdn.conf 파일 보기 
     Ex) cat /APP/ipmdn/ipmdn_data/conf/ipmdn.conf
        - 연동 PEER 정보 확인 (NODE_INFO.xml)
         Ex) cat /APP/atom/BLUECORE/CFG/NODE_INFO.xml
         
  2) DB의 PGW GRoupID, Roaming Prefix, NAT_IP
     - T_IPMDN_IP_GROUP_INFO 
         - T_IPMDN_NAT_PREFIX_INFO
         - T_IPMDN_ROAMING_PREFIX_INFO
         
  3) RM/SM Cache 및 DB의 PCF 가입자 Session 정보 보는 법
     디렉토리 : /APP/ipmdn/ipmdn_home/cmd/SCRIPT
         - rm.select.sh [단말IP]
     Ex) /APP/ipmdn/ipmdn_home/cmd/SCRIPT/rm.select.sh 1.1.1.1
         - sm.select.sh [단말IP]
     Ex) /APP/ipmdn/ipmdn_home/cmd/SCRIPT/sm.select.sh 1.1.1.1
         - SELECT * FROM T_IPMDN_SESSION_DATA WHERE WHERE IP = '1.1.1.1'; 
           (추가 조회 조건 : IP, MDN, MIN, MSISDN....)
         
  4) 통계 확인 
     - T_IPMDN_MMSC_STATISTICS_5MIN
         - T_IPMDN_NAG_STATISTICS_5MIN
         - T_IPMDN_IMS_STATISTICS_5MIN)
     Ex) SELECT * FROM T_IPMDN_IMS_STATISTICS_5MIN WHERE NODE = 'IMS-SIM' AND PRC_DATE BETWEEN '2024-06-10 00:00:00' AND '2024-06-10 00:00:05';