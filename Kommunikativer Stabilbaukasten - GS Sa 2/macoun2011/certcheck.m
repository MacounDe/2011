/* ********** Check HTTPS certificates ******** */
// Source: 

#define SERVER_CERT_HASH @"1893bf2d3e527d44f6f1b68632f97e237a48cae8"

- (NSString*)sha1HexDigest:(NSData*)input 
{ // see http://www.makebetterthings.com/blogs/uncategorized/how-to-get-md5-and-sha1-in-objective-c-ios-sdk/
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([input bytes], [input length], result);
	
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
			result[16], result[17], result[18], result[19]
			];
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	
	return ([[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSURLProtectionSpace * protectionSpace = [challenge protectionSpace];
	if ([[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust]) {
		
		SecTrustRef trust = [protectionSpace serverTrust];
		BOOL trusted = NO;
		
		if (trust != NULL) {
			CFIndex             certCount;
			CFIndex             certIndex;
			SecCertificateRef   cert;
			
			// iterate over all certificates to check if the correct one is included
            certCount = SecTrustGetCertificateCount(trust);
            for (certIndex = 0; certIndex < certCount; certIndex++) {
                CFDataRef    certData;
				
                cert = SecTrustGetCertificateAtIndex(trust, certIndex);
                assert(cert != NULL);
				
                certData = SecCertificateCopyData(cert);
                assert(certData != NULL);
				
                NSLog(@"  %2d %@", (int) certIndex, [self sha1HexDigest:(NSData*)certData]);
				trusted |= [SERVER_CERT_HASH isEqual:[self sha1HexDigest:(NSData*)certData]];
				
                CFRelease(certData);
            }
        }
		
		
		if (trusted) {
			NSURLCredential * credential = [NSURLCredential credentialForTrust:trust];
			[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
		} else {
			// do something
			NSLog(@"Invalid certificate!");
		}
	}
}
