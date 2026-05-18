package my.paractice.socket;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Pattern;

import javax.net.ssl.HostnameVerifier;

public class PGSIM {
	private static final int PORT					=	10500;
	public static final int DATE_SIZE				=	14;
	
	public static final String [] jobCodes = {"NH1","NH3","NHG","NY3","NJ3","NIC","NI8","NIO","NR3","NR7"};
	public static final String IDLE_CHECK			=	"HBR";
	public static final String TEST_JOB_CODE		=	"NCN";
	public static final String DAY					=	"D";
	public static final String MONTH				=	"M";
	
	
	//COMMON DATA SIZE DEFINE
	public static final int	JOB_CODE_SIZE			=	3+1;
	public static final int	BODY_SIZE_SIZE			=	3+1;
	public static final int	TID_SIZE				=	16+1;
	
	//NCN DATA SIZE DEFINE
	public static final int	SYS_NAME_SIZE		=	3+1;

		
	//PG DATA SIZE DEFINE
	public static final int	SYS_ID_SIZE				=	3+1;
	public static final int	HOST_NAME_SIZE			=	14+1;
	public static final int	MDN_SIZE				=	12+1;
	public static final int	RESET_FLAG_SIZE			=	1+1;
	public static final int	CODE_TYPE_SIZE			=	7+1;
	public static final int	UKEY_TIME_SIZE			=	15+1;
	
	public static final int	NCNDATA_SIZE = JOB_CODE_SIZE + SYS_NAME_SIZE + BODY_SIZE_SIZE + HOST_NAME_SIZE + TID_SIZE;
	public static final int	PGDATA_SIZE	= JOB_CODE_SIZE + SYS_ID_SIZE + BODY_SIZE_SIZE + TID_SIZE + MDN_SIZE + RESET_FLAG_SIZE + CODE_TYPE_SIZE + UKEY_TIME_SIZE;
	
	private ServerSocket server;
	private Socket client;
	private Calendar cal;
	private Date date;
	private String nowTime;
	private long mdn;
	
	private DataOutputStream toClientStream;
	private DataInputStream fromClientStream;
	
	private static long TID;
	
	public PGSIM(){
		date = new Date();
		cal = Calendar.getInstance();
		try {
			server = new ServerSocket(PORT);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	private void start(){
		try {
			System.out.println("Server is waiting at "+PORT);
			client = server.accept();
			System.out.println(client.getInetAddress() + " accepted");
			toClientStream = new DataOutputStream(client.getOutputStream());
			fromClientStream = new DataInputStream(client.getInputStream());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void sendData(String jobCode, String resetFlag, String codeType, String tid, String mdn) throws IOException{
		byte[] data = new byte[PGDATA_SIZE];
		
		String systemId = "01";
		String bodySize = "28";
		
		if (mdn == null)
			mdn = "01011112222";
		
		cal = Calendar.getInstance();
		date = cal.getTime();
		nowTime = new SimpleDateFormat("yyyyMMddHHmmss").format(date);
		
		
		System.arraycopy(jobCode.getBytes(), 0, data
				, 0, jobCode.length());
		System.arraycopy(systemId.getBytes(), 0, data
				, JOB_CODE_SIZE, systemId.length());
		System.arraycopy(bodySize.getBytes(), 0, data
				, JOB_CODE_SIZE+SYS_ID_SIZE, bodySize.length());
		System.arraycopy(tid.getBytes(), 0, data
				, JOB_CODE_SIZE + SYS_ID_SIZE + BODY_SIZE_SIZE, tid.length());
		System.arraycopy(mdn.getBytes(), 0, data
				, JOB_CODE_SIZE + SYS_ID_SIZE + BODY_SIZE_SIZE + TID_SIZE, mdn.length());
		System.arraycopy(resetFlag.getBytes(), 0, data
				, JOB_CODE_SIZE + SYS_ID_SIZE + BODY_SIZE_SIZE + TID_SIZE + MDN_SIZE, resetFlag.length());
		System.arraycopy(codeType.getBytes(), 0, data
				, JOB_CODE_SIZE + SYS_ID_SIZE + BODY_SIZE_SIZE + TID_SIZE + MDN_SIZE + RESET_FLAG_SIZE, codeType.length());
		System.arraycopy(nowTime.getBytes(), 0, data
				, JOB_CODE_SIZE + SYS_ID_SIZE + BODY_SIZE_SIZE + TID_SIZE + MDN_SIZE + RESET_FLAG_SIZE + CODE_TYPE_SIZE, nowTime.length());
		
		
		System.out.println("Send : ["+new String(data)+"]" );
		toClientStream.write(data);
		toClientStream.flush();
	}
	
	
	private void getAck() throws Exception{
		byte[] inbuffer = new byte[NCNDATA_SIZE];

		int size;
		
		size = fromClientStream.read(inbuffer);
		
		if(size < 0){
			System.out.println("ReadWrong");
		}
		else{
//			System.out.println("read :"+size);
			byte[] jobCode = new byte[JOB_CODE_SIZE];
			System.arraycopy(inbuffer, 0, jobCode, 0, JOB_CODE_SIZE);
			System.out.println("jobCode : ["+new String(jobCode)+"]");
			
			byte[] sysname = new byte[SYS_NAME_SIZE];
			System.arraycopy(inbuffer, JOB_CODE_SIZE , sysname, 0, SYS_NAME_SIZE);
			System.out.println("SysName : ["+new String(sysname)+"]");
			
			byte[] bodySize = new byte[BODY_SIZE_SIZE];
			System.arraycopy(inbuffer, JOB_CODE_SIZE + SYS_NAME_SIZE, bodySize, 0, BODY_SIZE_SIZE);
			System.out.println("BodySize : ["+ new String(bodySize)+"]");
			
			byte[] hostName = new byte[HOST_NAME_SIZE];
			System.arraycopy(inbuffer, JOB_CODE_SIZE + SYS_NAME_SIZE + BODY_SIZE_SIZE, hostName, 0, HOST_NAME_SIZE);
			System.out.println("hostName : ["+ new String(hostName)+"]");
			
			byte[] tid = new byte[TID_SIZE];
			System.arraycopy(inbuffer, JOB_CODE_SIZE + SYS_NAME_SIZE + BODY_SIZE_SIZE + HOST_NAME_SIZE, tid, 0, TID_SIZE);
			String ss = new String(tid);
			if(ss.isEmpty() || ss == null){
				System.out.println("Request TID Null");
			}
			else{
				ss = ss.substring(0, 16);
				TID = Long.parseLong(ss);
				System.out.println("Request TID : ["+ TID +"]");
				TID++;
			}
		}
	}
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		PGSIM sim = new PGSIM();
		String tid = null;
		Scanner scanner = new Scanner(System.in);
		String cin = null;
		String codetype = null;
		String jobcode = null;
		String mdn = null;
		String cnt = null;
		sim.start();
		
		try {
			sim.getAck();
			
			while(true){
				System.out.print("JobCode(H:HBR, E:END O:SendOne M:SendMany): ");
				cin = scanner.next();
				
				if(cin.equals("E")){
					break;
				}
				
				else if(cin.equals("h")){
					tid = String.valueOf(TID);
					sim.sendData(IDLE_CHECK, "","", tid, null);
					sim.getAck();
				}
				else if(cin.equals("o")){
					System.out.print("jobCode : ");
					jobcode = scanner.next();
					System.out.print("codeType : ");
					codetype = scanner.next();
					System.out.print("MDN : ");
					mdn = scanner.next();
					
					tid = String.valueOf(TID);
					sim.sendData(jobcode, MONTH, codetype, tid, mdn);
					sim.getAck();
				}
				else if(cin.equals("m")){
					System.out.print("mdn band ex:10000000): ");
					sim.mdn = Long.valueOf(scanner.next());

					System.out.print("count : ");
					cnt = scanner.next();

					for(int i=0; i<Integer.valueOf(cnt); i++){
						tid = String.valueOf(TID);
						sim.sendData(jobCodes[sim.getRandom()], MONTH, "0", tid, sim.getSeqPhonNum());
						sim.getAck();
					}
//					tid = String.valueOf(++TID);	
//					sim.sendData(jobcode, MONTH, "0", tid, sim.getSeqPhonNum());
//					sim.getAck();
				}
				else{
					System.out.println("wrong input");
				}
			}
			
			sim.toClientStream.close();
			sim.fromClientStream.close();
			sim.client.close();
			sim.server.close();
		}
		catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public boolean isNumeric(String s) { 
	    java.util.regex.Pattern pattern = Pattern.compile("[+-]?\\d+"); 
	    return pattern.matcher(s).matches(); 
	}
	public String getRandomPhonNum(){
        int min = 10000000;
        int max = 100000000;
 
        int result = (int) (Math.random() * (max - min + 1)) + min;
        return "010" + String.valueOf(result); 
    }
	public String getSeqPhonNum(){
		mdn++;
        return "010" + String.valueOf(mdn); 
    }
	public int getRandom(){
		
        return (int)(Math.random()*10)%jobCodes.length; 
    }
}
