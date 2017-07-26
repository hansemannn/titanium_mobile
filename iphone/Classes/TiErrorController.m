/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <QuartzCore/QuartzCore.h>
#import "TiErrorController.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiUtils.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@implementation UIColor (ErrorColors)

+ (UIColor *)errorBackgroundColor
{
    return Rgb2UIColor(192, 57, 43);
}

+ (UIColor *)errorDismissButtonBackgroundColor
{
    return Rgb2UIColor(205, 115, 115);
}

+ (UIColor *)errorTitleBackgroundColor
{
    return Rgb2UIColor(175, 50, 50);
}

@end

@implementation TiErrorController

- (instancetype)initWithError:(NSString *)error
{
    if (self = [super init]) {
        _error = error;
        _callStackSymbols = [NSThread callStackSymbols];
    }
    return self;
}

- (NSArray<UIKeyCommand *> *)keyCommands
{
    return @[[UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(dismiss:)]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [[self view] setBackgroundColor:[UIColor errorBackgroundColor]];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:30];
    _titleLabel.text = @"Application Error";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _messageLabel.text = [NSString stringWithFormat:@"\n%@\n", _error];
    _messageLabel.backgroundColor = [UIColor errorTitleBackgroundColor];
    _messageLabel.font = [UIFont systemFontOfSize:18];
    _messageLabel.numberOfLines = 0;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = [UIColor whiteColor];
    
    _scrollView = [[UIScrollView alloc] init];
    _dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.backgroundColor = [UIColor blueColor];
    
    UILabel *stackTrace = [[UILabel alloc] init];
    stackTrace.translatesAutoresizingMaskIntoConstraints = NO;
    stackTrace.numberOfLines = 0;
    stackTrace.text = [_callStackSymbols componentsJoinedByString:@"\n"];
    stackTrace.font = [UIFont fontWithName:@"Menlo" size:14];
    stackTrace.textColor = [UIColor whiteColor];
    
    _dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    _dismissButton.tintColor = [UIColor whiteColor];
    _dismissButton.backgroundColor = [UIColor errorDismissButtonBackgroundColor];
    [_dismissButton setTitle:@"Dismiss (or ⎋ ESC)" forState:UIControlStateNormal];
    
    /*
     * Title constraints
     */
    
    NSLayoutConstraint *titleConstraint1 = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.view
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0
                                                                               constant:20];
    
    NSLayoutConstraint *titleConstraint2 = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1
                                                                         constant:20];
    
    NSLayoutConstraint *titleConstraint3 = [NSLayoutConstraint constraintWithItem:self.view
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_titleLabel
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1
                                                                         constant:20];
    
    /*
     * Message constraints
     */

    NSLayoutConstraint *messageConstraint1 = [NSLayoutConstraint constraintWithItem:_messageLabel
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_titleLabel
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:60];
    
    NSLayoutConstraint *messageConstraint2 = [NSLayoutConstraint constraintWithItem:_messageLabel
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1
                                                                         constant:20];
    
    NSLayoutConstraint *messageConstraint3 = [NSLayoutConstraint constraintWithItem:self.view
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_messageLabel
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:20];
    
    /*
     * Scroll View constraints
     */
    
    // FIXME: Add ScrollView / StackTrace constraints
    
    /*
     * Dismiss button constraints
     */
    
    NSLayoutConstraint *dismissButtonConstraint1 = [NSLayoutConstraint constraintWithItem:_dismissButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:-20];
    
    NSLayoutConstraint *dismissButtonConstraint2 = [NSLayoutConstraint constraintWithItem:_dismissButton
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1
                                                                         constant:20];
    
    NSLayoutConstraint *dismissButtonConstraint3 = [NSLayoutConstraint constraintWithItem:self.view
                                                                                attribute:NSLayoutAttributeTrailing
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:_dismissButton
                                                                                attribute:NSLayoutAttributeTrailing
                                                                               multiplier:1
                                                                                 constant:20];
    
    NSLayoutConstraint *dismissButtonConstraint4 = [NSLayoutConstraint constraintWithItem:_dismissButton
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1
                                                                                 constant:40];
    
    [_scrollView addSubview:stackTrace];

    [[self view] addSubview:_titleLabel];
    [[self view] addSubview:_messageLabel];
    [[self view] addSubview:_scrollView];
    [[self view] addSubview:_dismissButton];
    
    [[self view] addConstraint:titleConstraint1];
    [[self view] addConstraint:titleConstraint2];
    [[self view] addConstraint:titleConstraint3];
    
    [[self view] addConstraint:messageConstraint1];
    [[self view] addConstraint:messageConstraint2];
    [[self view] addConstraint:messageConstraint3];
    
    [[self view] addConstraint:dismissButtonConstraint1];
    [[self view] addConstraint:dismissButtonConstraint2];
    [[self view] addConstraint:dismissButtonConstraint3];
    [[self view] addConstraint:dismissButtonConstraint4];

    [_dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _messageLabel.preferredMaxLayoutWidth = _messageLabel.frame.size.width;
    _titleLabel.preferredMaxLayoutWidth = _titleLabel.frame.size.width;
    
    [[self view] layoutIfNeeded];
}

- (void)dismiss:(id)sender
{
    [[TiApp app] hideModalController:self animated:YES];
}

@end
