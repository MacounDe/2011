//
//  MyDocument.m
//  Rough Cut
//
//  Created by Stefan Hafeneger on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"

#import <AVFoundation/AVFoundation.h>

#import "MyPlayerView.h"

@interface MyDocument () {
	AVPlayer *_player;
	id _playerPeriodicTimeObserver;
	
	MyPlayerView *_playerView;
	NSButton *_playPauseButton;
	NSSlider *_currentTimeSlider;
}
@end

@implementation MyDocument

- (id)init
{
	self = [super init];
	
	if (self)
	{
		_player = [[AVPlayer alloc] init];
		
		// Add self as player item did play to end time observer.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	// Remove self as player item did play to end time observer.
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	
	[_player release];
	_player = nil;
	
	[super dealloc];
}

#pragma mark -

@synthesize player = _player;
@synthesize playerView = _playerView;
@synthesize playPauseButton = _playPauseButton;
@synthesize currentTimeSlider = _currentTimeSlider;

#pragma mark -

- (NSString *)windowNibName
{
	return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller
{
	[super windowControllerDidLoadNib:controller];
	
	// Set MyPlayerView's player property.
	[_playerView setPlayer:_player];
	
	// Add periodic time observer.
	_playerPeriodicTimeObserver = [[_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:NULL usingBlock:^(CMTime time) {
		AVPlayerItem *playerItem = [_player currentItem];
		if (playerItem)
		{
			CMTime duration = [playerItem duration];
			if (CMTIME_IS_NUMERIC(duration))
			{
				// Update current time slider.
				double value = (double)(CMTimeGetSeconds(time) / CMTimeGetSeconds(duration));
				[_currentTimeSlider setDoubleValue:value];
			}
		}
	}] retain];
}

- (void)close
{
	// Remove periodic time observer.
	[_player removeTimeObserver:_playerPeriodicTimeObserver];
	[_playerPeriodicTimeObserver release];
	_playerPeriodicTimeObserver = nil;
	
	// Set MyPlayerView's player property.
	[_playerView setPlayer:nil];
	
	[super close];
}

#pragma mark -

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{
	if (![typeName isEqualToString:@"DocumentType"])
	{
		// Create player item from URL.
		AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
		if (playerItem)
		{
			// Make player item player's current item.
			[_player replaceCurrentItemWithPlayerItem:playerItem];
			
			return YES;
		}
		
		return NO;
	}
	
	return [super readFromURL:url ofType:typeName error:outError];
}

#pragma mark -

- (IBAction)togglePlayback:(id)sender
{
	BOOL isPlaying = (0.0f != [_player rate]);
	
	// Set playhead back to start.
	if (!isPlaying)
	{
		AVPlayerItem *playerItem = [_player currentItem];
		if (playerItem)
		{
			CMTime currentTime = [playerItem currentTime];
			CMTime duration = [playerItem duration];
			if (CMTIME_IS_NUMERIC(duration))
			{
				if (CMTIME_COMPARE_INLINE(currentTime, >=, duration))
				{
					[playerItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			}
		}
	}
	
	// Toggle playback.
	[_player setRate:(isPlaying ? 0.0f : 1.0f)];
}

- (IBAction)seekToTime:(id)sender
{
	if ([sender isKindOfClass:[NSSlider class]])
	{
		double value = [sender doubleValue];
		
		AVPlayerItem *playerItem = [_player currentItem];
		if (playerItem)
		{
			CMTime duration = [playerItem duration];
			if (CMTIME_IS_NUMERIC(duration))
			{
				// Seek player to time.
				CMTime time = CMTimeMultiplyByFloat64(duration, (Float64)value);
				[_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
			}
		}
	}
}

#pragma mark -

- (IBAction)addClips:(id)sender
{
	AVPlayerItem *playerItem = [_player currentItem];
	if (playerItem && [[playerItem asset] isKindOfClass:[AVURLAsset class]])
	{
		NSURL *URL = [(AVURLAsset *)[playerItem asset] URL];
		
		NSOpenPanel *openPanel = [NSOpenPanel openPanel];
		[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"public.audiovisual-content"]];
		[openPanel setAllowsMultipleSelection:YES];
		[openPanel setPrompt:@"Choose"];
		[openPanel beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
			if (NSOKButton == result)
			{
				NSArray *URLs = [[NSArray arrayWithObject:URL] arrayByAddingObjectsFromArray:[openPanel URLs]];
				
				// Create mutable composition.
				AVMutableComposition *composition = [AVMutableComposition composition];
				if (composition)
				{
#if 0
					CMTime time = kCMTimeZero;
					
					for (NSURL *URL in URLs)
					{
						// Create asset from URL (and prepare asset to be used in composition).
						AVAsset *asset = [AVURLAsset URLAssetWithURL:URL options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], AVURLAssetPreferPreciseDurationAndTimingKey, nil]];
						if (asset)
						{
							CMTime duration = [asset duration];
							
							[composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofAsset:asset atTime:time error:NULL];
							
							time = CMTimeAdd(time, duration);
						}
					}
#else				
					NSMutableArray *videoAssets = [NSMutableArray array];
					NSMutableArray *audioAssets = [NSMutableArray array];
					
					for (NSURL *URL in URLs)
					{
						// Create asset from URL (and prepare asset to be used in composition).
						AVAsset *asset = [AVURLAsset URLAssetWithURL:URL options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], AVURLAssetPreferPreciseDurationAndTimingKey, nil]];
						if (asset)
						{
							// Add asset to appropriate asset array.
							if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] > 0)
							{
								[videoAssets addObject:asset];
							}
							else if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
							{
								[audioAssets addObject:asset];
							}
						}
					}
					
					// Add assets to composition.
					AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
					AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
					if (videoTrack && audioTrack)
					{
						CMTime time = kCMTimeZero;
						
						for (AVAsset *asset in videoAssets)
						{
							CMTime duration = [asset duration];
							CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, duration);
							
							// Add content from video and audio track to composition tracks.
							NSArray *videoAssetTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
							AVAssetTrack *videoAssetTrack = ([videoAssetTracks count] > 0 ? [videoAssetTracks objectAtIndex:0] : nil);
							if (videoAssetTrack)
							{
								[videoTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:time error:NULL];
							}
							NSArray *audioAssetTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
							AVAssetTrack *audioAssetTrack = ([audioAssetTracks count] > 0 ? [audioAssetTracks objectAtIndex:0] : nil);
							if (audioAssetTrack)
							{
								[audioTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:time error:NULL];
							}
							
							time = CMTimeAdd(time, duration);
						}
						
						// Add additional audio assets to composition.
						if ([audioAssets count] > 0)
						{
							audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
							if (audioTrack)
							{
								// Save total time.
								CMTime totalTime = time;
								
								// Reset time for additional audio track.
								time = kCMTimeZero;
								
								for (AVAsset *asset in audioAssets)
								{
									CMTime duration = [asset duration];
									CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, duration);
									
									// Limit time range to total time.
									timeRange.duration = (CMTIME_COMPARE_INLINE(CMTimeAdd(time, duration), >, totalTime) ? CMTimeSubtract(totalTime, time) : timeRange.duration);
									
									NSArray *audioAssetTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
									AVAssetTrack *audioAssetTrack = ([audioAssetTracks count] > 0 ? [audioAssetTracks objectAtIndex:0] : nil);
									if (audioAssetTrack)
									{
										[audioTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:time error:NULL];
									}
									
									time = CMTimeAdd(time, duration);
									
									// Skip remaining assets if total time is reached.
									if (CMTIME_COMPARE_INLINE(time, >, totalTime)) break;
								}
							}
						}
					}
#endif
					
					// Create player item from immutable composition copy.
					AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[[composition copy] autorelease]];
					
					// Make player item player's current item.
					[_player replaceCurrentItemWithPlayerItem:playerItem];
					
					// Update current time slider.
					[_currentTimeSlider setDoubleValue:0.0];
				}
			}
		}];
	}
}

#pragma mark -

- (IBAction)export:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mov"]];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel setPrompt:@"Export"];
	[savePanel beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (NSOKButton == result)
		{
			NSURL *URL = [savePanel URL];
			
			// Remove item at URL if it exists, otherwise AVAssetExportSession will fail.
			if ([URL checkResourceIsReachableAndReturnError:NULL])
			{
				[[NSFileManager defaultManager] removeItemAtURL:URL error:NULL];
			}
			
			// Create export session with current player item and 1280x720 export preset.
			AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:[[_player currentItem] asset] presetName:AVAssetExportPreset1280x720];
			if (exportSession)
			{
				// Setup export session.
				[exportSession setOutputFileType:@"com.apple.quicktime-movie"];
				[exportSession setOutputURL:URL];
				
				// Hide save panel (so we can present another sheet).
				[savePanel orderOut:self];
				
				// Show progress sheet.
				NSWindow *sheet = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0f, 0.0f, 400.0f, 56.0f) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:YES];
				NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(18.0f, 16.0f, 364.0f, 20.0f)];
				[progressIndicator setIndeterminate:NO];
				[progressIndicator setMinValue:0.0];
				[progressIndicator setMaxValue:1.0];
				[progressIndicator setDoubleValue:0.0];
				[[sheet contentView] addSubview:progressIndicator];
				[progressIndicator release];
				[NSApp beginSheet:sheet modalForWindow:[self windowForSheet] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
				
				// Setup repeating timer for updating progress sheet.
				NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireTimer:) userInfo:[NSArray arrayWithObjects:exportSession, progressIndicator, nil] repeats:YES];
				
				// Start export session.
				[exportSession exportAsynchronouslyWithCompletionHandler:^{
					// Invalidate repeating timer.
					[timer invalidate];
					
					// Hide progress sheet.
					[NSApp endSheet:sheet];
					[sheet orderOut:self];
					[sheet release];
					
					// Present error if export failed.
					if (AVAssetExportSessionStatusCompleted != [exportSession status])
					{
						[self presentError:[exportSession error] modalForWindow:[self windowForSheet] delegate:nil didPresentSelector:NULL contextInfo:NULL];
					}
					
					// Release export session.
					[exportSession release];
				}];
			}
		}
	}];
}

- (void)fireTimer:(NSTimer *)timer
{
	// Update export progress indicator by getting current progress from export session.
	double progress = (double)[(AVAssetExportSession *)[[timer userInfo] objectAtIndex:0] progress];
	[(NSProgressIndicator *)[[timer userInfo] objectAtIndex:1] setDoubleValue:progress];
}

#pragma mark -

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
	AVPlayerItem *playerItem = [notification object];
	if ([_player currentItem] == playerItem)
	{
		// Change button image.
		[[_playPauseButton cell] setState:NSOffState];
	}
}

@end

#pragma mark -

@implementation NSDocumentController (MyDocument)

- (IBAction)newDocument:(id)sender
{
	// Read/write of document not implemented in this demo.
}

@end
