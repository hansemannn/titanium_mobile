/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2018 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiPromiseProxy.h"

@implementation TiPromiseProxy

- (NSString *)apiName
{
  return @"Promise";
}

- (void)dealloc
{
  RELEASE_TO_NIL(_then);
  RELEASE_TO_NIL(_catch);

  [super dealloc];
}

- (void)resolve:(id)value
{
  [_then call:@[value] thisObject:self];
}

- (void)reject:(id)value
{
  [_catch call:@[value] thisObject:self];
}

- (TiPromiseProxy *)then:(id)callback
{
  ENSURE_SINGLE_ARG(callback, KrollCallback);

  RELEASE_TO_NIL(_then);
  _then = [callback retain];

  return self;
}

- (TiPromiseProxy *)catch:(id)callback
{
  ENSURE_SINGLE_ARG(callback, KrollCallback);

  RELEASE_TO_NIL(_catch);
  _catch = [callback retain];

  return self;
}

@end
