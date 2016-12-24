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
#import "TiHost.h"

@implementation TiUIiOSWebViewProxy

- (TiUIiOSWebView*)webView
{
    return (TiUIiOSWebView*)self.view;
}

#pragma mark - Public APIs

#pragma mark Getters

- (id)disableBounce
{
    return NUMBOOL(![[[[self webView] webView] scrollView] bounces]);
}

- (id)scrollsToTop
{
    return NUMBOOL([[[[self webView] webView] scrollView] scrollsToTop]);
}

- (id)allowsBackForwardNavigationGestures
{
    return NUMBOOL([[[self webView] webView] allowsBackForwardNavigationGestures]);
}

- (id)userAgent
{
    return [[[self webView] webView] customUserAgent] ?: [NSNull null];
}

- (id)url
{
    return [[[[self webView] webView] URL] absoluteString];
}

- (id)title
{
    return [[[self webView] webView] title];
}

- (id)progress
{
    return NUMDOUBLE([[[self webView] webView] estimatedProgress]);
}

- (id)loading
{
    return NUMBOOL([[[self webView] webView] isLoading]);
}

- (id)secure
{
    return NUMBOOL([[[self webView] webView] hasOnlySecureContent]);
}

#pragma mark Methods

- (void)stopLoading:(id)unused
{
    [[[self webView] webView] stopLoading];
}

- (void)reload:(id)unused
{
    [[[self webView] webView] reload];
}

- (void)goBack:(id)unused
{
    [[[self webView] webView] goBack];
}

- (void)goForward:(id)unused
{
    [[[self webView] webView] goForward];
}

- (id)canGoBack:(id)unused
{
    return NUMBOOL([[[self webView] webView] canGoBack]);
}

- (id)canGoForward:(id)unused
{
    return NUMBOOL([[[self webView] webView] canGoForward]);
}

// Callback based in this API to avoid dead-locks
// on the main-thread
- (void)evalJS:(id)args
{
    NSString *code = nil;
    KrollCallback *callback = nil;
    
    ENSURE_ARG_AT_INDEX(code, args, 0, NSString);
    ENSURE_ARG_AT_INDEX(callback, args, 1, KrollCallback);

    [[self webView] stringByEvaluatingJavaScriptFromString:code withCompletionHandler:^(NSString *result, NSError *error) {
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
            @"result": result ?: [NSNull null],
            @"success": NUMBOOL(error == nil)
        }];
        
        if (error) {
            [event setObject:[error localizedDescription] forKey:@"error"];
        }
        
        [callback call:[[NSArray alloc] initWithObjects:&event count:1] thisObject:self];
    }];
}

@end

#endif
