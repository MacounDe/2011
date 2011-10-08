package helpers;

import java.io.FileInputStream;
import java.io.IOException;
import java.security.KeyStore;

import javax.crypto.Cipher;
import javax.servlet.ServletContext;

import org.apache.commons.codec.binary.Base64;

import play.vfs.VirtualFile;

/**
 * A helper class to do RSA encryption
 * @author pascal
 *
 */
public class RSA {

	private static RSA sharedInstance;
	KeyStore keyStore;
	
    static final char[] passParse = "blabla".toCharArray(); 
	
	private RSA() { // private encryption
	}
	
	/**
	 * Creates the new singleton
	 * @return the singleton for decryption
	 */
	public static RSA sharedInstance() {
		if (sharedInstance == null)
			sharedInstance = new RSA();
		return sharedInstance;
	}

	/**
	 * Decrypts a message using the servers private key
	 * 
	 * @param cryptedMessage	the encrypted message
	 * @return	the decrypted message
	 */
	public byte[] decryptWithPrivateKey(String cryptedMessage) {
		try {
			 if (cryptedMessage == null)
				 return null;
			 
			 if (keyStore ==  null) {
				 
			     keyStore = KeyStore.getInstance("PKCS12");
			     
	
			     keyStore.load(new FileInputStream(VirtualFile.fromRelativePath("/conf/encryption.p12").getRealFile()), passParse);
			 }     
	
		     byte[] messageCrypte = Base64.decodeBase64(cryptedMessage.getBytes());
	
		     
		     Cipher decryptCipher = Cipher.getInstance("RSA");
		     decryptCipher.init(Cipher.DECRYPT_MODE,keyStore.getKey("MacRunners Encryption Key",passParse));
	
		     byte[] messageDecrypte = decryptCipher.doFinal(messageCrypte);
		     return messageDecrypte;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
		
}
