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

@end

#endif
