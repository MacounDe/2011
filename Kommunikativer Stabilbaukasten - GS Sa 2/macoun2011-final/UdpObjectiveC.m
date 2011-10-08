#pragma mark ---- UDP Communication ----

- (void) sendData:(NSData *) data {
	
	if (! networkSocket)
		[self openUdpSocket];
	
	if (! networkSocket)
		return;
	
	CFSocketError err = CFSocketSendData(self.networkSocket, NULL, (CFDataRef) data, 0.1);
	if (err != kCFSocketSuccess) {
        perror("senddata");
	}
	
}

- (void) receivedData:(NSData *) data {
	
	NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"UDP-Received: %@", dataString);
	
	if ([data length] > 0) {
       ... do something here ...
	}

}


#pragma mark ---- UDP Socket Management ----

static void NetworkSocketCallBack(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
	UDPServerCommunicator * self;
	self = (UDPServerCommunicator *) info;
	assert([self isKindOfClass:[UDPServerCommunicator class]]);
	
	assert(type == kCFSocketReadCallBack);
	assert(address == nil);
	assert(data == nil);
	[self _readData];
}

- (void) _readData {
	
    char buffer[MAXBUFLEN];
	ssize_t bytesRead;
	
	bytesRead = recv(CFSocketGetNative(self.networkSocket),
					 buffer,
					 sizeof(buffer),
					 MSG_DONTWAIT);
	
	if (bytesRead < 0) {
		perror("recvfrom");
	} else {
		[self receivedData:[NSData dataWithBytes:buffer length:bytesRead]];
	}
}


- (BOOL) openUdpSocket {
	
	
	CFSocketContext context = {0, self, NULL, NULL, NULL};
	CFSocketRef newSocket;
	CFRunLoopSourceRef rls;
	
	struct sockaddr_in addr;
	
	// Get server address
	struct hostent *hp;
	hp = gethostbyname([@"example.com" cStringUsingEncoding:NSUTF8StringEncoding]); // your server
	if (hp == NULL) {
		perror("gethostbyname");
		return NO;
	}
	
	
	// create and connect a socket for sending and receiving
	
	newSocket = CFSocketCreate(
							   NULL,
							   PF_INET,
							   SOCK_DGRAM,
							   IPPROTO_UDP,
							   kCFSocketReadCallBack,
							   NetworkSocketCallBack,
							   &context);
	
	
	if (! newSocket) {
		perror("CFSocketCreate");
		return NO;
	}
	
	memset(&addr,0,sizeof(addr));
	addr.sin_len = sizeof(addr);
	addr.sin_family = AF_INET;
	addr.sin_port = htons(1234); // The port you selected
	memcpy(&addr.sin_addr.s_addr,hp->h_addr_list[0],hp->h_length);
	
	BOOL success = NO;
	
	CFDataRef address = CFDataCreate(NULL, (unsigned char*)&addr,sizeof(addr));
	CFSocketError err = CFSocketConnectToAddress(newSocket, address, 0.1);
	if (err == kCFSocketSuccess) {
		
		//schedule the socket on the run loop
		rls = CFSocketCreateRunLoopSource(NULL, newSocket, 0);
		assert(rls != NULL);
		
		CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
		
		CFRelease(rls);
		self.networkSocket = newSocket;
		
		success = YES;
	}
	
	if (newSocket)
		CFRelease(newSocket);
	newSocket = NULL;
	
	return success;
}

- (void) closeUdpSocket {
	if (networkSocket) {
		CFSocketInvalidate(networkSocket);
		CFRelease(networkSocket);
	}
	
}
