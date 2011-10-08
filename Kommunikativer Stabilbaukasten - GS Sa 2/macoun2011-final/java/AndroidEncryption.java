
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Random;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;


/**
 * A helper class to do RSA and AES encryption
 * @author pascal
 *
 */
public class AndroidEncryption {

	private static AndroidEncryption sharedInstance;
	X509Certificate trustedCert;
	Cipher encryptCipher;
	
	byte[] key = new byte[16];
	
	private AndroidEncryption() { // private encryption
		Random rand = new Random();
		rand.nextBytes(key); // generate random key for AES encryption
	}
	
	/**
	 * Creates the new singleton
	 * @return the singleton for decryption
	 */
	public static AndroidEncryption sharedInstance() {
		if (sharedInstance == null)
			sharedInstance = new AndroidEncryption();
		return sharedInstance;
	}
	
	/**
	 * Encrypt AES  using the servers private key
	 * 
	 * @param cryptedMessage	the encrypted message
	 * @return	the encrypted key
	 */
	public String encryptedAESKeyWithPublicKey() {
		try {			 
			 if ((trustedCert ==  null) || (encryptCipher == null)) {

			     CertificateFactory cf = CertificateFactory.getInstance("X.509");
			     trustedCert = (X509Certificate) cf.generateCertificate(Application.getInstance().getResources().openRawResource(R.raw.encryption));
			     encryptCipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
			 }     
   
		     encryptCipher.init(Cipher.ENCRYPT_MODE,trustedCert.getPublicKey());
	
		     byte[] messageEncrypte = encryptCipher.doFinal(key);
		     byte[] encoded = Base64.encodeBase64(messageEncrypte);
		     // make string out of the bye array (simple new String(...) crashes sometimes...)
		     String encodedString = stringFromByteArray(encoded);
		     return encodedString;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	private String stringFromByteArray(byte[] encoded) {
		StringBuffer encodedString =  new StringBuffer(encoded.length);
		 for (int i = 0; i < encoded.length; i++) {
			 encodedString.append((char) encoded[i]);
		 }
		return encodedString.toString();
	}
	
	/**
	 * Encrypts a string using AES-128-ECB and Base64
	 * 
	 * @param clear the clear string to encrypt
	 * @return	the encrypted string or <code>null</code> on error
	 */
	public String encrypt(String clear) {
		if (clear == null)
			return null;
		
		try {
			Cipher c = Cipher.getInstance("AES");
			SecretKeySpec k =
			  new SecretKeySpec(key, "AES");
			c.init(Cipher.ENCRYPT_MODE, k);
			byte[]  encryptedData = c.doFinal(clear.getBytes());
			
			if (encryptedData == null)
				return null;
	
			return stringFromByteArray(Base64.encodeBase64(encryptedData));
		
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * Decrypts a string using AES-128-ECB and Base64
	 * 
	 * @param encrypted the encrypted string to decrypt
	 * @return	the decrypted string or <code>null</code> on error
	 */
	public String decrypt(String encrypted) {
		if (encrypted == null)
			return null;
		
		try {
			Cipher c = Cipher.getInstance("AES");
			SecretKeySpec k =
			  new SecretKeySpec(key, "AES");
			c.init(Cipher.DECRYPT_MODE, k);
			byte[]  decryptedData = c.doFinal(Base64.decodeBase64(encrypted.getBytes()));
			
			if (decryptedData == null)
				return null;
	
			return stringFromByteArray(decryptedData);
		
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
		
}
