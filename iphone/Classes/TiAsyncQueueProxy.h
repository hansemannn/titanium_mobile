/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "AsyncConstants.h"

@interface TiAsyncQueueProxy : TiProxy {
    KrollBridge *bridge;
}

- (id)_initWithPageContext:(id<TiEvaluator>)context andType:(TiAsyncQueueType)type;

- (void)dispatch:(id)args;

@end
