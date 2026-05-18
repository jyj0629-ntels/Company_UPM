import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class getUserSimulator {
private static String _path = "127.0.0.1";

 private static long _timelog = 0L;
 private static long _cnt = 0L;
 private static int _tps = 2000;
private static ExecutorService EXECUTOR_SERVICE = null;

 public static void main(String[] arg){

  if(arg.length != 5) {
	System.out.println("############################################################################");
	System.out.println("Error>>>>>> Please input parameter");
	System.out.println("Format) java -cp . getUserSimulator SERVER_IP START_MDN(7) END_MDN(7) threadCnt TPS");
	System.out.println("Ex) java -cp . getUserSimulator 192.168.10.192 10000000 1000100 5 10");
	System.out.println("############################################################################");

	System.exit(0);
  } 
  _path = arg[0];
  int startMdn = Integer.parseInt(arg[1]);
  int endMdn = Integer.parseInt(arg[2]);
  String threadCnt = arg[3];
  String tpsStr = arg[4];

  String tempStartMdn = "0101"+String.format("%07d",startMdn);
  String tempEndMdn = "0101"+String.format("%07d",endMdn);

  System.out.println("####################################################################################");
  System.out.println("API SIMULATOR START ["+new Date().toString()+"]");
  System.out.println("\tAPI SIMULATOR PARAMETER ");
  System.out.println("\tServer IP : " + _path);
  System.out.println("\tStart MDN : " + tempStartMdn); 
  System.out.println("\tEnd MDN   : " + tempEndMdn); 
  System.out.println("\tThread    : " + threadCnt); 
  System.out.println("\tTPS       : " + tpsStr); 
  System.out.println("####################################################################################");
  EXECUTOR_SERVICE = Executors.newFixedThreadPool(Integer.parseInt(threadCnt));
  _tps = Integer.parseInt(tpsStr);
  try {
   _timelog = getTime();
   for(int cnt = startMdn ; cnt <= endMdn ; cnt++){
    while(true){
     float duration = getTime()-_timelog;
     if(duration == 0 || _cnt == 0){
      break;
     }
     int tps = (int) (_cnt/(duration/1000));
     if(tps < _tps){
      break;
     }
     Thread.sleep(100);
    }
    String urlStr = "http://"+_path+"/api/10/A/getUser?device=hlteskt&bsp_result=&device_model=SM-N900S&pg_proc_id=DS&pg_host=PG53&os=Android5.0&ver=1.9.3&mdn=";
    String mdn = "0101"+String.format("%07d",cnt);

    RequestAPI checkStatus = new RequestAPI(urlStr, mdn);
    EXECUTOR_SERVICE.execute(checkStatus);
    _cnt++;    

    //urlStr = "http://"+_path+"/api/10/A/updatePushStatus?mdn=";
    //RequestAPI updateStatus = new RequestAPI(urlStr, mdn);
    //EXECUTOR_SERVICE.execute(updateStatus);
    //_cnt++;
   }
EXECUTOR_SERVICE.shutdown();
   while (!EXECUTOR_SERVICE.isTerminated()) {
    Thread.sleep(1);
   }
   EXECUTOR_SERVICE = null;
  } catch (Exception e) {
   e.printStackTrace();
  }

  System.out.println("API SIMULATOR END ["+new Date().toString()+"] Running Time : "+(getTime()-_timelog)+"ms, Total API Call Counnt : "+_cnt);
 }
 private static long getTime(){
  return new Date().getTime();
 }
}

class RequestAPI implements Runnable{
 private static String _key = "ZoneService12345";

 private String _mdn;
 private String _apiUrl;

 public RequestAPI(String apiUrl, String mdn){
  _apiUrl = apiUrl;
  _mdn = mdn;
 }

 @Override
 public void run() {
  try{
   send(_apiUrl+encrypt(_mdn));
  }catch(Exception e){
   System.out.println("REQUEST ERROR");
   e.printStackTrace();
  }
 }
public String send(String apiUrl) throws Exception {
  String resultCode = "";
  HttpURLConnection conn = null;
  StringBuffer stringBufferResult = new StringBuffer();

  try {
   URL url = new URL(apiUrl);
   conn = (HttpURLConnection) url.openConnection();

   conn.setConnectTimeout(1000);
   conn.setReadTimeout(1000);
   conn.setDoOutput(true);
   conn.setDoInput(true);
   conn.setUseCaches(false);
   conn.setDefaultUseCaches(false);

   int nResponseCode = conn.getResponseCode();
   resultCode = ""+nResponseCode;
   if (nResponseCode == HttpURLConnection.HTTP_OK) {
    BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
    String readLine = null;
    while ((readLine = reader.readLine()) != null) {
     stringBufferResult.append(readLine);
    }
    reader.close();
    reader = null;
   }
   else {
    return ""+nResponseCode;
   }

  } catch (Exception e) {
   throw e;
  } finally {
   if(!"200".equals(resultCode)){
    System.out.println(new Date().toString()+" "+String.format("%-90s", apiUrl)+" >> "+resultCode);
   }
   if(conn != null) {
     conn.disconnect();
     conn = null;
    }
  }
  return stringBufferResult.toString();
 }

 public String byteArrayToHex(byte[] ba) {
  if (ba == null || ba.length == 0) {
   return null;
  }
  StringBuffer sb = new StringBuffer(ba.length * 2);
  String hexNumber;
  for (int x = 0; x < ba.length; x++) {
   hexNumber = "0" + Integer.toHexString(0xff & ba[x]);

   sb.append(hexNumber.substring(hexNumber.length() - 2));
  }
  return sb.toString();
 }

 public String encrypt(String message) throws Exception {
   SecretKeySpec skeySpec = new SecretKeySpec(_key.getBytes(), "AES");
  Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5PADDING");
  cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
  byte[] encrypted = cipher.doFinal(message.getBytes());
  return byteArrayToHex(encrypted);
 }
}
