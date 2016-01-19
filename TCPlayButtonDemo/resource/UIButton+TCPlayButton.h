//
//  UIButton+TCPlayButton.h
//  Demo
//
//  Created by TonyChan on 16/1/18.
//  Copyright © 2016年 TonyChan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PlayState)(BOOL play, UIButton *button);

enum{
    UIButtonTypeTCPlay = 100
};

@interface UIButton (TCPlayButton)

/**
 *  set default state
 *
 *  @param play necessary
 */
- (void)playState:(BOOL)play;

/**
 *  set tintcolor
 *
 *  @param color necessary
 */
- (void)backTintColor:(UIColor *)color;

/**
 *  touch call back
 *
 *  @param playState call back block
 */
- (void)touchUpInside:(PlayState)playState;

@end
