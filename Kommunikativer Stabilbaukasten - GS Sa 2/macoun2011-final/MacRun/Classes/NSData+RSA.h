//
//  NSData+RSA.h
//  encryptionStuff
//
//  Created by Pascal Bihler on 15.10.10.
//  Source: http://stackoverflow.com/questions/7441306/ios-rsa-encryption-ciphertext-length-alters-between-63-bytes-and-64-bytes

/**
 @brief allows asymmetric Data encryption using the RSA algorithm
 */
@interface NSData (RSA)

/**
 @brief		Encrypts a chunk of data using RSA public key
 @param		path	The Path to the certificate with the public key
 @returns	the encrypted data 
*/
- (NSData *) encryptWithKeyFromCert:(NSString *) path;

@end
