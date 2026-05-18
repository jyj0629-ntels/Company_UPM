#!/bin/bash

# HFCSimulator 프로세스를 찾아서 종료하는 스크립트

MODE=$1
TAIL_TYPE=$2

echo "####################################################################"
echo "     CHECK HFC PG Simulator & Start "
echo "####################################################################"
# 프로세스 목록에서 HFCSimulator 관련 프로세스 찾기 (grep 제외)
PIDS=$(ps -ef | grep HFCSimulator | grep -v grep | awk '{print $2}')

echo "    *********************************************************"
if [ -z "$PIDS" ]; then
  echo "    [Caution] HFCSimulator 관련 프로세스를 찾을 수 없습니다."
else
  echo "      종료할 PID 목록: $PIDS"
  for PID in $PIDS; do
    echo "    프로세스 종료 중: PID $PID"
    kill -9 $PID
  done
  echo "      모든 관련 프로세스 종료 완료."
fi
echo "    *********************************************************"

# Simulator 로그 파일 삭제
echo " PGSim.log 파일 삭제 "
rm -rf PGSim.log

if [[ "$MODE" == "S" ]]; then
    echo "===================================================================="
    echo " >>>> PG Simulator가 종료 되었습니다."
    echo "===================================================================="
    exit 1
fi

# HFC PG Simulator 실행
nohup java -jar -Djava.net.preferIPv4Stack=true HFCSimulator_R260.jar PG51 10080 > PGSim.log 2>&1 &
echo "########################################## "
ps -ef | grep HFCSimulator
echo "######################################### "

sleep 2

if [[ "$TAIL_TYPE" == "T" ]]; then
        echo "===================================================================="
        echo " >>>> Turn On : Only Message Type is printed (For Performance Test)"
        echo "===================================================================="
        tail -f PGSim.log | grep -E "tid==|msgType=="
else
        echo "####################################################################"
        echo "===================================================================="
        echo " >>>> Turn Off : All Message is printed (For Function Test)"
        echo "===================================================================="
        tail -f PGSim.log
fi
