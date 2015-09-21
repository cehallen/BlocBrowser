//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Christopher Allen on 9/18/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

/** for assgnmt 26 - the part about replacing the toolbar labels with buttons
 - basic button tap
    http://stackoverflow.com/questions/1378765/how-do-i-create-a-basic-uibutton-programmatically
 
 - there are useful signals built in to buttons you can access with UIButton instance method 'addTarget:forControlEvents:'.  
    eg: UIControlEventTouchDown, UIControlEventTouchUpInside, UIControlEventTouchUpOutside, UIControlEventTouchCancel, etc.
    see docs for more: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIControl_Class/#//apple_ref/doc/constant_group/Control_Events
    you can use them to change opacity a la the labels before.  see first answer here for implementation deets:
    http://stackoverflow.com/questions/16615514/uibutton-press-and-hold-repeat-action-until-let-go
 
 - http://stackoverflow.com/questions/903114/way-to-make-a-uibutton-continuously-fire-during-a-press-and-hold-situation?lq=1
    second answer
 */

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
//@property (nonatomic, weak) UILabel *currentLabel;  // what does this do?? check bloc.  A: 'keeps track of which label user is currently touching
@property (nonatomic, weak) UIButton *currentButton;  // not sure if needed but I added this for same purpose as above
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles { /* ? what is 'instancetype'.   */
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        /**
         replace labels with buttons and remove tap gesture to enable
         - remember to change .h file, and references in ViewController to the labels
         */
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
//            button.userInteractionEnabled = YES; // necessary?
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:12]];  // how to make dynamic for bigger devices?
            button.backgroundColor = colorForThisButton;
            
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
        }
        
//        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
//        
//        // Make the 4 labels
//        for (NSString *currentTitle in self.currentTitles) {
//            UILabel *label = [[UILabel alloc] init];
//            label.userInteractionEnabled = NO;
//            label.alpha = 0.25;
//            
//            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
//            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
//            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
//            
//            label.textAlignment = NSTextAlignmentCenter;
//            label.font = [UIFont systemFontOfSize:10];
//            label.text = titleForThisLabel;
//            label.backgroundColor = colorForThisLabel;
//            label.textColor = [UIColor whiteColor];
//            
//            [labelsArray addObject:label];
//        }
//        
//        self.labels = labelsArray;
//        
//        for (UILabel *thisLabel in self.labels) {
//            [self addSubview:thisLabel];
//        }
        
//        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];  /** notice the empty parameter after tapFired and panFired...  in the methods there ARE arguments (the ).  some automatic stuff going on. */
//        [self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}

- (void) layoutSubviews {
    
    /* change to button layout */
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            buttonY = 0;
        } else {
            // 2 or 3, so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }

        if (currentButtonIndex % 2 == 0) {
            // 0 or 2, so on the left
            buttonX = 0;
        } else {
            // 1 or 3, so on the right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
    
//    for (UILabel *thisLabel in self.labels) {
//        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
//        
//        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;  /* ? where does 'self' have bounds from at this point?  A: this is the whole toolbars bounds, set in the initializer */
//        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
//        CGFloat labelX = 0;
//        CGFloat labelY = 0;
//        
//        // adjust labelX and labelY for each label
//        if (currentLabelIndex < 2) {
//            // 0 or 1, so on top
//            labelY = 0;
//        } else {
//            // 2 or 3, so on bottom
//            labelY = CGRectGetHeight(self.bounds) / 2;
//        }
//        
//        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
//            // 0 or 2, so on the left
//            labelX = 0;
//        } else {
//            // 1 or 3, so on the right
//            labelX = CGRectGetWidth(self.bounds) / 2;
//        }
//        
//        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
//    }
    



}



#pragma mark - Touch Handling

/* change to buttons */
- (void) buttonPressed:(UIButton *)sender {
    if ([self.buttons containsObject:sender]) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)sender).currentTitle];
        }
    }
}

//- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self];
//    UIView *subview = [self hitTest:location withEvent:event];
//    
//    if ([subview isKindOfClass:[UILabel class]]) {
//        return (UILabel *)subview;
//    } else {
//        return nil;
//    }
//}
//
//- (void) tapFired:(UITapGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//        CGPoint location = [recognizer locationInView:self];
//        UIView *tappedView = [self hitTest:location withEvent:nil];
//        
//        if ([self.labels containsObject:tappedView]) {
//            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
//            }
//        }
//    }
//}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    //if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint translation = [recognizer translationInView:self];  /* gives nice new point read as difference in x and y, eg, {-10, 20}, which represents left 10, down 20.  */
        
//        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    //}
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    //if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
//        NSLog(@"New zoom scale: %f", recognizer.scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchZoom:)]) {
            [self.delegate floatingToolbar:self didTryToPinchZoom:recognizer];
        }
        
//        [recognizer setScale:1.0];  // doesn't seem to do anything
    //}
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didLongPress:)]) {
            [self.delegate floatingToolbar:self didLongPress:recognizer];
        }
    }
}



#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}



@end
