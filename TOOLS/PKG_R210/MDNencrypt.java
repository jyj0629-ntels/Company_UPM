import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class MDNencrypt {
	private static String _key = "ZoneService12345";

	public static void main(String[] arg){
		String mdn = "";
		if(arg.length == 1){
			mdn = arg[0];
		} else {
			System.out.println("##############################################");
			System.out.println("[ERROR] Please Input Only One Parameter(MDN)");
			System.out.println("##############################################");
			System.exit(0);
		}
		try {
			System.out.println(encrypt(mdn));
		} catch (Exception e) {
			System.out.println("ENCRYPT ERROR");
		}
	}
    public static String byteArrayToHex(byte[] ba) {
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
    public static String encrypt(String message) throws Exception {
    	 SecretKeySpec skeySpec = new SecretKeySpec(_key.getBytes(), "AES");
        // Instantiate the cipher
        Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5PADDING");
        cipher.init(Cipher.ENCRYPT_MODE, skeySpec);

        byte[] encrypted = cipher.doFinal(message.getBytes());
        return byteArrayToHex(encrypted);
    }
}
