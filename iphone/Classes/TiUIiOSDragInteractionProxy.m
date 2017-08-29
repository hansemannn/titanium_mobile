/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#if __IPHONE_11_0

#import "TiUIiOSDragInteractionProxy.h"

@implementation TiUIiOSDragInteractionProxy

- (id)_initWithPageContext:(id<TiEvaluator>)context
{
  if (self = [super _initWithPageContext:context]) {

  }
  
  return self;
}

#pragma mark UIDragInteractionDelegate

- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session
{
  CGPoint location = [session locationInView:[[self sourceView] view]];
  id localObject = [[[self sourceView] view] hitTest:location withEvent:nil];
  id dragContent = [localObject valueForKey:@"dragContent"];
  
  if (dragContent == nil) {
    NSLog(@"[WARN] The view does not contain drag-content, skipping ...");
    return @[];
  }
  
  NSItemProvider *itemProvider = nil;
  
  if ([dragContent isKindOfClass:[NSString class]]) {
      itemProvider = [[NSItemProvider alloc] initWithObject:dragContent];
  } else {
      NSLog(@"[ERROR] Unsupported drag-content-type provided: %@", [dragContent class]);
      return @[];
  }

  if (itemProvider == nil) {
    NSLog(@"[ERROR] Could not find suitable drag-content, returning ...");
    return @[];
  }
  
  UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
  item.localObject = localObject;
  
  return @[item];
}

- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session
{
  return [[UITargetedDragPreview alloc] initWithView:interaction.view];
}

- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session
{
  
}

- (void)dragInteraction:(UIDragInteraction *)interaction sessionWillBegin:(id<UIDragSession>)session
{
  if ([self _hasListeners:@"dragstart"]) {
    [self fireEvent:@"dragstart"];
  }
}

- (BOOL)dragInteraction:(UIDragInteraction *)interaction sessionAllowsMoveOperation:(id<UIDragSession>)session
{
  return YES;
}

- (BOOL)dragInteraction:(UIDragInteraction *)interaction sessionIsRestrictedToDraggingApplication:(id<UIDragSession>)session
{
  return NO;
}

- (BOOL)dragInteraction:(UIDragInteraction *)interaction prefersFullSizePreviewsForSession:(id<UIDragSession>)session
{
  return NO;
}

- (void)dragInteraction:(UIDragInteraction *)interaction sessionDidMove:(id<UIDragSession>)session
{
  if ([self _hasListeners:@"dragmove"]) {
    [self fireEvent:@"dragmove"];
  }
}

- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session willEndWithOperation:(UIDropOperation)operation
{
  if ([self _hasListeners:@"dragwillend"]) {
    [self fireEvent:@"dragwillend"];
  }
}

- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation
{
  if ([self _hasListeners:@"dragend"]) {
    [self fireEvent:@"dragend"];
  }
}

- (void)dragInteraction:(UIDragInteraction *)interaction sessionDidTransferItems:(id<UIDragSession>)session
{
  if ([self _hasListeners:@"complete"]) {
    [self fireEvent:@"complete"];
  }
}

- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForAddingToSession:(id<UIDragSession>)session withTouchAtPoint:(CGPoint)point
{
  return @[];
}

- (nullable id<UIDragSession>)dragInteraction:(UIDragInteraction *)interaction sessionForAddingItems:(NSArray<id<UIDragSession>> *)sessions withTouchAtPoint:(CGPoint)point
{
  return nil;
}

- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session willAddItems:(NSArray<UIDragItem *> *)items forInteraction:(UIDragInteraction *)addingInteraction
{
  
}

- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForCancellingItem:(UIDragItem *)item withDefault:(UITargetedDragPreview *)defaultPreview
{
  return nil;
}

- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator
{
  
}

@end

#endif
