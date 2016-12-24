/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#ifdef USE_TI_UIIOSWEBVIEW
#import "TiUIiOSWebView.h"
#import "TiUIiOSWebViewProxy.h"
#import "TiFilesystemFileProxy.h"
#import "TiApp.h"
#import "SBJSON.h"

@implementation TiUIiOSWebView

#pragma mark Internal API's

- (WKWebView*)webView
{
    if (_webView == nil) {
        [[TiApp app] attachXHRBridgeIfRequired];
                
        _webView = [[WKWebView alloc] initWithFrame:[self bounds] configuration:[self configuration]];
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"Ti"];
        
        [_webView setUIDelegate:self];
        [_webView setNavigationDelegate:self];
        [_webView setContentMode:[self contentModeForWebView]];
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        // KVO for "progress" event
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        [self addSubview:_webView];
    }
    
    return _webView;
}

#pragma mark Cleanup

-(void)dealloc
{
    RELEASE_TO_NIL(_webView);
    [super dealloc];
}

#pragma mark Public API's

- (void)setUrl_:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self proxy] replaceValue:value forKey:@"url" notification:NO];
    
    if ([[self webView] isLoading]) {
        [[self webView] stopLoading];
    }
    
    if ([[self proxy] _hasListeners:@"beforeload"]) {
        [[self proxy] fireEvent:@"beforeload" withObject:@{@"url": [TiUtils stringValue:value]}];
    }
    
    // Handle remote URL's
    if ([value hasPrefix:@"http"] || [value hasPrefix:@"https"]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[TiUtils stringValue:value]]];
        [[self webView] loadRequest:request];
        
    // Handle local URL's (WiP)
    } else {
        NSString *path = [self pathFromComponents:@[[TiUtils stringValue:value]]];
        [[self webView] loadFileURL:[NSURL fileURLWithPath:path]
            allowingReadAccessToURL:[NSURL fileURLWithPath:[path stringByDeletingLastPathComponent]]];
    }
}

- (void)setData_:(id)value
{
    [[self proxy] replaceValue:value forKey:@"data" notification:NO];
    
    if ([[self webView] isLoading]) {
        [[self webView] stopLoading];
    }
    
    if ([[self proxy] _hasListeners:@"beforeload"]) {
        [[self proxy] fireEvent:@"beforeload" withObject:@{@"url": [[NSBundle mainBundle] bundlePath], @"data": [TiUtils stringValue:value]}];
    }
    
    NSData *data = nil;
    
    if ([value isKindOfClass:[TiBlob class]]) {
        data = [[(TiBlob*)value data] retain];
    } else if ([value isKindOfClass:[TiFile class]]) {
        data = [[[(TiFilesystemFileProxy*)value blob] data] retain];
    } else {
        NSLog(@"[ERROR] Ti.UI.iOS.WebView.data can only be a TiBlob or TiFile object, was %@", [(TiProxy*)value apiName]);
    }
    
    [[self webView] loadData:data
                    MIMEType:[TiUIiOSWebView mimeTypeForData:data]
       characterEncodingName:@"UTF-8" // TODO: Support other character-encodings as well
                     baseURL:[[NSBundle mainBundle] resourceURL]];
    
    RELEASE_TO_NIL(data);
}

- (void)setHtml_:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self proxy] replaceValue:value forKey:@"html" notification:NO];
   
    NSString *content = [TiUtils stringValue:value];

    if ([[self webView] isLoading]) {
        [[self webView] stopLoading];
    }
    
    if ([[self proxy] _hasListeners:@"beforeload"]) {
        [[self proxy] fireEvent:@"beforeload" withObject:@{@"url": [[NSBundle mainBundle] bundlePath], @"html": content}];
    }
    
    [[self webView] loadHTMLString:content baseURL:nil];
}

- (void)setDisableBounce_:(id)value
{
    [[self proxy] replaceValue:[value isEqual: @1] ? @0 : @1 forKey:@"disableBounce" notification:NO];
    [[[self webView] scrollView] setBounces:![TiUtils boolValue:value]];
}

- (void)setScrollsToTop_:(id)value
{
    [[self proxy] replaceValue:value forKey:@"scrollsToTop" notification:NO];
    [[[self webView] scrollView] setScrollsToTop:[TiUtils boolValue:value def:YES]];
}

- (void)setAllowsBackForwardNavigationGestures_:(id)value
{
    [[self proxy] replaceValue:value forKey:@"allowsBackForwardNavigationGestures" notification:NO];
    [[self webView] setAllowsBackForwardNavigationGestures:[TiUtils boolValue:value def:NO]];
}

- (void)setUserAgent_:(id)value
{
    [[self proxy] replaceValue:value forKey:@"userAgent" notification:NO];
    [[self webView] setCustomUserAgent:[TiUtils stringValue:value]];
}

#pragma mark Delegates

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    // Use own event to notify the user that the web view started
    // to receive content but did not finish, yet
    if ([[self proxy] _hasListeners:@"loadprogress"]) {
        [[self proxy] fireEvent:@"loadprogress" withObject:@{@"url": webView.URL.absoluteString, @"title": webView.title}];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if ([[self proxy] _hasListeners:@"load"]) {
        [[self proxy] fireEvent:@"load" withObject:@{@"url": webView.URL.absoluteString, @"title": webView.title}];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([[self proxy] _hasListeners:@"error"]) {
        [[self proxy] fireEvent:@"error" withObject:@{@"url": webView.URL.absoluteString, @"title": webView.title, @"error": [error localizedDescription]}];
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    if ([[self proxy] _hasListeners:@"redirect"]) {
        [[self proxy] fireEvent:@"redirect" withObject:@{@"url": webView.URL.absoluteString, @"title": webView.title}];
    }
}

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo
{
    return [TiUtils boolValue:[[self proxy] valueForKey:@"allowsLinkPreview"] def:NO];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([[self proxy] _hasListeners:@"message"]) {
        // TODO: May need to bridge the body type for data
        [[self proxy] fireEvent:@"message" withObject:@{
            @"url": message.frameInfo.request.URL.absoluteString ?: [[NSBundle mainBundle] bundlePath],
            @"message": message.body,
            @"name": message.name,
            @"isMainFrame": NUMBOOL(message.frameInfo.isMainFrame)
        }];
    }
}

#pragma mark Utilities

- (WKWebViewConfiguration*)configuration
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];

    id suppressesIncrementalRendering = [[self proxy] valueForKey:@"suppressesIncrementalRendering"];
    id scalePageToFit = [[self proxy] valueForKey:@"scalePageToFit"];
    id allowsInlineMediaPlayback = [[self proxy] valueForKey:@"allowsInlineMediaPlayback"];
    id allowsAirPlayForMediaPlayback = [[self proxy] valueForKey:@"allowsAirPlayForMediaPlayback"];
    id allowsPictureInPictureMediaPlayback = [[self proxy] valueForKey:@"allowsPictureInPictureMediaPlayback"];
    
    if ([TiUtils boolValue:scalePageToFit def:YES]) {
        [controller addUserScript:[TiUIiOSWebView userScriptScalePageToFit]];
    }
    
    [config setSuppressesIncrementalRendering:[TiUtils boolValue:suppressesIncrementalRendering def:NO]];

    [config setAllowsInlineMediaPlayback:[TiUtils boolValue:allowsInlineMediaPlayback def:NO]];
    
    [config setAllowsAirPlayForMediaPlayback:[TiUtils boolValue:allowsAirPlayForMediaPlayback def:NO]];

    [config setAllowsPictureInPictureMediaPlayback:[TiUtils boolValue:allowsPictureInPictureMediaPlayback def:YES]];
    
    [config setUserContentController:controller];

    return [config autorelease];
}

+ (WKUserScript*)userScriptScalePageToFit
{
    NSString *source = @"var meta = document.createElement('meta'); \
                         meta.setAttribute('name', 'viewport'); \
                         meta.setAttribute('content', 'width=device-width'); \
                         document.getElementsByTagName('head')[0].appendChild(meta);";
    
    return [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
}

+ (WKUserScript*)userScriptDisableSelection
{
    NSString *source = @"var style = document.createElement('style'); \
                         style.type = 'text/css'; \
                         style.innerText = '*:not(input):not(textarea) { -webkit-user-select: none; -webkit-touch-callout: none; }'; \
                         var head = document.getElementsByTagName('head')[0]; \
                         head.appendChild(style);";
    
    return [[WKUserScript alloc] initWithSource:source
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                               forMainFrameOnly:YES];
}

+ (WKUserScript*)userScriptTitaniumJSEvaluationFromString:(NSString*)string
{
    return [[WKUserScript alloc] initWithSource:string
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                               forMainFrameOnly:YES];
}

-(NSString*)pathFromComponents:(NSArray*)args
{
    NSString * newPath;
    id first = [args objectAtIndex:0];
    
    if ([first hasPrefix:@"file://"]) {
        newPath = [[NSURL URLWithString:first] path];
    } else if ([first characterAtIndex:0]!='/') {
        newPath = [[[NSURL URLWithString:[self resourcesDirectory]] path] stringByAppendingPathComponent:[self resolveFile:first]];
    } else {
        newPath = [self resolveFile:first];
    }
    
    if ([args count] > 1) {
        for (int c = 1;c < [args count]; c++) {
            newPath = [newPath stringByAppendingPathComponent:[self resolveFile:[args objectAtIndex:c]]];
        }
    }
    
    return [newPath stringByStandardizingPath];
}

-(id)resolveFile:(id)arg
{
    if ([arg isKindOfClass:[TiFilesystemFileProxy class]]) {
        return [(TiFilesystemFileProxy*)arg path];
    }
    return [TiUtils stringValue:arg];
}

-(NSString*)resourcesDirectory
{
    return [NSString stringWithFormat:@"%@/",[[NSURL fileURLWithPath:[TiHost resourcePath] isDirectory:YES] path]];
}

// http://stackoverflow.com/a/32765708/5537752
+ (NSString *)mimeTypeForData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    
    return nil;
}


// Add support for evaluating JS with the WKWebView and return back an evaluated value.
- (NSString*)stringByEvaluatingJavaScriptFromString:(NSString *)script withCompletionHandler:(void (^)(NSString *result, NSError *error))completionHandler
{
    [[self webView] evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil && result != nil) {
            completionHandler([NSString stringWithFormat:@"%@", result], nil);
        } else {
            NSLog(@"[DEBUG] Evaluating JavaScript failed : %@", [error localizedDescription]);
            completionHandler(nil, error);
        }
    }];
}

#pragma mark Layout helper

- (void)setWidth_:(id)width_
{
    width = TiDimensionFromObject(width_);
    [self updateContentMode];
}

- (void)setHeight_:(id)height_
{
    height = TiDimensionFromObject(height_);
    [self updateContentMode];
}

- (void)updateContentMode
{
    if ([self webView] != nil) {
        [[self webView] setContentMode:[self contentModeForWebView]];
    }
}

- (UIViewContentMode)contentModeForWebView
{
    if (TiDimensionIsAuto(width) || TiDimensionIsAutoSize(width) || TiDimensionIsUndefined(width) ||
        TiDimensionIsAuto(height) || TiDimensionIsAutoSize(height) || TiDimensionIsUndefined(height)) {
        return UIViewContentModeScaleAspectFit;
    } else {
        return UIViewContentModeScaleToFill;
    }
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    for (UIView *child in [self subviews]) {
        [TiUtils setView:child positionRect:bounds];
    }
    
    [super frameSizeChanged:frame bounds:bounds];
}


- (CGFloat)contentWidthForWidth:(CGFloat)suggestedWidth
{
    if (autoWidth > 0) {
        //If height is DIP returned a scaled autowidth to maintain aspect ratio
        if (TiDimensionIsDip(height) && autoHeight > 0) {
            return roundf(autoWidth * height.value / autoHeight);
        }
        return autoWidth;
    }
    
    CGFloat calculatedWidth = TiDimensionCalculateValue(width, autoWidth);
    if (calculatedWidth > 0) {
        return calculatedWidth;
    }
    
    return 0;
}

- (CGFloat)contentHeightForWidth:(CGFloat)width_
{
    if (width_ != autoWidth && autoWidth>0 && autoHeight > 0) {
        return (width_ * autoHeight/autoWidth);
    }
    
    if (autoHeight > 0) {
        return autoHeight;
    }
    
    CGFloat calculatedHeight = TiDimensionCalculateValue(height, autoHeight);
    if (calculatedHeight > 0) {
        return calculatedHeight;
    }
    
    return 0;
}

- (UIViewContentMode)contentMode
{
    if (TiDimensionIsAuto(width) || TiDimensionIsAutoSize(width) || TiDimensionIsUndefined(width) ||
        TiDimensionIsAuto(height) || TiDimensionIsAutoSize(height) || TiDimensionIsUndefined(height)) {
        return UIViewContentModeScaleAspectFit;
    } else {
        return UIViewContentModeScaleToFill;
    }
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == [self webView]) {
        if ([[self proxy] _hasListeners:@"progress"]) {
            [[self proxy] fireEvent:@"progress" withObject:@{
                @"progress": NUMDOUBLE([[self webView] estimatedProgress]),
                @"url": [[[self webView] URL] absoluteString]
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

#endif
