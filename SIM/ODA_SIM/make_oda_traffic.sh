#/bin/sh
if [ $# -ne 6 ]; then
        echo " ERROR ] ######################################################################################"
        echo "  Please 4 input parameter "
        echo "      : make_oda_traffic.sh START_MDN MDN_CNT FILE_DIV_CNT ZONE_AVP IN_OUT OTHER_STATUS_PERCENT"
        echo "  ex) ./make_oda_traffic.sh 10000001  100000  100          9100     IN     10"
        echo "  Remark> If you want to make tps, TPS = MDN_CNT/FILE_DIV_CNT (1000tps = 100000/100)"
        echo "                                                              (2000tps = 100000/50)"
	echo "          OTHER_STATUS_PERCENT mean is if IN_OUT is IN, OUT Percent count"
	echo "          Ex) IN 1000 tps 10% : 900 In / 100 Out"
        echo " ##############################################################################################"
        exit
fi
 
START_MDN="10${1}"
CNT=$2
FILE_DIV_CNT=$3
AVP=$4
FILENAME="${5}.dat"
PERCENT=$6
 
if [ ${#START_MDN} -ne 10 ]; then
        echo " ERROR ] ######################################################################################"
        echo " Please check START_MDN : START_MDN Length must be 8 digit "
        echo " ##############################################################################################"
        exit
fi
 
MDN=$START_MDN
 
TPS=`expr $CNT / $FILE_DIV_CNT`
OTHER_CNT=`expr $TPS \* $PERCENT / 100`

rm -rf *.dat

for ((i=1; i<=$FILE_DIV_CNT; i++)); do
        for ((j=0; j<$TPS; j++)); do
		if [ $j -lt $OTHER_CNT ]
		then
			if [ ${AVP} -eq "9100" ]; then
                		echo "0$MDN,172.21.31.168,9200000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $i"_"$FILENAME
			else
                		echo "0$MDN,172.21.31.168,9100000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $i"_"$FILENAME
			fi
		else
                	echo "0$MDN,172.21.31.168,${AVP}000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $i"_"$FILENAME
		fi
                MDN=`expr $MDN + 1`
        done
done
END_MDN=`expr $MDN - 1`
echo "# [ Working Complete ] ##############################################################"
echo " 1) MDN RANGE : 010$START_MDN ~ 010${END_MDN} / Subscriber Count : $CNT"
echo " 2) File Count : $FILE_DIV_CNT [EA]"
echo " 3) TPS : $TPS"
echo "#####################################################################################"
