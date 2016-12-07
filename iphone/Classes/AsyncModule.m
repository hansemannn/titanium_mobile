/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "AsyncModule.h"
#import "TiAsyncQueueProxy.h"
#import "AsyncConstants.h"

@implementation AsyncModule

-(void)dealloc
{
	[super dealloc];
}

-(id)mainQueue
{
    return [[[TiAsyncQueueProxy alloc] _initWithPageContext:[self pageContext] andType:TiAsyncQueueTypeMain] autorelease];
}

MAKE_SYSTEM_PROP(STATUS_CREATED, TiAsyncQueueStatusCreated);
MAKE_SYSTEM_PROP(STATUS_RUNNING, TiAsyncQueueStatusRunning);
MAKE_SYSTEM_PROP(STATUS_COMPLETED, TiAsyncQueueStatusCompleted);
MAKE_SYSTEM_PROP(STATUS_ERRORED, TiAsyncQueueStatusErrored);
MAKE_SYSTEM_PROP(STATUS_CANCELLED, TiAsyncQueueStatusCancelled);

MAKE_SYSTEM_PROP(QUEUE_GLOBAL, TiAsyncQueueTypeGlobal);
MAKE_SYSTEM_PROP(QUEUE_MAIN, TiAsyncQueueTypeMain);

@end
