/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#ifdef USE_TI_UIIOSSYSTEMBUTTONSTYLE

#import "TiUIiOSSystemButtonStyleProxy.h"
#import "TiBase.h"

@implementation TiUIiOSSystemButtonStyleProxy

-(NSString*)apiName
{
    return @"Ti.UI.iOS.SystemButtonStyle";
}

MAKE_SYSTEM_PROP(DONE,UIBarButtonItemStyleDone);
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
MAKE_SYSTEM_PROP_DEPRECATED_REMOVED(BORDERED,UIBarButtonItemStyleBordered,@"UI.iOS.SystemButtonStyle.PLAIN",@"6.1.0",@"7.0.0");
#pragma GCC diagnostic pop
MAKE_SYSTEM_PROP(PLAIN,UIBarButtonItemStylePlain);
@end

#endif
