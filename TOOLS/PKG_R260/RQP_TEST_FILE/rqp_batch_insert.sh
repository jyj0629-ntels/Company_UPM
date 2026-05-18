#!/bin/bash
# =====================================================
# Usage: ./insert_direct_mysql.sh YYYYMMDD
# =====================================================

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 YYYYMMDD"
  exit 1
fi

BASE_DIR="$1"

# -----------------------------------------------------
# MySQL Connection Info
# -----------------------------------------------------
MYSQL_HOST="127.0.0.1"
MYSQL_USER="upm"
MYSQL_PASS="upm?4321?"
MYSQL_DB="pm"

# -----------------------------------------------------
# Initial Values
# -----------------------------------------------------
MDN_NUM=1
LAT=37.31677
LON=127.122694

ADDR="서울시 양천구 목1동 7단지"
SYS_ID="UPM01"

# -----------------------------------------------------
# JSON file list
# -----------------------------------------------------
FILES=$(ls ${BASE_DIR}/rqp_conn_cells_batch_request_*_UPM01.json 2>/dev/null | sort -t'_' -k7 -n)

if [ -z "$FILES" ]; then
  echo "? ERROR: 처리할 JSON 파일이 없습니다."
  exit 1
fi

# =====================================================
# Main Process
# =====================================================
for FILE in $FILES; do
  FILE_NAME=$(basename "$FILE")

  echo "=================================================="
  echo "▶ Processing file: $FILE_NAME"
  echo "=================================================="

  if [ ! -r "$FILE" ]; then
    echo "? ERROR: 파일을 읽을 수 없습니다 -> $FILE"
    continue
  fi

  # ---------------------------------------------------
  # 파일명에서 YYYYMMDDHHmmss 추출 (req_date 용)
  # ---------------------------------------------------
  REQ_DATE=$(echo "$FILE_NAME" | sed -n 's/.*_\(20[0-9]\{12\}\)_.*/\1/p')

  if [ -z "$REQ_DATE" ]; then
    echo "? ERROR: 파일명에서 날짜 추출 실패 -> $FILE_NAME"
    continue
  fi

  # ---------------------------------------------------
  # 파일 전체 내용 -> req_msg (JSON 안전 처리)
  # ---------------------------------------------------
  FILE_CONTENT=$(cat "$FILE")
  ESCAPED_FILE_CONTENT=$(printf "%s" "$FILE_CONTENT" | sed "s/'/''/g")

  # =================================================
  # 1?? t_barod_rqp_hist : 파일당 1번 INSERT
  # =================================================
  SQL_RQP_HIST="
SET @req_msg='${ESCAPED_FILE_CONTENT}';

INSERT INTO t_barod_rqp_hist (
  req_file_name,
  req_date,
  status,
  mdn,
  req_msg,
  req_result_code,
  res_file_name,
  res_date,
  res_msg,
  res_result_code,
  event_timestamp,
  alarm_send_time
) VALUES (
  '${FILE_NAME}',
  '${REQ_DATE}',
  'D',
  NULL,
  @req_msg,
  'SC0000',
  NULL,
  NULL,
  NULL,
  NULL,
  ${REQ_DATE},
  NULL
);
"

  echo ""
  echo "▶ INSERT t_barod_rqp_hist (FILE 단위 1건)"
  echo "$SQL_RQP_HIST"
  echo "----------------------------------------------"

  echo "$SQL_RQP_HIST" | mysql -h "$MYSQL_HOST" \
                             -u "$MYSQL_USER" \
                             -p"$MYSQL_PASS" \
                             "$MYSQL_DB"

  # =================================================
  # 2?? t_barod_sub_list : 파일 안 라인마다 INSERT
  # =================================================
  while read -r LINE; do

    IMSI=$(echo "$LINE" | sed -n 's/.*"IMSI":"\([^"]*\)".*/\1/p')
    [ -z "$IMSI" ] && continue

    NOW_TS=$(date +"%Y%m%d%H%M%S")
    MDN=$(printf "010%08d" "$MDN_NUM")
    TID="${SYS_ID}_${NOW_TS}"

    SQL_SUB_LIST="
INSERT INTO t_barod_sub_list (
  mdn, lat, lon, cell_list, send_Yn, result_code,
  event_timestamp, update_timestamp, addr, sys_id, tid,
  pg_sync_update_yn, use_yn, device_type, product_type,
  voc_cell, rqp_cell, common_voc_cell, imsi, upm_sys_id, process_type
) VALUES (
  '${MDN}',
  '${LAT}',
  '${LON}',
  NULL,
  'Y',
  NULL,
  '${NOW_TS}',
  '${NOW_TS}',
  '${ADDR}',
  '${SYS_ID}',
  '${TID}',
  NULL,
  'Y',
  'S',
  '03',
  NULL,
  NULL,
  NULL,
  '${IMSI}',
  'UPM01',
  'RP'
);
"

    echo ""
    echo "▶ INSERT t_barod_sub_list"
    echo "MDN=${MDN}, IMSI=${IMSI}"
    echo "$SQL_SUB_LIST"
    echo "----------------------------------------------"

    echo "$SQL_SUB_LIST" | mysql -h "$MYSQL_HOST" \
                                -u "$MYSQL_USER" \
                                -p"$MYSQL_PASS" \
                                "$MYSQL_DB"

    MDN_NUM=$((MDN_NUM + 1))
    LAT=$(printf "%.5f" "$(echo "$LAT + 0.00001" | bc)")
    LON=$(printf "%.6f" "$(echo "$LON + 0.000001" | bc)")

  done < "$FILE"

done

echo "? 모든 파일 처리 완료"
[upm@UPM51:0:/APPDATA/PM/SIM/PERM/TOOLS/PKG_R260/RQP_TEST] 
[upm@UPM51:0:/APPDATA/PM/SIM/PERM/TOOLS/PKG_R260/RQP_TEST] 
[upm@UPM51:0:/APPDATA/PM/SIM/PERM/TOOLS/PKG_R260/RQP_TEST] 
[upm@UPM51:0:/APPDATA/PM/SIM/PERM/TOOLS/PKG_R260/RQP_TEST] cat rqp_batch_insert.sh 
#!/bin/bash
# =====================================================
# Usage: ./insert_direct_mysql.sh YYYYMMDD
# =====================================================

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 YYYYMMDD"
  exit 1
fi

BASE_DIR="$1"

# -----------------------------------------------------
# MySQL Connection Info
# -----------------------------------------------------
MYSQL_HOST="127.0.0.1"
MYSQL_USER="upm"
MYSQL_PASS="upm?4321?"
MYSQL_DB="pm"

# -----------------------------------------------------
# Initial Values
# -----------------------------------------------------
MDN_NUM=1
LAT=37.31677
LON=127.122694

ADDR="서울시 양천구 목1동 7단지"
SYS_ID="UPM01"

# -----------------------------------------------------
# JSON file list
# -----------------------------------------------------
FILES=$(ls ${BASE_DIR}/rqp_conn_cells_batch_request_*_UPM01.json 2>/dev/null | sort -t'_' -k7 -n)

if [ -z "$FILES" ]; then
  echo "? ERROR: 처리할 JSON 파일이 없습니다."
  exit 1
fi

# =====================================================
# Main Process
# =====================================================
for FILE in $FILES; do
  FILE_NAME=$(basename "$FILE")

  echo "=================================================="
  echo "▶ Processing file: $FILE_NAME"
  echo "=================================================="

  if [ ! -r "$FILE" ]; then
    echo "? ERROR: 파일을 읽을 수 없습니다 -> $FILE"
    continue
  fi

  # ---------------------------------------------------
  # 파일명에서 YYYYMMDDHHmmss 추출 (req_date 용)
  # ---------------------------------------------------
  REQ_DATE=$(echo "$FILE_NAME" | sed -n 's/.*_\(20[0-9]\{12\}\)_.*/\1/p')

  if [ -z "$REQ_DATE" ]; then
    echo "? ERROR: 파일명에서 날짜 추출 실패 -> $FILE_NAME"
    continue
  fi

  # ---------------------------------------------------
  # 파일 전체 내용 -> req_msg (JSON 안전 처리)
  # ---------------------------------------------------
  FILE_CONTENT=$(cat "$FILE")
  ESCAPED_FILE_CONTENT=$(printf "%s" "$FILE_CONTENT" | sed "s/'/''/g")

  # =================================================
  # 1?? t_barod_rqp_hist : 파일당 1번 INSERT
  # =================================================
  SQL_RQP_HIST="
SET @req_msg='${ESCAPED_FILE_CONTENT}';

INSERT INTO t_barod_rqp_hist (
  req_file_name,
  req_date,
  status,
  mdn,
  req_msg,
  req_result_code,
  res_file_name,
  res_date,
  res_msg,
  res_result_code,
  event_timestamp,
  alarm_send_time
) VALUES (
  '${FILE_NAME}',
  '${REQ_DATE}',
  'D',
  NULL,
  @req_msg,
  'SC0000',
  NULL,
  NULL,
  NULL,
  NULL,
  ${REQ_DATE},
  NULL
);
"

  echo ""
  echo "▶ INSERT t_barod_rqp_hist (FILE 단위 1건)"
  echo "$SQL_RQP_HIST"
  echo "----------------------------------------------"

  echo "$SQL_RQP_HIST" | mysql -h "$MYSQL_HOST" \
                             -u "$MYSQL_USER" \
                             -p"$MYSQL_PASS" \
                             "$MYSQL_DB"

  # =================================================
  # 2?? t_barod_sub_list : 파일 안 라인마다 INSERT
  # =================================================
  while read -r LINE; do

    IMSI=$(echo "$LINE" | sed -n 's/.*"IMSI":"\([^"]*\)".*/\1/p')
    [ -z "$IMSI" ] && continue

    NOW_TS=$(date +"%Y%m%d%H%M%S")
    MDN=$(printf "010%08d" "$MDN_NUM")
    TID="${SYS_ID}_${NOW_TS}"

    SQL_SUB_LIST="
INSERT INTO t_barod_sub_list (
  mdn, lat, lon, cell_list, send_Yn, result_code,
  event_timestamp, update_timestamp, addr, sys_id, tid,
  pg_sync_update_yn, use_yn, device_type, product_type,
  voc_cell, rqp_cell, common_voc_cell, imsi, upm_sys_id, process_type
) VALUES (
  '${MDN}',
  '${LAT}',
  '${LON}',
  NULL,
  'Y',
  NULL,
  '${NOW_TS}',
  '${NOW_TS}',
  '${ADDR}',
  '${SYS_ID}',
  '${TID}',
  NULL,
  'Y',
  'S',
  '03',
  NULL,
  NULL,
  NULL,
  '${IMSI}',
  'UPM01',
  'RP'
);
"

    echo ""
    echo "▶ INSERT t_barod_sub_list"
    echo "MDN=${MDN}, IMSI=${IMSI}"
    echo "$SQL_SUB_LIST"
    echo "----------------------------------------------"

    echo "$SQL_SUB_LIST" | mysql -h "$MYSQL_HOST" \
                                -u "$MYSQL_USER" \
                                -p"$MYSQL_PASS" \
                                "$MYSQL_DB"

    MDN_NUM=$((MDN_NUM + 1))
    LAT=$(printf "%.5f" "$(echo "$LAT + 0.00001" | bc)")
    LON=$(printf "%.6f" "$(echo "$LON + 0.000001" | bc)")

  done < "$FILE"

done
echo "###################################################"
echo " 모든 파일 처리 완료"
echo "###################################################"