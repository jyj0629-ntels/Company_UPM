#/bin/sh
if [ $# -ne 3 ]; then
        echo "### [ ERROR ] #######################################################"
        echo " Usage : ./pg_perm.sh START_MDN TPS AGING_TIME(Second)"
        echo "      Ex)./pg_perm.sh 10001000  10  3600"
	echo " AGING_TIME : 24 hour = 86400(24*60*60) / 12 hour = 43200(12*60*60)"
        echo "#####################################################################"
        exit
fi
 
START_MDN=$1
TPS=$2
AGING_TIME=$3
 
echo "## PG SIMULATOR START ] ########################################"
java -cp . my/paractice/socket/PGSIM_PERM $START_MDN $TPS $AGING_TIME
