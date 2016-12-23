/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#ifdef USE_TI_UIIOSWEBVIEW
#import "TiViewProxy.h"
#import "TiEvaluator.h"

@interface TiUIiOSWebViewProxy : TiViewProxy<TiEvaluator> {
    NSString *pageToken;
    NSString *evalResult;
    NSArray *webKeySequence;
    BOOL inKJSThread;
}

-(void)setPageToken:(NSString*)pageToken;

@end

#endif
