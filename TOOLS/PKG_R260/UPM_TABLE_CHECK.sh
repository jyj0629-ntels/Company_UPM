#!/bin/bash
# MySQL 성능 및 환경 점검을 위한 쿼리 명령어 List

DB_A_IP="192.168.10.85"
DB_B_IP="192.168.10.86"
DATABASE_NAME="pm"
TABLE_SUB="t_barod_sub_list"
TABLE_CELL1="t_barod_cell_list"
TABLE_CELL2="t_barod_cell_list_1"

pmsqlA="$MYSQL_HOME/bin/mysql -uupm -pupm?4321? pm -h ${DB_A_IP}"
pmsqlB="$MYSQL_HOME/bin/mysql -uupm -pupm?4321? pm -h ${DB_A_IP}"

echo "===================================================================================="
echo "[$(date)] UPM DB Table Size Check"
echo " UPM Active : ${DB_A_IP} / UPM Standby : ${DB_B_IP}"
echo "####################################################################################"
echo "1) TABLE별 사용량 점검"
echo "####################################################################################"
echo " "
echo "------------------------------------------------------------------------------------"
echo " ${DB_A_IP} DB Table Size"
echo "------------------------------------------------------------------------------------"
$pmsqlA << EOF
SELECT 
    table_schema AS DB_Name,
    table_name AS Table_Name,
    table_rows AS Row_Count,
    ROUND(data_length / 1024 / 1024, 2) AS Data_MB,
    ROUND(index_length / 1024 / 1024, 2) AS Index_MB,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS Total_MB
FROM 
    information_schema.tables
WHERE 
    table_schema = '${DATABASE_NAME}'
ORDER BY 
    Total_MB DESC
LIMIT 10;
EOF
echo "------------------------------------------------------------------------------------"
echo " ${DB_B_IP} DB Table Size"
echo "------------------------------------------------------------------------------------"
$pmsqlB << EOF
SELECT 
    table_schema AS DB_Name,
    table_name AS Table_Name,
    table_rows AS Row_Count,
    ROUND(data_length / 1024 / 1024, 2) AS Data_MB,
    ROUND(index_length / 1024 / 1024, 2) AS Index_MB,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS Total_MB
FROM 
    information_schema.tables
WHERE 
    table_schema = '${DATABASE_NAME}'
ORDER BY 
    Total_MB DESC
LIMIT 10;
EOF

echo "####################################################################################"
echo "2) 주요 TABLE별 Index 점검 "
echo "  - t_barod_sub_list, t_barod_cell_list, t_barod_cell_list_1"
echo "  - t_barod_msg_hist, t_barod_rqp_hist"
echo "####################################################################################"