#/bin/sh
if [ $# -ne 5 ]; then
        echo " ERROR ] ######################################################################################"
        echo "  Please 4 input parameter "
        echo "      : make_oda_traffic_sinario.sh START_MDN MDN_CNT FILE_DIV_CNT ZONE_AVP OTHER_STATUS_PERCENT"
        echo "  ex) ./make_oda_traffic_sinario.sh 10000001  100000  100          9100     10"
        echo "  Remark> If you want to make tps, TPS = MDN_CNT/FILE_DIV_CNT (1000tps = 100000/100)"
        echo "                                                              (2000tps = 100000/50)"
	echo "          OTHER_STATUS_PERCENT mean is if IN_OUT is IN, OUT Percent count"
	echo "          Ex) 9100(Zone In) 1000 tps 90% : 900 In / 100 Out"
        echo " ##############################################################################################"
        exit
fi

START_MDN="10${1}"
CNT=$2
FILE_DIV_CNT=$3
AVP=$4
PERCENT=$5

MDN=$START_MDN
 
TPS=`expr $CNT / $FILE_DIV_CNT`
OTHER_CNT=`expr $TPS \* $PERCENT / 100`
FILENAME="./ODA_DATA/"$TPS"tps_"$PERCENT"_percent"

rm -rf *.dat

if [ ! -d $FILENAME ]; then
	mkdir $FILENAME
fi

if [ ${#START_MDN} -ne 10 ]; then
        echo " ERROR ] ######################################################################################"
        echo " Please check START_MDN : START_MDN Length must be 8 digit "
        echo " ##############################################################################################"
        exit
else
	echo ""
	echo " START ] ##########################################################################################"
	echo " START MDN : 0$START_MDN / FILE_DIV : $FILE_DIV_CNT / TPS : $TPS / OTHER_STATUS_CNT : $OTHER_CNT"
        echo " ##################################################################################################"
fi
 
for ((i=1; i<=$FILE_DIV_CNT; i++)); do
        for ((j=0; j<$TPS; j++)); do
		if [ $j -lt $OTHER_CNT ]
		then
			if [ ${AVP} -eq "9100" ]; then
                		echo "0$MDN,172.21.31.168,9200000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $FILENAME"/"$i"_IN.dat"
                		echo "0$MDN,172.21.31.168,9100000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $FILENAME"/"$i"_OUT.dat"
			else
                		echo "0$MDN,172.21.31.168,9200000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $FILENAME"/"$i"_IN.dat"
                		echo "0$MDN,172.21.31.168,9100000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $FILENAME"/"$i"_OUT.dat"
			fi
		else
                	echo "0$MDN,172.21.31.168,${AVP}000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $FILENAME"/"$i"_IN.dat"
                	echo "0$MDN,172.21.31.168,${AVP}000000000S,L,C,99990,1,lte,0,192.168.0.10" >> $FILENAME"/"$i"_OUT.dat"
		fi
                MDN=`expr $MDN + 1`
        done
	echo " $i FILE COMPLETED !!! Please wait!"
done
END_MDN=`expr $MDN - 1`
echo ""
echo "# [ Working Complete ] ##############################################################"
echo " 1) MDN RANGE : 010$START_MDN ~ 010${END_MDN} / Subscriber Count : $CNT"
echo " 2) File Count : $FILE_DIV_CNT [EA]"
echo " 3) TPS : $TPS"
echo " 4) RAW DATA DIRECTORY : $FILENAME"
echo "#####################################################################################"
echo ""
