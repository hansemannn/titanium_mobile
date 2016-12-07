/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

typedef NS_ENUM(NSUInteger, TiAsyncQueueType) {
    TiAsyncQueueTypeMain = 0,
    TiAsyncQueueTypeGlobal
};

typedef NS_ENUM(NSUInteger, TiAsyncQueueStatus) {
    TiAsyncQueueStatusCreated = 0,
    TiAsyncQueueStatusRunning,
    TiAsyncQueueStatusCompleted,
    TiAsyncQueueStatusErrored,
    TiAsyncQueueStatusCancelled
};
