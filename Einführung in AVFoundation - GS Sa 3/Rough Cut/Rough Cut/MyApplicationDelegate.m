//
//  MyApplicationDelegate.m
//  Rough Cut
//
//  Created by Stefan Hafeneger on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyApplicationDelegate.h"

#import <AVFoundation/AVFoundation.h>

@interface MyApplicationDelegate () <NSWindowDelegate, AVCaptureFileOutputRecordingDelegate> {
	NSWindow *_captureWindow;
	AVCaptureSession *_captureSession;
}
@end

@implementation MyApplicationDelegate

- (void)dealloc
{
	[_captureSession release];
	_captureSession = nil;
	
	[_captureWindow release];
	_captureWindow = nil;
	
	[super dealloc];
}

#pragma mark -

- (IBAction)capture:(id)sender
{
	if (!_captureWindow)
	{
		// Create capture window.
		_captureWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0f, 0.0f, 640.0f, 512.0f) styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
		
		// Setup capture window.
		[_captureWindow setContentBorderThickness:32.0f forEdge:NSMinYEdge];
		[_captureWindow setDelegate:self];
		[_captureWindow setReleasedWhenClosed:NO];
		[_captureWindow setTitle:[[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] localizedName]];
		
		// Create capture video preview layer.
		AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layer];
		[layer setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
		
		// Add capture video preview layer view.
		NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0.0f, 32.0f, 640.0f, 480.0f)];
		[view setLayer:layer];
		[view setWantsLayer:YES];
		[[_captureWindow contentView] addSubview:view];
		[view release];
		
		// Add start recording button.
		NSButton *startButton = [[NSButton alloc] initWithFrame:NSMakeRect(238.0f, -2.0f, 82.0f, 32.0f)];
		[startButton setBezelStyle:NSRoundedBezelStyle];
		[startButton setButtonType:NSMomentaryPushInButton];
		[startButton setTitle:@"Start"];
		[startButton setTarget:self];
		[startButton setAction:@selector(startRecording:)];
		[[_captureWindow contentView] addSubview:startButton];
		[startButton release];
		
		// Add stop recording button.
		NSButton *stopButton = [[NSButton alloc] initWithFrame:NSMakeRect(320.0f, -2.0f, 82.0f, 32.0f)];
		[stopButton setBezelStyle:NSRoundedBezelStyle];
		[stopButton setButtonType:NSMomentaryPushInButton];
		[stopButton setTitle:@"Stop"];
		[stopButton setTarget:self];
		[stopButton setAction:@selector(stopRecording:)];
		[[_captureWindow contentView] addSubview:stopButton];
		[stopButton release];
	}
	
	if (!_captureSession)
	{
		_captureSession = [[AVCaptureSession alloc] init];
		
		AVCaptureInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:NULL];
		if (captureInput && [_captureSession canAddInput:captureInput])
		{
			[_captureSession addInput:captureInput];
		}
		
		AVCaptureOutput *captureOutput = [[[AVCaptureMovieFileOutput alloc] init] autorelease];
		if (captureOutput && [_captureSession canAddOutput:captureOutput])
		{
			[_captureSession addOutput:captureOutput];
		}
		
		// Connect capture video preview layer to capture session.
		[(AVCaptureVideoPreviewLayer *)[[[[_captureWindow contentView] subviews] objectAtIndex:0] layer] setSession:_captureSession];
		
		// Enable start recording button.
		[(NSButton *)[[[_captureWindow contentView] subviews] objectAtIndex:1] setEnabled:YES];
	}
	
	// Enable start recording button and disable stop recording button.
	[(NSButton *)[[[_captureWindow contentView] subviews] objectAtIndex:1] setEnabled:YES];
	[(NSButton *)[[[_captureWindow contentView] subviews] objectAtIndex:2] setEnabled:NO];
	
	// Start capture session.
	[_captureSession startRunning];
	
	// Show capture window.
	[_captureWindow center];
	[_captureWindow makeKeyAndOrderFront:self];
}

- (IBAction)startRecording:(id)sender
{
	if (_captureSession)
	{
		NSArray *outputs = [_captureSession outputs];
		if ([outputs count] > 0)
		{
			// Get capture output.
			AVCaptureMovieFileOutput *captureOutput = [outputs objectAtIndex:0];
			
			// Define capture URL (we will save to Desktop).
			NSURL *URL = [NSURL fileURLWithPath:[@"~/Desktop/Capture.mov" stringByExpandingTildeInPath]];
			
			// Remove item at URL if it exists, otherwise AVCaptureMovieFileOutput won't record.
			if ([URL checkResourceIsReachableAndReturnError:NULL])
			{
				[[NSFileManager defaultManager] removeItemAtURL:URL error:NULL];
			}
			
			// Start recording.
			[captureOutput startRecordingToOutputFileURL:URL recordingDelegate:self];
			
			// Disable start recording button and enable stop recording button.
			[(NSButton *)[[[_captureWindow contentView] subviews] objectAtIndex:1] setEnabled:NO];
			[(NSButton *)[[[_captureWindow contentView] subviews] objectAtIndex:2] setEnabled:YES];
		}
	}
}

- (IBAction)stopRecording:(id)sender
{
	if (_captureSession)
	{
		NSArray *outputs = [_captureSession outputs];
		if ([outputs count] > 0)
		{
			// Get capture output.
			AVCaptureMovieFileOutput *captureOutput = [outputs objectAtIndex:0];
			
			if ([captureOutput isRecording])
			{
				// Stop recording.
				[captureOutput stopRecording];
				
				// Disable stop recording button.
				[(NSButton *)[[[_captureWindow contentView] subviews] objectAtIndex:2] setEnabled:NO];
			}
		}
	}
}

#pragma mark -

- (BOOL)windowShouldClose:(id)sender
{
	if (_captureSession)
	{
		NSArray *outputs = [_captureSession outputs];
		if ([outputs count] > 0)
		{
			// Get capture output.
			AVCaptureMovieFileOutput *captureOutput = [outputs objectAtIndex:0];
			
			// Refuse to close window if recording.
			if ([captureOutput isRecording])
			{
				return NO;
			}
		}
		
		// Stop capture session.
		[_captureSession stopRunning];
	}
	
	return YES;
}

#pragma mark -

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
	// Hide capture window.
	[_captureWindow orderOut:self];
	
	// Stop capture session.
	[_captureSession stopRunning];
}

@end
