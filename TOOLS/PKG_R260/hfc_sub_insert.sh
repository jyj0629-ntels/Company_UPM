#!/bin/bash

rm -rf insert_data.sql

# MySQL d
DB_USER="upm"
DB_PASSWORD="upm?1234"
DB_NAME="pm"

MIN_LAT=37.47645
MAX_LAT=37.66470
MIN_LON=126.8146
MAX_LON=127.1280

random_float() {
  min=$1
  max=$2
  echo "$(awk -v min=$min -v max=$max 'BEGIN{srand(); print min+(rand()*(max-min))}')"
}


SQL_FILE="insert_data.sql"

#   SQL   
#for i in {1..140000}
for i in {1..96000}
do
    PRD_TYPE=$(( $i % 5 ))

    PHONE_NUMBER=$(printf "01010%06d" $((100000 + i)))
    LATITUDE=$(random_float $MIN_LAT $MAX_LAT)
    LONGITUDE=$(random_float $MIN_LON $MAX_LON)
    CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    ADDRESS="서울시 양천구 목1동   0${i}-${i} ${i}"

    if (( $i % 3 == 0 )); then
        DEVICE_TYPE="L"
    elif (( $i % 3 == 1 )); then
        DEVICE_TYPE="N"
    else
        DEVICE_TYPE="S"
    fi
   
    case $PRD_TYPE in 
      0) 
        PRODUCT_TYPE="01"
        ;;
      1)  
        PRODUCT_TYPE="03"
        ;;
      2)  
        PRODUCT_TYPE="04"
        ;;
      3)  
        PRODUCT_TYPE="10"
        ;;
      4)  
        PRODUCT_TYPE="05"
        ;;
    esac
   

    echo "INSERT INTO t_barod_sub_list (mdn, lat, lon, send_Yn, event_timestamp, addr, sys_id, use_yn, device_type, product_type) VALUES ('$PHONE_NUMBER', $LATITUDE, $LONGITUDE, 'Y', '$CURRENT_TIME', '$ADDRESS', 'UPM51', 'Y', '$DEVICE_TYPE', '$PRODUCT_TYPE');" >> $SQL_FILE
done

# MySQL MYSQL_HOME/bin/mysql -u${DB_USER} -p${DB_PASSWORD} -s ${DB_NAME} < $SQL_FILE

echo "10   "
