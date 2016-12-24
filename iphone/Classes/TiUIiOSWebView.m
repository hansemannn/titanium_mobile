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

extern NSString * const TI_APPLICATION_ID;

static NSString * const kTitaniumJavascript = @"Ti.App={};Ti.API={};Ti.App._listeners={};Ti.App._listener_id=1;Ti.App.id=Ti.appId;Ti.App._xhr=XMLHttpRequest;"
"Ti._broker=function(module,method,data){try{var url='app://'+Ti.appId+'/_TiA0_'+Ti.pageToken+'/'+module+'/'+method+'?'+Ti.App._JSON(data,1);"
"var xhr=new Ti.App._xhr();xhr.open('GET',url,false);xhr.send()}catch(X){}};"
"Ti._hexish=function(a){var r='';var e=a.length;var c=0;var h;while(c<e){h=a.charCodeAt(c++).toString(16);r+='\\\\u';var l=4-h.length;while(l-->0){r+='0'};r+=h}return r};"
"Ti._bridgeEnc=function(o){return'<'+Ti._hexish(o)+'>'};"
"Ti.App._JSON=function(object,bridge){var type=typeof object;switch(type){case'undefined':case'function':case'unknown':return undefined;case'number':case'boolean':return object;"
"case'string':if(bridge===1)return Ti._bridgeEnc(object);return'\"'+object.replace(/\"/g,'\\\\\"').replace(/\\n/g,'\\\\n').replace(/\\r/g,'\\\\r')+'\"'}"
"if((object===null)||(object.nodeType==1))return'null';if(object.constructor.toString().indexOf('Date')!=-1){return'new Date('+object.getTime()+')'}"
"if(object.constructor.toString().indexOf('Array')!=-1){var res='[';var pre='';var len=object.length;for(var i=0;i<len;i++){var value=object[i];"
"if(value!==undefined)value=Ti.App._JSON(value,bridge);if(value!==undefined){res+=pre+value;pre=', '}}return res+']'}var objects=[];"
"for(var prop in object){var value=object[prop];if(value!==undefined){value=Ti.App._JSON(value,bridge)}"
"if(value!==undefined){objects.push(Ti.App._JSON(prop,bridge)+': '+value)}}return'{'+objects.join(',')+'}'};"
"Ti.App._dispatchEvent=function(type,evtid,evt){var listeners=Ti.App._listeners[type];if(listeners){for(var c=0;c<listeners.length;c++){var entry=listeners[c];if(entry.id==evtid){entry.callback.call(entry.callback,evt)}}}};Ti.App.fireEvent=function(name,evt){Ti._broker('App','fireEvent',{name:name,event:evt})};Ti.API.log=function(a,b){Ti._broker('API','log',{level:a,message:b})};Ti.API.debug=function(e){Ti._broker('API','log',{level:'debug',message:e})};Ti.API.error=function(e){Ti._broker('API','log',{level:'error',message:e})};Ti.API.info=function(e){Ti._broker('API','log',{level:'info',message:e})};Ti.API.fatal=function(e){Ti._broker('API','log',{level:'fatal',message:e})};Ti.API.warn=function(e){Ti._broker('API','log',{level:'warn',message:e})};Ti.App.addEventListener=function(name,fn){var listeners=Ti.App._listeners[name];if(typeof(listeners)=='undefined'){listeners=[];Ti.App._listeners[name]=listeners}var newid=Ti.pageToken+Ti.App._listener_id++;listeners.push({callback:fn,id:newid});Ti._broker('App','addEventListener',{name:name,id:newid})};Ti.App.removeEventListener=function(name,fn){var listeners=Ti.App._listeners[name];if(listeners){for(var c=0;c<listeners.length;c++){var entry=listeners[c];if(entry.callback==fn){listeners.splice(c,1);Ti._broker('App','removeEventListener',{name:name,id:entry.id});break}}}};";

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
        // Inject Titanium event support
        [[[[self webView] configuration] userContentController] addUserScript:[TiUIiOSWebView userScriptTitaniumGlobalEventSupport]];

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
    
    // Inject Titanium event support
    [[[[self webView] configuration] userContentController] addUserScript:[TiUIiOSWebView userScriptTitaniumGlobalEventSupport]];
    
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
    
    // Inject Titanium event support
    content = [[self class] content:[TiUtils stringValue:value] withInjection:[self titaniumInjection]];
    
    [[self webView] loadHTMLString:content baseURL:nil];
}

- (void)setDisableBounce_:(id)value
{
    [[self proxy] replaceValue:[value isEqual: @1] ? @0 : @1 forKey:@"disableBounce" notification:NO];
    [[[self webView] scrollView] setBounces:![TiUtils boolValue:value]];
}

- (id)disableBounce
{
    return NUMBOOL(![[[self webView] scrollView] bounces]);
}

- (void)setScrollsToTop_:(id)value
{
    [[self proxy] replaceValue:value forKey:@"scrollsToTop" notification:NO];
    [[[self webView] scrollView] setScrollsToTop:[TiUtils boolValue:value def:YES]];
}

- (id)scrollsToTop
{
    return NUMBOOL([[[self webView] scrollView] scrollsToTop]);
}

- (void)setAllowsBackForwardNavigationGestures_:(id)value
{
    [[self proxy] replaceValue:value forKey:@"allowsBackForwardNavigationGestures" notification:NO];
    [[self webView] setAllowsBackForwardNavigationGestures:[TiUtils boolValue:value def:NO]];
}

- (id)allowsBackForwardNavigationGestures
{
    return NUMBOOL([[self webView] allowsBackForwardNavigationGestures]);
}

- (void)setUserAgent_:(id)value
{
    [[self proxy] replaceValue:value forKey:@"userAgent" notification:NO];
    [[self webView] setCustomUserAgent:[TiUtils stringValue:value]];
}

- (id)userAgent
{
    return [[self webView] customUserAgent] ?: [NSNull null];
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

#pragma mark Utilities

- (NSString *)titaniumInjection
{
    if (pageToken==nil) {
        pageToken = [[NSString stringWithFormat:@"%lu",(unsigned long)[self hash]] retain];
        [(TiUIiOSWebViewProxy*)self.proxy setPageToken:pageToken];
    }
    
    NSMutableString *html = [[[NSMutableString alloc] init] autorelease];
    [html appendString:@"<script id='__ti_injection'>"];
    NSString *ti = [NSString stringWithFormat:@"%@%s",@"Ti","tanium"];
    [html appendFormat:@"window.%@={};window.Ti=%@;Ti.pageToken=%@;Ti.appId='%@';",ti,ti,pageToken,TI_APPLICATION_ID];
    [html appendString:kTitaniumJavascript];
    [html appendString:@"</script>"];
    
    return html;
}

+ (NSString *)content:(NSString *)content withInjection:(NSString *)injection
{
    if ([content length] == 0) {
        return content;
    }
    // attempt to make well-formed HTML and inject in our Titanium bridge code
    // However, we only do this if the content looks like HTML
    NSRange range = [content rangeOfString:@"<html"];
    if (range.location == NSNotFound) {
        //TODO: Someone did a DOCTYPE, and our search wouldn't find it. This search is tailored for him
        //to cause the bug to go away, but is this really the right thing to do? Shouldn't we have a better
        //way to check?
        range = [content rangeOfString:@"<!DOCTYPE html"];
    }
    
    if (range.location != NSNotFound) {
        NSMutableString *html = [[NSMutableString alloc] initWithCapacity:[content length]+2000];
        NSRange nextRange = [content rangeOfString:@">" options:0 range:NSMakeRange(range.location, [content length]-range.location) locale:nil];
        if (nextRange.location != NSNotFound) {
            [html appendString:[content substringToIndex:nextRange.location+1]];
            [html appendString:injection];
            [html appendString:[content substringFromIndex:nextRange.location+1]];
        } else {
            // oh well, just jack it in
            [html appendString:injection];
            [html appendString:content];
        }
        
        return [html autorelease];
    }
    return content;
}

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

+ (WKUserScript*)userScriptTitaniumGlobalEventSupport
{
    NSString *pageToken = [NSString stringWithFormat:@"%lu",(unsigned long)[self hash]];
    NSString *ti = [NSString stringWithFormat:@"%@%s",@"Ti","tanium"];
    NSString *config = [NSString stringWithFormat:@"window.%@={};window.Ti=%@;Ti.pageToken=%@;Ti.appId='%@';",ti, ti, pageToken,TI_APPLICATION_ID];
    
    return [[WKUserScript alloc] initWithSource:[NSString stringWithFormat:@"%@ %@", config, kTitaniumJavascript]
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
    if ([arg isKindOfClass:[TiFilesystemFileProxy class]])
    {
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
            NSLog(@"[ERROR] Evaluating JavaScript failed : %@", [error localizedDescription]);
            completionHandler(nil, error);
        }
    }];
}

#pragma mark TiEvaluator

- (void)evalFile:(NSString*)path
{
    NSURL *url_ = [path hasPrefix:@"file:"] ? [NSURL URLWithString:path] : [NSURL fileURLWithPath:path];
    
    if (![path hasPrefix:@"/"] && ![path hasPrefix:@"file:"]) {
        NSURL *root = [[[self proxy] _host] baseURL];
        url_ = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",root,path]];
    }
    
    NSString *sourceCode = [NSString stringWithContentsOfURL:url_ encoding:NSUTF8StringEncoding error:nil];
    [[[[self webView] configuration] userContentController] addUserScript:[TiUIiOSWebView userScriptTitaniumJSEvaluationFromString:sourceCode]];
}

- (void)fireEvent:(id)listener withObject:(id)obj remove:(BOOL)yn thisObject:(id)thisObject_
{
    // don't bother firing an app event to the webview if we don't have a webview yet created
    if ([self webView] != nil)
    {
        NSDictionary *event = (NSDictionary*)obj;
        NSString *name = [event objectForKey:@"type"];
        NSString *sourceCode = [NSString stringWithFormat:@"Ti.App._dispatchEvent('%@',%@,%@);",name,listener,[SBJSON stringify:event]];
        
        [self stringByEvaluatingJavaScriptFromString:sourceCode withCompletionHandler:^(NSString *result, NSError *error) {
            // Evaluated
        }];
    }
}

+ (WKUserScript*)userScriptTitaniumJSEvaluationFromString:(NSString*)string
{
    return [[WKUserScript alloc] initWithSource:string
                                  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                               forMainFrameOnly:YES];
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
            @"mainFrame": NUMBOOL(message.frameInfo.isMainFrame)
        }];
    }
}

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
