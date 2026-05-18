package my.paractice.socket;

import java.io.*;
import java.lang.reflect.Array;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.*;

public class PGSIM {
	private static final int PORT					=	10400;
	
	public static final int	INT_SIZE				=	4;
	public final String DEV_CHANGE			=	"ZC1";
	public final String INFO_CHANGE			=	"ZG1";
	public final String SKT_OUT				=	"ZZ1";
	public final String SYS_CODE			=	"IS0";
	
	public static final int IP_ADDR_SIZE			=	15;
	
	public static final int	JOB_CODE_SIZE			=	3+1;
	public static final int	SYSTEM_ID_SIZE			=	3+1;
	public static final int	TID_SIZE				=	16+1;
	public static final int	PG_MDN_SIZE				=	12+1;
	public static final int	TABLET_PC_YN			=	1+1;
	public static final int	OS_VERSION_SIZE			=	2+1;
	public static final int	TERMINAL_MODEL_CODE_SIZE=	4+1;
	public static final int	ZONE_SERVICE_CODE		=	4+1;
	public static final int	PGDATA_RESRVED_SIZE		=	2+1;
	public static final int	PGDATA_HEADER_SIZE		=	JOB_CODE_SIZE + SYSTEM_ID_SIZE + INT_SIZE;
	public static final int	PGDATA_BODY_SIZE		=	48;
		
	public static final int	SYS_NAME_SIZE			=	3+1;
	public static final int	HOST_NAME_SIZE			=	14+1;
	public static final int	REQUEST_TID_SIZE		=	16+1;
	public static final int	PMACK_HEADER_SIZE		=	JOB_CODE_SIZE + SYS_NAME_SIZE + INT_SIZE;
	public static final int	PMACK_BODY_SIZE			=	HOST_NAME_SIZE + REQUEST_TID_SIZE;

	public static final int DATE_SIZE		=	14;
		
	private ServerSocket server;
	private Socket client;
	
	private DataOutputStream toClientStream;
	private DataInputStream fromClientStream;
	
	private long TID;
	
	public PGSIM(){
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
	
	private void sendData(String jobCode) throws IOException{
		byte[] data = new byte[PGDATA_HEADER_SIZE + PGDATA_BODY_SIZE];
		
		//String jobCode = ZONE1_JOIN;
		String systemId = "PG0";
		//int bodySize =  PGDATA_BODY_SIZE;
		String tid;
		
		tid = String.valueOf(TID);
			
		String mdn = "01023896799";
		//String mdn = "01021467937";
		String tabletPcYn = "Y";
		String osVersion = "27";
		String terminalModelCode = "SSOH";
		String zoneServiceCode = "1125";
		
		System.arraycopy(jobCode.getBytes(), 0, data
				, 0, jobCode.length());
		System.arraycopy(systemId.getBytes(), 0, data
				, JOB_CODE_SIZE, systemId.length());
//		System.arraycopy((String.valueOf(bodySize)).getBytes(), 0, data
//				, JOB_CODE_SIZE + SYSTEM_ID_SIZE , 4);
		System.arraycopy(tid.getBytes(), 0, data
				, JOB_CODE_SIZE + SYSTEM_ID_SIZE + INT_SIZE, tid.length());
		System.arraycopy(mdn.getBytes(), 0, data
				, JOB_CODE_SIZE + SYSTEM_ID_SIZE + INT_SIZE + TID_SIZE, mdn.length());
		System.arraycopy(tabletPcYn.getBytes(), 0, data
				, JOB_CODE_SIZE + SYSTEM_ID_SIZE + INT_SIZE +TID_SIZE + PG_MDN_SIZE, tabletPcYn.length());
		System.arraycopy(osVersion.getBytes(), 0, data
				, JOB_CODE_SIZE + SYSTEM_ID_SIZE + INT_SIZE +TID_SIZE + PG_MDN_SIZE + TABLET_PC_YN, osVersion.length());
		System.arraycopy(terminalModelCode.getBytes(), 0, data
				, JOB_CODE_SIZE + SYSTEM_ID_SIZE + INT_SIZE +TID_SIZE + PG_MDN_SIZE + TABLET_PC_YN + OS_VERSION_SIZE, terminalModelCode.length());
		System.arraycopy(zoneServiceCode.getBytes(), 0, data
				, JOB_CODE_SIZE + SYSTEM_ID_SIZE + INT_SIZE +TID_SIZE + PG_MDN_SIZE + TABLET_PC_YN + OS_VERSION_SIZE + TERMINAL_MODEL_CODE_SIZE, zoneServiceCode.length());
		
		System.out.println("Send : ["+new String(data)+"]" );
		toClientStream.write(data);
		toClientStream.flush();
	}
	
	private void getAck() throws Exception{
		byte[] inbuffer = new byte[PMACK_HEADER_SIZE + PMACK_BODY_SIZE];

		int size;
		
		size = fromClientStream.read(inbuffer);
		
		if(size < 0){
			System.out.println("ReadWrong");
		}
		else{
//			System.out.println("read :"+size);
			byte[] jobCode = new byte[JOB_CODE_SIZE];
			System.arraycopy(inbuffer, 0, jobCode, 0, JOB_CODE_SIZE);
			String strJobCode = new String(jobCode);
			System.out.println("jobCode : ["+strJobCode+"]");
			
			byte[] sysname = new byte[SYS_NAME_SIZE];
			System.arraycopy(inbuffer, JOB_CODE_SIZE , sysname, 0, SYS_NAME_SIZE);
			System.out.println("SysName : ["+new String(sysname)+"]");
			
			byte[] bodySize = new byte[INT_SIZE];
			System.arraycopy(inbuffer, JOB_CODE_SIZE + SYS_NAME_SIZE, bodySize, 0, INT_SIZE);
			int bodysize = getBigEndian(bodySize);
			System.out.println("Body_size : ["+ bodysize+"]");
			
			byte[] hostName = new byte[HOST_NAME_SIZE];
			System.arraycopy(inbuffer, JOB_CODE_SIZE + SYS_NAME_SIZE + INT_SIZE, hostName, 0, HOST_NAME_SIZE);
			System.out.println("hostName : ["+ new String(hostName)+"]");
			
			byte[] tid = new byte[REQUEST_TID_SIZE];
			System.arraycopy(inbuffer, JOB_CODE_SIZE + SYS_NAME_SIZE + INT_SIZE + HOST_NAME_SIZE, tid, 0, REQUEST_TID_SIZE);
			String ss = new String(tid);
			ss = ss.substring(0, 16);
			
			if(strJobCode.contains(SYS_CODE)){
				this.TID = Long.parseLong(ss);
				System.out.println("Request TID : ["+ ss +"]");
			}
			else{
				System.out.println("TID : ["+ ss +"]");
			}
		}
	}
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		PGSIM sim = new PGSIM();

		Scanner scanner = new Scanner(System.in);
		String cin = null;
		sim.start();
		
		try {
			//sim.sendData(sim.ZONE1_JOIN);
		
			sim.getAck();
			while(true){
				System.out.print("Continue?(ic,dc,d,end OR JobCode) :");
				cin = scanner.next();
				
				sim.TID++;
				if(cin.equals("ic")){
					sim.sendData(sim.INFO_CHANGE);
				}
				else if(cin.equals("dc")){
					sim.sendData(sim.DEV_CHANGE);
				}
				else if(cin.equals("d")){
					sim.sendData(sim.SKT_OUT);
				}
				else if(cin.equals("end")){
					System.out.println("end!");
					break;
				}
				else{
					sim.sendData(cin);
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

	public static int getBigEndian(byte[] v)throws Exception{
		int[] arr = new int[4];
	    
		for(int i=0;i<4;i++){
	    	arr[i] = (int)(v[3-i] & 0xFF);
		}
	    return ((arr[0]  << 24) + (arr[1]  << 16) + (arr[2]  << 8) + (arr[3]  << 0));
	}
	public static final byte[] int2byte(int i)
    {
        byte dest[] = new byte[4];
        dest[3] = (byte)(i & 0xff);
        dest[2] = (byte)(i >>> 8 & 0xff);
        dest[1] = (byte)(i >>> 16 & 0xff);
        dest[0] = (byte)(i >>> 24 & 0xff);
        return dest;
    }
}
