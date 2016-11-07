/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#ifdef USE_TI_UIIOSWEBVIEW

#import "TiUIiOSWebViewProxy.h"
#import "TiUIiOSWebView.h"
#import "TiUtils.h"

@implementation TiUIiOSWebViewProxy

- (TiUIiOSWebView*)webView
{
    return (TiUIiOSWebView*)self.view;
}

- (void)stopLoading:(id)unused
{
    [[[self webView] webView] stopLoading];
}

// Callback based in this API to avoid dead-locks
// on the main-thread
- (void)evalJS:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSString *code = nil;
    KrollCallback *callback = nil;
    
    ENSURE_ARG_AT_INDEX(code, args, 0, NSString);
    ENSURE_ARG_AT_INDEX(callback, args, 1, KrollCallback);

    [[self webView] stringByEvaluatingJavaScriptFromString:code withCompletionHandler:^(NSString *result, NSError *error) {
        NSDictionary * propertiesDict = @{
            @"result": result ?: [NSNull null],
            @"success": NUMBOOL(error == nil),
            @"error" : [error localizedDescription] ?: [NSNull null]
        };
        NSArray *invocationArray = [[NSArray alloc] initWithObjects:&propertiesDict count:1];
        
        [callback call:invocationArray thisObject:self];
        [invocationArray release];
    }];
}

@end

#endif
