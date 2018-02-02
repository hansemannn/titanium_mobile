/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2018 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"

@interface TiPromiseProxy : TiProxy {
  KrollCallback *_then;
  KrollCallback *_catch;
}

- (void)resolve:(id)value;

- (void)reject:(id)value;

- (TiPromiseProxy *)then:(id)callback;

- (TiPromiseProxy *)catch:(id)callback;

@end
