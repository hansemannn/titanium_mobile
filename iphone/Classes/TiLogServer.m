/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLogServer.h"
#import "TiBase.h"

@implementation TiLogServer

+ (id)sharedServer {
    static TiLogServer *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 3000, &readStream, &writeStream);
        inputStream = [(NSInputStream *)readStream retain];
        outputStream = [(NSOutputStream *)writeStream retain];
        
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)dealloc
{
    RELEASE_TO_NIL(inputStream);
    RELEASE_TO_NIL(outputStream);
    
    [super dealloc];
}

/**
 * Writes the log message to active connection or to a queue if there are no connections.
 *
 * Important: Do NOT call NSLog() from within this function!
 */
- (void)log:(NSString*)message
{
    NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}

- (void)startServer
{
    [inputStream open];
    [outputStream open];
}

- (void)stopServer
{
    [inputStream close];
    [outputStream class];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    // NSLog in here will produce an infinite loop, be careful!
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
  //          NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            break;
            
        case NSStreamEventErrorOccurred:
   //         NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            break;
            
        default:
    //        NSLog(@"Unknown event");
            break;
    }
}


@end
