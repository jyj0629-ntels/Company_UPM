#!/usr/bin/env bash
set -euo pipefail

###########################################################################################################################
# 사용법: 
# (1) 본 파일은 "/pm/app/odapm/webapp/upm_file/rqp_conn_cells_request" 디렉토리에 rqp_insert.sh 파일을 복사해 놓은 후...
#    ./rqp_insert.sh <TARGET_DIR>
#    (ex) ./rqp_insert.sh 20260313 (날짜 폴더명) 으로 처리 
# 비밀번호에 특수문자 포함 시 작은따옴표로 감싸주세요: -p'P@ss!23'
# (2) 새로 받은 response 파일을 "/pm/app/odapm/webapp/upm_file/rqp_conn_cells_response/" 디렉토리에 넣고 처리 결과 확인
###########################################################################################################################

HOST="localhost"
PORT="3306"
USER="upm"
PASS="upm?4321?"
DB="pm"

TABLE="t_barod_rqp_hist"      # 기존 이력 테이블
SUB_TABLE="t_barod_sub_list"  # 추가: 대상 서브 테이블

TARGET_DIR="."
TID_LEN=20                    # 기본 TID 자리수(숫자). 필요 시 조정
ADDRESS="서울시 양천구 목1동 7단지"
SYS_ID="UPM01"
SEND_YN="Y"
DEVICE_TYPE="S"
PRODUCT_TYPE="03"

# mysql CLI 체크
if ! command -v mysql >/dev/null 2>&1; then
  echo "ERROR: mysql CLI가 필요합니다. (예: sudo apt-get install -y mysql-client)"
  exit 1
fi

# 인자 확인
if [[ $# -eq 0 ]]; then
    echo "
###########################################################################################################################
# 사용법: 
# (1) 본 파일은 '/pm/app/odapm/webapp/upm_file/rqp_conn_cells_request' 디렉토리에 rqp_insert.sh 파일을 복사해 놓은 후...
#    ./rqp_insert.sh <TARGET_DIR>
#    (ex) ./rqp_insert.sh 20260313 (날짜 폴더명) 으로 처리 
# 비밀번호에 특수문자 포함 시 작은따옴표로 감싸주세요: -p'P@ss!23'
# (2) 새로 받은 response 파일을 '/pm/app/odapm/webapp/upm_file/rqp_conn_cells_response/' 디렉토리에 넣고 처리 결과 확인
###########################################################################################################################"
    echo "ERROR: 첫 번째 인자(TARGET_DIR)가 없습니다."
    echo "사용법: $0 <TARGET_DIR> ..."
    exit 1
fi
if [[ $# -eq 1 ]]; then
    TARGET_DIR="$1"
fi

MYSQL_BASE=(mysql -h "$HOST" -P "$PORT" -u "$USER" -p"$PASS" --default-character-set=utf8mb4 "$DB")

shopt -s nullglob
mapfile -t FILES < <(find "$TARGET_DIR" -maxdepth 1 -type f -name 'rqp_conn_cells_request_*.json' | sort)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "대상 디렉터리에 처리할 파일이 없습니다: $TARGET_DIR"
  exit 0
fi

echo "총 ${#FILES[@]} 개 파일 처리 시작..."

# 숫자 TID 생성기 (SIGPIPE 없는 순수 bash 버전)
gen_tid() {
  local len="${1:-$TID_LEN}"
  local out=""
  while [[ ${#out} -lt $len ]]; do
    out+=$((RANDOM % 10))
  done
  printf '%s' "$out"
}

for f in "${FILES[@]}"; do
  base="$(basename "$f")"

  # 파일명에서 req_date(17자리) 추출
  if [[ "$base" =~ ^rqp_conn_cells_request_([0-9]{17})_([0-9]+)\.json$ ]]; then
    req_date="${BASH_REMATCH[1]}"          # 예: 20260128042118865
    event_timestamp="${req_date:0:14}"     # 예: 20260128042118
  else
    echo "WARN: 패턴 불일치로 스킵: $base"
    continue
  fi

  # 파일 전체를 문자열로 읽어 req_msg 구성
  if ! req_msg="$(cat "$f" 2>/dev/null)"; then
    echo "WARN: 파일 내용을 읽을 수 없어 스킵: $base"
    continue
  fi

  # ---------- jq 없이 JSON 값 추출 ----------
  # 1) 한 줄로 압축(줄바꿈/탭 제거)
  one_line="$(tr -d '\n\r\t' < "$f" 2>/dev/null || true)"

  # 2) sed로 값 추출: "KEY":"VALUE" 패턴
  mdn="$(printf '%s' "$one_line" | sed -n 's/.*"MDN"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  lat="$(printf '%s' "$one_line" | sed -n 's/.*"LATITUDE"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  lon="$(printf '%s' "$one_line" | sed -n 's/.*"LONGITUDE"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

  # 공백 제거
  mdn="$(printf '%s' "${mdn}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  lat="$(printf '%s' "${lat}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  lon="$(printf '%s' "${lon}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  # ------------------------------------------

  status="RE"
  req_result_code=""   # 비었으면 NULL로

  # 중복 방지 (이력 테이블)
  exists=$("${MYSQL_BASE[@]}" -N -e "SELECT 1 FROM ${TABLE} WHERE req_file_name='${base}' LIMIT 1;" || true)
  if [[ "$exists" == "1" ]]; then
    echo "SKIP: 이미 존재 - $base"
    # hist는 스킵하지만, 필요 시 sub 테이블만 넣고 싶다면 여기서 로직 추가 가능
    continue
  fi

  # SQL 이스케이프
  esc_req_file_name=$(printf "%s" "$base" | sed "s/'/''/g")
  esc_req_date=$(printf "%s" "$req_date" | sed "s/'/''/g")
  esc_status=$(printf "%s" "$status" | sed "s/'/''/g")
  esc_event_ts=$(printf "%s" "$event_timestamp" | sed "s/'/''/g")
  esc_req_msg=$(printf "%s" "$req_msg" | sed "s/'/''/g")

  # mdn 처리 (빈 문자열이면 NULL)
  if [[ -z "${mdn}" ]]; then
    mdn_sql="NULL"
  else
    esc_mdn=$(printf "%s" "$mdn" | sed "s/'/''/g")
    mdn_sql="'$esc_mdn'"
  fi

  # lat/lon 숫자 검증 (숫자 아니면 NULL)
  if [[ -n "${lat}" && "${lat}" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    lat_sql="${lat}"
  else
    lat_sql="NULL"
  fi
  if [[ -n "${lon}" && "${lon}" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    lon_sql="${lon}"
  else
    lon_sql="NULL"
  fi

  # req_result_code 처리
  if [[ -z "$req_result_code" ]]; then
    req_result_sql="NULL"
  else
    req_result_sql="'$(printf "%s" "$req_result_code" | sed "s/'/''/g")'"
  fi

  # 1) 이력 테이블 INSERT
  SQL1="
INSERT INTO ${TABLE}
(req_file_name, req_date, status, mdn, req_msg, req_result_code, res_file_name, res_date, res_msg, res_result_code, event_timestamp, alarm_send_time)
VALUES
('${esc_req_file_name}', '${esc_req_date}', '${esc_status}', ${mdn_sql}, '${esc_req_msg}', ${req_result_sql}, NULL, NULL, NULL, NULL, '${esc_event_ts}', NULL);
"
  if "${MYSQL_BASE[@]}" -e "$SQL1"; then
    echo "OK: INSERT (hist) - $base"
  else
    echo "ERROR: INSERT 실패 (hist) - $base"
    continue
  fi

  # 2) 서브 테이블 INSERT (요청하신 매핑 적용)
  #    - 현재시간은 'YYYYMMDDHH24MISS' 포맷 문자열로 저장
  esc_address=$(printf "%s" "$ADDRESS" | sed "s/'/''/g")
  esc_sys_id=$(printf "%s" "$SYS_ID" | sed "s/'/''/g")
  esc_device_type=$(printf "%s" "$DEVICE_TYPE" | sed "s/'/''/g")
  esc_product_type=$(printf "%s" "$PRODUCT_TYPE" | sed "s/'/''/g")
  esc_send_yn=$(printf "%s" "$SEND_YN" | sed "s/'/''/g")

  tid="$(gen_tid "$TID_LEN")"
  esc_tid=$(printf "%s" "$tid" | sed "s/'/''/g")

  SQL2="
INSERT INTO ${SUB_TABLE}
(mdn, lat, lon, event_timestamp, update_timestamp, addr, sys_id, cell_list, send_Yn, use_yn, tid, device_type, product_type, voc_cell, rqp_cell, common_voc_cell, imsi)
VALUES
(${mdn_sql}, ${lat_sql}, ${lon_sql},
 DATE_FORMAT(NOW(),'%Y%m%d%H%i%S'),
 DATE_FORMAT(NOW(),'%Y%m%d%H%i%S'),
 '${esc_address}', '${esc_sys_id}', '', '${esc_send_yn}', 'Y', '${esc_tid}', '${esc_device_type}', '${esc_product_type}',
 NULL, NULL, NULL, NULL);
"
  if "${MYSQL_BASE[@]}" -e "$SQL2"; then
    echo "OK: INSERT (sub)  - mdn=${mdn:-NULL}, tid=${tid}"
  else
    echo "ERROR: INSERT 실패 (sub) - mdn=${mdn:-NULL}, 파일=$base"
  fi

done

echo "##################################################"
echo "처리 완료."
echo "##################################################"