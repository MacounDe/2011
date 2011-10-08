//
//  NSData+RSA.m
//  encryptionStuff
//
//  Created by Pascal Bihler on 15.10.10.
//  Source: http://stackoverflow.com/questions/7441306/ios-rsa-encryption-ciphertext-length-alters-between-63-bytes-and-64-bytes

#import "NSData+RSA.h"
#import <CommonCrypto/CommonCryptor.h>


@implementation NSData (RSA)

- (NSData *) encryptWithKeyFromCert:(NSString *) path {
	
	assert(path != nil);
	
	OSStatus            err;
	NSData *            data;
	SecCertificateRef   cert;    
	SecTrustRef trust = NULL;
	
	SecTrustResultType result;
	
	data = [NSData dataWithContentsOfFile:path];
	assert(data != nil);
	
	cert = SecCertificateCreateWithData(NULL, (CFDataRef) data);
	assert(cert != NULL);
	
	SecPolicyRef policy = SecPolicyCreateBasicX509();
	err = SecTrustCreateWithCertificates((CFArrayRef)[NSArray arrayWithObject:(id)cert], policy, &trust);
    CFRelease(policy);
	
	assert(trust != NULL);
	
	err = SecTrustEvaluate (trust,&result);
	
	SecKeyRef publicKey = SecTrustCopyPublicKey(trust);
	assert(publicKey != NULL);
	
	CFRelease(trust);
	CFRelease(cert);
	
	OSStatus sanityCheck = noErr;	
    size_t cipherBufferSize = 0;	
    size_t keyBufferSize = 0;	
	
    NSData * cipher = nil;	
    uint8_t * cipherBuffer = NULL;	
	
    // Calculate the buffer sizes.	
    cipherBufferSize = SecKeyGetBlockSize(publicKey);	
    keyBufferSize = [self length];	
	
    // Allocate some buffer space. I don't trust calloc.
    cipherBuffer = malloc( cipherBufferSize * sizeof(uint8_t) );
    memset((void *)cipherBuffer, 0x0, cipherBufferSize);
	
    // Encrypt using the public key.
    sanityCheck = SecKeyEncrypt(publicKey,								
								kSecPaddingPKCS1,								
								(const uint8_t *)[self bytes],								
								keyBufferSize,								
								cipherBuffer,								
								&cipherBufferSize								
                                );
	
	
    // Build up cipher text blob.
	cipher = [NSData dataWithBytes:(const void *)cipherBuffer length:(NSUInteger)cipherBufferSize];
	if (cipherBuffer) free(cipherBuffer);
	
	CFRelease(publicKey);
	
	return cipher;
}

@end
