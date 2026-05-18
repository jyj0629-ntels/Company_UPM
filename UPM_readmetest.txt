######################################################################################
# This is manual for UPM Test
######################################################################################

1) UPM / PG Simulator Connection Check 
   (1) sqlpm (Local DB Connect alias)
   (2) PG Simulator Connection IP/Port Check Query
       select * from t_pm_configuration where conf_id like 'BAROD_PG_SOCKET_INFO%';

2) PG Simulator Directory (cdsim - alias)
    Method1) cdsim 
    Method2) cd /APPDATA/PM/SIM/HFC_PG

3) PG Simluator 기동 방법
    (1) PKG R260 : ./startHfc_260.sh
        first parameter : type or null
        - type : when you use Performance Test, you can use 'performance' as first parameter
        - '' : When you use Function Test, you can see all PG Simulator log
    (2) 해당 디렉토리에 PGSim.log 파일이 생성 되며, Simulator로그를 보면서 확인 가능.

4) PG Simulator 사용 메뉴얼 확인하는 방법
    curl "http://127.0.0.1:10099/sim/help"

5) CMSWEB 기지국 처리 시험 방법 (HWAS로 API Resut 호출 방식 / PG Simulator는 연결 되어 있어야 함)
    (1) HWAS가 기동된 서버로 API Rest 호출
      > curl -k "http://50.10.23.128/barod/getCellFromAllUser?pmr=AL"
      > curl -k "http://127.0.0.1/barod/getCellFromAllUser?pmr=AL"

6) 가입자 용량별 성능 시험 방법
  (1) cd /APPDATA/PM/SIM/PERM/TOOLS/PKG_RXXX : 성능 시험 Simulator 및 기타 Script 디렉토리 이동
    - PKG_RXXX의 XXX는 PKG 버전을 의미함.
  (2) ./HFC_TEST_START.sh 스크립트로 실행. (사용방법은 하기 참고 / 파라미터 값을 넣어 줘야 함)
        ###########################################
        에러: 변수 2개를 입력해야 합니다.
        사용법: <변수 1 : ( A / S : Active/Standby) > <변수2 (1 ~ 5)> <변수2 (1 or 2 : CMSWEB/PG API, Only CMSWEB)>
        ###########################################
        -------------------------------------------
        HELP :파라미터 첫번째값을 선택해 주세요.
        A : Active
        S : Standby
        -------------------------------------------
        HELP :파라미터 두번째값을 선택해 주세요.
        1 : 96,000 Subscriber
        2 : 120,000 Subscriber
        3 : 140,000 Subscriber
        4 : 160,000 Subscriber
        5 : 180,000 Subscriber
        -------------------------------------------
        HELP : 파라미터 두번째 값을 선택해 주세요.
        1 : CMSWEB 및 PG 가입/해지/기기변경 전문 전송 시험
        2 : CMSWEB 변경 기지국 처리만 (PG전문 미포함)
        ##############################################

7) 성능 시험 통계 확인 방법
  (1) cd /APPDATA/PM/SIM/PERM/TOOLS/PKG_RXXX : 성능 시험 Simulator 및 기타 Script 디렉토리 이동 
      - PKG_RXXX의 XXX는 PKG 버전을 의미
      비고) cdperm이라는 alias를 통해서 /APPDATA/PM/SIM/PERM 디렉토리 이동후에 상황에 따라서 디렉토리 이동해도 됨
  (2) ./result_report.sh 스크립트 파일 사용  
      - 첫번째 파라미터 : 통계 시작 시간
      - 두번째 파라미터 : 통계 종료 시간
      - 세번째 파라미터 : UPM에 포함된 서비스별 값
        > 1 : TDATAFREE - Zone 서비스 (서비스 종료됨)
        > 2 : 서비스형 MDMS 
        > 3 : HFC
        > 4: 1,2,3 모두 통계 표히
      예시) ./result_report.sh 20250417180000 20250417190000 3