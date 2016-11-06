/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#ifdef USE_TI_APPIOSONDEMANDRESOURCESMANAGER
#import "TiProxy.h"

@interface TiAppiOSOnDemandResourcesManagerProxy : TiProxy<NSProgressReporting> {
@private
    NSBundleResourceRequest *resourceRequest;
}

- (void)conditionallyBeginAccessingResources:(id)args;
- (void)endAccessingResources;
- (void)setPriority:(id)value;
- (id)priority;

@end

#endif
