#/bin/sh

echo "## [ RESULT ] ####################################################################################"
cat /APPDATA/PM/ZONE_VOC/* | awk -F "," '{total+=$5}  END {print "TOTAL ODA Traffic = "total}'
cat /APPDATA/PM/ZONE_VOC/* | awk -F "," '{total+=$4}  END {print "SC1200            = "total}'
cat /APPDATA/PM/ZONE_VOC/* | awk -F "," '{total+=$6}  END {print "MDN Count         = "total}'
echo "##################################################################################################"
