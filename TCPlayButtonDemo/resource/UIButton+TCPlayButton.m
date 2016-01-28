//
//  UIButton+TCPlayButton.m
//  Demo
//
//  Created by TonyChan on 16/1/18.
//  Copyright © 2016年 TonyChan. All rights reserved.
//

#import "UIButton+TCPlayButton.h"

#import <objc/runtime.h>

static const CFTimeInterval duration = 0.2f;
static const CGFloat margin = 0.2f;

@interface UIButton ()

@property (nonatomic, strong) CAShapeLayer *pauseLineLayer0;
@property (nonatomic, strong) CAShapeLayer *pauseLineLayer1;
@property (nonatomic, copy) PlayState playState;
@property (nonatomic, assign) BOOL play;

@end

@implementation UIButton (TCPlayButton)

#pragma mark - initialize property

- (void)setPlayState:(PlayState)playState
{
    objc_setAssociatedObject(self, @selector(playState), playState, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (PlayState)playState
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlay:(BOOL)play
{
    objc_setAssociatedObject(self, @selector(play), @(play), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)play
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    return NO;
}

- (void)setPauseLineLayer0:(CAShapeLayer *)pauseLineLayer0
{
    objc_setAssociatedObject(self, @selector(pauseLineLayer0), pauseLineLayer0, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)pauseLineLayer0
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPauseLineLayer1:(CAShapeLayer *)pauseLineLayer1
{
    objc_setAssociatedObject(self, @selector(pauseLineLayer1), pauseLineLayer1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)pauseLineLayer1
{
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - swizzled setFrame

+ (void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setFrame:);
        SEL swizzledSelector = @selector(tc_setFrame:);
        
        Method originalMethod = class_getInstanceMethod(class,
                                                        originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class,
                                                        swizzledSelector);
        
        BOOL success = class_addMethod(class,
                                       originalSelector,
                                       method_getImplementation(swizzledMethod),
                                       method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod,
                                           swizzledMethod);
        }
    });
}

- (void)tc_setFrame:(CGRect)frame
{
    [self tc_setFrame:frame];
    if (self.buttonType == (UIButtonType)UIButtonTypeTCPlay) {
        CGSize selfSize = self.frame.size;
        CGFloat edge = MIN(selfSize.width, selfSize.height);
        
        CALayer *backLayer = [[CALayer alloc] init];
        backLayer.frame = CGRectMake(edge*margin, edge*margin, edge*(1-margin*2), edge*(1-margin*2));
        backLayer.backgroundColor = [[UIColor clearColor] CGColor];
        [self.layer addSublayer:backLayer];
        
        UIColor *color = [UIColor blueColor];
        self.pauseLineLayer0 = [CAShapeLayer layer];
        self.pauseLineLayer0.fillColor = [color CGColor];
        [backLayer addSublayer:self.pauseLineLayer0];
        
        self.pauseLineLayer1 = [CAShapeLayer layer];
        self.pauseLineLayer1.fillColor = [color CGColor];
        [backLayer addSublayer:self.pauseLineLayer1];
        
        if (self.play) {
            [self.pauseLineLayer0 setPath:[[self paths][0] CGPath]];
            [self.pauseLineLayer1 setPath:[[self paths][1] CGPath]];
        } else{
            [self.pauseLineLayer0 setPath:[[self paths][2] CGPath]];
            [self.pauseLineLayer1 setPath:[[self paths][3] CGPath]];
        }
        
        [self addTarget:self action:@selector(playButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Action

- (void)playState:(BOOL)play
{
    [self goAnimation:play];
}

- (void)backTintColor:(UIColor *)color
{
    self.pauseLineLayer0.fillColor = [color CGColor];
    self.pauseLineLayer1.fillColor = [color CGColor];
}

- (void)touchUpInside:(PlayState)playState
{
    if (playState) {
        self.playState = playState;
    }
}

- (void)playButtonTap:(UIButton *)sender
{
    [self goAnimation:self.play];
}

- (void)goAnimation:(BOOL)play
{
    CGPathRef fromePath0 = play?([[self paths][0] CGPath]):([[self paths][2] CGPath]);
    CGPathRef toPath0 = play?([[self paths][2] CGPath]):([[self paths][0] CGPath]);
    CGPathRef fromePath1 = play?([[self paths][1] CGPath]):([[self paths][3] CGPath]);
    CGPathRef toPath1 = play?([[self paths][3] CGPath]):([[self paths][1] CGPath]);

    [CATransaction begin];
    CABasicAnimation *pathAnimation0 = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation0.duration = duration;
    pathAnimation0.fromValue = (__bridge id _Nullable)(fromePath0);
    pathAnimation0.toValue = (__bridge id _Nullable)(toPath0);
    pathAnimation0.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.pauseLineLayer0 addAnimation:pathAnimation0 forKey:nil];
    
    CABasicAnimation *pathAnimation1 = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation1.duration = duration;
    pathAnimation1.fromValue = (__bridge id _Nullable)(fromePath1);
    pathAnimation1.toValue = (__bridge id _Nullable)(toPath1);
    pathAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.pauseLineLayer1 addAnimation:pathAnimation1 forKey:nil];
    
    [CATransaction setCompletionBlock:^{
        [self.pauseLineLayer0 setPath:toPath0];
        [self.pauseLineLayer1 setPath:toPath1];
        self.play = !play;
        if (self.playState) {
            self.playState(self.play, self);
        }
    }];
    [CATransaction commit];
}

- (NSArray *)paths
{
    CGSize selfSize = self.frame.size;
    CGFloat edge = (MIN(selfSize.width, selfSize.height)*(1-margin*2));
    CGFloat wide = edge*sin(M_PI/3)/3;
    
    UIBezierPath *pauseLinePath0 = [UIBezierPath bezierPath];
    [pauseLinePath0 moveToPoint:CGPointMake(0, 0)];
    [pauseLinePath0 addLineToPoint:CGPointMake(wide, 0)];
    [pauseLinePath0 addLineToPoint:CGPointMake(wide, edge)];
    [pauseLinePath0 addLineToPoint:CGPointMake(0, edge)];
    [pauseLinePath0 closePath];
    
    UIBezierPath *pauseLinePath1 = [UIBezierPath bezierPath];
    [pauseLinePath1 moveToPoint:CGPointMake(2*wide, 0)];
    [pauseLinePath1 addLineToPoint:CGPointMake(3*wide, 0)];
    [pauseLinePath1 addLineToPoint:CGPointMake(3*wide, edge)];
    [pauseLinePath1 addLineToPoint:CGPointMake(2*wide, edge)];
    [pauseLinePath1 closePath];
    
    UIBezierPath *playLinePath0 = [UIBezierPath bezierPath];
    [playLinePath0 moveToPoint:CGPointMake(0, 0)];
    [playLinePath0 addLineToPoint:CGPointMake(wide*1.5, (wide/2)*tan(M_PI/3))];
    [playLinePath0 addLineToPoint:CGPointMake(wide*1.5, edge-(wide/2)*tan(M_PI/3))];
    [playLinePath0 addLineToPoint:CGPointMake(0, edge)];
    [playLinePath0 closePath];
    
    UIBezierPath *playLinePath1 = [UIBezierPath bezierPath];
    [playLinePath1 moveToPoint:CGPointMake(wide*1.5, (wide/2)*tan(M_PI/3))];
    [playLinePath1 addLineToPoint:CGPointMake(3*wide, edge/2)];
    [playLinePath1 addLineToPoint:CGPointMake(3*wide, edge/2)];
    [playLinePath1 addLineToPoint:CGPointMake(wide*1.5, edge-(wide/2)*tan(M_PI/3))];
    [playLinePath1 closePath];
    
    return @[pauseLinePath0, pauseLinePath1, playLinePath0, playLinePath1];
}

@end
