//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Christopher Allen on 9/18/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional

- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPinchZoom:(UIPinchGestureRecognizer *)recognizer;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didLongPress:(UILongPressGestureRecognizer *)recognizer;

@end

@interface AwesomeFloatingToolbar : UIView

- (instancetype) initWithFourTitles:(NSArray *)titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

// moved here for tap gesture access to toolbar properties
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;

@end