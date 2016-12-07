/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiAsyncQueueProxy.h"
#import "KrollBridge.h"

@implementation TiAsyncQueueProxy

- (void)dealloc
{
    RELEASE_TO_NIL(bridge);
    [super dealloc];
}

- (NSString *)apiName
{
    return @"Ti.Async.Queue";
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andType:(TiAsyncQueueType)type
{
    if (self = [super _initWithPageContext:context]) {
        // TODO: Handle different queue types (e.g. main-queue, priority-queue, ...)
    }
    
    return self;
}

- (void)dispatch:(id)args
{
    NSString *url = nil;
    KrollCallback *callback = nil;
    
    ENSURE_ARG_AT_INDEX(url, args, 0, NSString);
    ENSURE_ARG_AT_INDEX(callback, args, 1, KrollCallback);
    
    if (bridge) {
        [bridge shutdown:nil];
        RELEASE_TO_NIL(bridge);
    }
    
    // Will be required when we need to evalute the contents of the url
    bridge = [[[KrollBridge alloc] initWithHost:[self _host]] retain];
    [bridge boot:nil url:[TiUtils toURL:url proxy:self] preload:@{@"App": @{@"currentService": self}}];
    [self fireEventWithStatus:TiAsyncQueueStatusCreated];
    
    // This would be something coming from the new kroll bridge
    __block NSUInteger k = 0;

    // Dispatch on the global background queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fireEventWithStatus:TiAsyncQueueStatusRunning];
        
        for (NSUInteger i = 0; i < 100000000; i++) {
            k += i/1000;
        }
        
        // Deliever the result to the main-thread
        TiThreadPerformOnMainThread(^{
            NSDictionary * propertiesDict = @{@"value": NUMINTEGER(k)};
            NSArray * invocationArray = [[NSArray alloc] initWithObjects:&propertiesDict count:1];
            
            [callback call:invocationArray thisObject:self];
            [invocationArray release];
            
            [self fireEventWithStatus:TiAsyncQueueStatusCompleted];
        }, YES);
    });
}

- (void)fireEventWithStatus:(TiAsyncQueueStatus)status
{
    if ([self _hasListeners:@"status"]) {
        [self fireEvent:@"status" withObject:@{@"status": NUMUINTEGER(status)}];
    }
}

@end
