#!/bin/ksh
LAT=27.000000
LON=117.000000

for cell_id in {340000..355000}
do
	CELL_ID=$((cell_id + 1))
	LAT=$((LAT + 0.000001))
	LON=$((LON + 0.000001))
	TAC=$cell_id

	echo "cell_id : $cell_id / LAT : $LAT / LON : $LON / TAC : $TAC"
	ET=`date +%C%y%m%d%H%M%S`
	$MYSQL_HOME/bin/mysql -h 127.0.0.1 -uupm -pupm?4321? -s pm_test << EOF 
	INSERT INTO t_barod_cell_list (
					cell_info, 
					lon, 
					lat, 
					ta_code
					) 
				VALUES (
					'$CELL_ID:11', 
					$LON, 
					$LAT, 
					$TAC);
EOF
done
