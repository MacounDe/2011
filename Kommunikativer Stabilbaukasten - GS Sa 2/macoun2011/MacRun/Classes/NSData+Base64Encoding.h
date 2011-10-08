//
//  base64.h
//
//  Created by Neo on 5/11/08.
//  Copyright 2008 Kaliware, LLC. All rights reserved.
//


/**
 @brief		Extends the NSData class by Base64 Encoding functionality
*/
@interface NSData (Base64Encoding)
/**
 @brief		Creates a new object from Base64 encoded string
 @param		string	The Base64 encoded data
 @result	A new autoreleased NSData object
*/
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;

/**
 @brief		Inits an object with Base64 encoded data
 @param		string	The Base64 encoded data
 @result	The NSData object
*/
- (id) initWithBase64EncodedString:(NSString *) string;

/**
 @brief		Encodes Base64
 @result	The data encoded as Base64
*/
- (NSString *) base64Encoding;

/**
 @brief		Encodes Base64
 @param		lineLength	the maximum length of one line
 @result	The data encoded as Base64
*/
- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

@end