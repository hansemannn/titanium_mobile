/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-present by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

@interface TiErrorController : UIViewController {
@private
	NSString *_error;
    NSArray<NSString *> *_callStackSymbols;
    UILabel *_messageLabel;
    UIButton *_dismissButton;
    UIScrollView *_scrollView;
    UILabel *_titleLabel;
}

-(id)initWithError:(NSString*)error_;

@end

@interface UIColor (ErrorColors)

+ (UIColor *)errorBackgroundColor;

+ (UIColor *)errorDismissButtonBackgroundColor;

+ (UIColor *)errorTitleBackgroundColor;

@end
