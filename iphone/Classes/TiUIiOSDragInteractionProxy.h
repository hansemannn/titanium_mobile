/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#if __IPHONE_11_0

#import "TiProxy.h"
#import "TiUIViewProxy.h"
@interface TiUIiOSDragInteractionProxy : TiProxy<UIDragInteractionDelegate> {

}

@property (nonatomic, strong) TiUIViewProxy *sourceView;

@end

#endif
