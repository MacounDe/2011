//
//  NSData+AES128.h

//  Created by Pascal Bihler on 14.10.10.
//  Source: http://www.iphonedevsdk.com/forum/iphone-sdk-development/40989-aes-encryption-problem.html
//



/**
 @brief		Extends the NSData class by AES128 Encryption functionality
 */
@interface NSData (AES128) 

- (NSData *)AES128EncryptWithKey:(NSData *)key;
- (NSData *)AES128DecryptWithKey:(NSData *)key;

@end
