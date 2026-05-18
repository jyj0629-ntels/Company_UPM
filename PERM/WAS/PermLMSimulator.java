import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;


public class PermLMSimulator {
 private static java.sql.Connection _dbConn = null;
 private static String _dbInfo = "jdbc:mysql://127.0.0.1:3306/pm";
 private static String _dbID = "upm";
 private static String _dbPW = "upm?4321?";
 private static long _lm_if_id = 0L;
 
 private static String[] _zoneID = {"10000001", "10000002", "10000003", "10000004"};
 private static String[] _zoneName = {"SUBWAYFREE", "JEJUFREE", "CAMPUSFREE", "SHIFREE"};
 private static String[] _zonePriority = {"C", "A", "B", "Z"};
 
 private static long _timelog = 0L;
 private static long _cnt = 1L;
 private static int _tps = 2000;

 public static void main(String[] arg){
  String zoneType = "91000000000";
  String deviceIP = "127.0.0.1";
  String mdnCnt = "1";
  String repeatCnt = "1";
  String tpsCnt = "2000";  
  try{
   if(arg.length < 4){
    throw new Exception("SIMULATOR PARAMETER ERROR");
   }
   zoneType = arg[0];
   deviceIP = arg[1];
   mdnCnt = arg[2];
   _tps = Integer.parseInt(arg[3]);
   repeatCnt = arg[4];

   if(!zoneType.contains("1") && !zoneType.contains("2")){
    throw new Exception("ZONE TYPE ERROR ["+zoneType+"]");
   }
  }catch(Exception e){
   System.out.println("PARAMETER ERROR >> "+e.getMessage());
   return ;
  }
  System.out.println("PARAMETER : ZONE INFO="+zoneType+", DEVICE IP="+deviceIP+", MDN COUNT="+mdnCnt+", TPS="+_tps);
  try{
   Class.forName("com.mysql.jdbc.Driver");
   _dbConn = java.sql.DriverManager.getConnection(_dbInfo, _dbID, _dbPW);
   System.out.println("DB CONNECTION OPEN \t: "+_dbConn.getCatalog()+" ["+getNow()+"]");
   getIFID();
   
   HashMap<String, String> lmInfo = makeLI(zoneType, deviceIP);
   int repeat = Integer.parseInt(repeatCnt);
   int maxCnt = Integer.parseInt(mdnCnt);
   _timelog = getTime();
   

   for(int i=0 ; i<repeat ; i++){
    for(int cnt = 0 ; cnt < maxCnt ; cnt++){
     while(true){
      float duration = getTime()-_timelog;
      if(duration == 0){
       break;
      }
      int tps = (int) (_cnt/(duration/1000));
      if(tps < _tps){
       break;
      }
      Thread.sleep(100);
     }
     insertLI("0101"+String.format("%07d",(cnt+1)), lmInfo);
    }
    System.out.println("\t"+(i+1)+" times : "+new Date().toString());
    Thread.sleep(200);

   }
   
   _dbConn.close(); 
   System.out.println("DB CONNECTION CLOSE \t: "+_dbConn.getCatalog()+" ["+getNow()+"]");
  }catch(Exception e){
   System.out.println("ERROR >> "+e.getMessage());
  }
 }

 private static void insertLI(String mdn, HashMap<String, String> data) throws Exception{
  Class.forName("com.mysql.jdbc.Driver");
  long ifID = _lm_if_id;
  ifID = ifID + 1L;
  
  java.sql.Statement stmt = _dbConn.createStatement();
  String dbCommand = "INSERT INTO T_PM_LM_IF( PROC_ID, IF_ID, EVENT_REG_DATE, EVENT_REG_TIME, TASK_CODE, DEVICE_MDN, "
    + "DEVICE_OS_CODE, ZONE_ID, ZONE_NAME, ZONE_IN_OUT, ZONE_PRIORITY, PGW_IP, NETWORK_TYPE, "
    + "CELL_TYPE, CELL_ID, CELL_INFO, ODA_NAME, ZONE_COUNT, LATENCY_TIME, DEVICE_IP, RESULT_CODE, REG_DATETIME )"
    + "VALUES( "
    + "'LI01', '"+String.valueOf(ifID)+"', '"+getNowDate()+"', '"+getNowTime()+"', 'LM10', '"+mdn+"', "
    + "'26', '"+data.get("zone_id")+"', '"+data.get("zone_name")+"', '"+data.get("zone_io")+"', '"+data.get("zone_priority")+"', '172.21.31.168', 'L', "
    + "'3', '25597443', '99990:0', 'ODA03_A', '1', '"+String.valueOf(new Date().getTime())+"', '"+data.get("device_ip")+"', 'SC0000', NOW() )";
  stmt.executeUpdate(dbCommand);
  
  _lm_if_id = ifID;
  _cnt += 1L;
 }
 private static void getIFID(){
  try{
   java.sql.Statement stmt = _dbConn.createStatement();
   String selectLastLMIFID = "SELECT IFNULL(MAX(IF_ID), CONCAT(DATE_FORMAT(NOW(), '%Y%m%d'), '00000000')) AS IF_ID "
     + "FROM T_PM_LM_IF WHERE IF_ID > CONCAT( DATE_FORMAT(NOW(), '%Y%m%d'), '00000000')";
   ResultSet rs = stmt.executeQuery(selectLastLMIFID);
   rs.first();
   long ifID = Long.parseLong(rs.getString("IF_ID"));
   System.out.println("LAST LM IF_ID = "+rs.getString("IF_ID"));
   _lm_if_id = ifID;

   rs.close();
  }catch(Exception e){
   e.printStackTrace();
  }
 }

 private static HashMap<String, String> makeLI(String zoneType, String deviceIP) throws Exception{
  HashMap<String, String> map = new HashMap<String, String>();
  String zoneID = "";
  String zoneName = "";
  String zonePriority = "";
  String zoneIO = "";
  
  String[] avp = zoneType.split("");
  
  for(int idx=2 ; idx<avp.length ; idx++){
   if(!"0".equals(avp[idx])){
    zoneID += _zoneID[idx-2]+"_";
    zoneName += _zoneName[idx-2]+"_";
    zonePriority += _zonePriority[idx-2]+"_";
    
    if("1".equals(avp[idx])){
     zoneIO += "I_";
    }else{
     zoneIO += "O_";
    }
   }
  }
  
  if("".equals(zoneID)){
   throw new Exception("ZONE TYPE ERROR");
  }
  
  map.put("zone_id", zoneID.substring(0, zoneID.length()-1));
  map.put("zone_name", zoneName.substring(0, zoneName.length()-1));
  map.put("zone_priority", zonePriority.substring(0, zonePriority.length()-1));
  map.put("zone_io", zoneIO.substring(0, zoneIO.length()-1));
  map.put("device_ip", deviceIP);
  
  return map;
 }
 private static String getNowDate() {
  SimpleDateFormat formatDate = new SimpleDateFormat("yyyyMMdd");
  String date = formatDate.format(new Date().getTime());

  return date;
 }
 private static String getNowTime() {
  SimpleDateFormat formatTime = new SimpleDateFormat("HHmmss");
  String time = formatTime.format(new Date().getTime());

  return time;
 }
 private static String getNow() {
  SimpleDateFormat formatTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
  String time = formatTime.format(new Date().getTime());

  return time;
 }
 private static long getTime(){
  return new Date().getTime();
 }
}
