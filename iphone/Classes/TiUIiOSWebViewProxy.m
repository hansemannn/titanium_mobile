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

-(void)windowDidClose
{
    if (pageToken!=nil)
    {
        [[self host] unregisterContext:(id<TiEvaluator>)self forToken:pageToken];
        RELEASE_TO_NIL(pageToken);
    }
    NSNotification *notification = [NSNotification notificationWithName:kTiContextShutdownNotification object:self];
    WARN_IF_BACKGROUND_THREAD_OBJ;
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [super windowDidClose];
}

-(void)_destroy
{
    if (pageToken!=nil)
    {
        [[self host] unregisterContext:(id<TiEvaluator>)self forToken:pageToken];
        RELEASE_TO_NIL(pageToken);
    }
    [super _destroy];
}

-(void)setPageToken:(NSString*)pageToken_
{
    if (pageToken != nil)
    {
        [[self host] unregisterContext:(id<TiEvaluator>)self forToken:pageToken];
        RELEASE_TO_NIL(pageToken);
    }
    pageToken = [pageToken_ retain];
    [[self host] registerContext:self forToken:pageToken];
}

#pragma mark Evaluator

- (BOOL)evaluationError
{
    // TODO; is this correct
    return NO;
}

- (TiHost*)host
{
    return [self _host];
}

- (void)evalFile:(NSString*)file
{
    TiThreadPerformOnMainThread(^{[(TiUIiOSWebView*)[self view] evalFile:file];}, NO);
}

- (id)evalJSAndWait:(NSString*)code
{
    __block id _result;
    TiThreadPerformOnMainThread(^{
        [[(TiUIiOSWebView*)[self view] webView] evaluateJavaScript:code
                                                 completionHandler:^(id result, NSError *error) {
                                                     _result = [NSString stringWithFormat:@"%@", result];
                                                 }];
    }, YES);
    
    return [_result autorelease];
}

- (void)fireEvent:(id)listener withObject:(id)obj remove:(BOOL)yn thisObject:(id)thisObject_
{
    TiThreadPerformOnMainThread(^{
        [(TiUIiOSWebView*)[self view] fireEvent:listener withObject:obj remove:yn thisObject:thisObject_];
    }, NO);
}

- (id)preloadForKey:(id)key name:(id)name
{
    return nil;
}

- (KrollContext*)krollContext
{
    return nil;
}

- (id)registerProxy:(id)proxy
{
    return nil;
}

- (void)unregisterProxy:(id)proxy
{
}

//TODO: Is this correct?
- (BOOL)usesProxy:(id)proxy;
{
    return NO;
}

//TODO: Is this correct?
- (id)krollObjectForProxy:(id)proxy
{
    return nil;
}

-(void)evalJSWithoutResult:(NSString*)code
{
    [self evalJS:code];
}

- (NSString*)basename
{
    return nil;
}

- (NSURL *)currentURL
{
    return nil;
}

-(void)setCurrentURL:(NSURL *)unused
{
    
}

DEFINE_DEF_PROP(scrollsToTop,[NSNumber numberWithBool:YES]);

#pragma mark - Internal Use Only
-(void)delayedLoad
{
    TiThreadPerformOnMainThread(^{
        [self contentsWillChange];
    }, NO);
}

-(void)webviewDidFinishLoad
{
    [self contentsWillChange];
    //Do a delayed load as well if this one does not go through.
    [self performSelector:@selector(delayedLoad) withObject:nil afterDelay:0.5];
}

@end

#endif
