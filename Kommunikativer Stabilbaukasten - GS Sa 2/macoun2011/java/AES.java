package helpers;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;

/**
 * A helper class to do AES encryption
 * @author pascal
 *
 */
public abstract class AES {


	
	/**
	 * Encrypts a string using AES-128-ECB and Base64
	 * 
	 * @param clear the clear string to encrypt
	 * @param key	the 16-bytes encryption key
	 * @return	the encrypted string or <code>null</code> on error
	 */
	public static String encrypt(String clear, byte[] key) {
		if (key == null)
			return clear;
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
	
			return new String(Base64.encodeBase64(encryptedData));
		
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	/**
	 * Decrypts a string using AES-128-ECB and Base64
	 * 
	 * @param encrypted the encrypted string to decrypt
	 * @param key	the 16-bytes decryption key
	 * @return	the decrypted string or <code>null</code> on error
	 */
	public static String decrypt(String encrypted, byte[] key) {
		if (key == null)
			return null;
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
	
			return new String(decryptedData);
		
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	
	}
}
	
