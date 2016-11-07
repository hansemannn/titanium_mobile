/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#ifdef USE_TI_UIIOSWEBVIEW

#import "TiUIView.h"
#import "TiDimension.h"
#import <WebKit/WebKit.h>

@interface TiUIiOSWebView : TiUIView <WKUIDelegate, WKNavigationDelegate> {
    WKWebView *_webView;
    
    TiDimension width;
    TiDimension height;
    CGFloat autoHeight;
    CGFloat autoWidth;
}

- (WKWebView*)webView;

@end

#endif
