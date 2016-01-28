//
//  ViewController.m
//  TCPlayButtonDemo
//
//  Created by TonyChan on 16/1/19.
//  Copyright © 2016年 TonyChan. All rights reserved.
//

#import "ViewController.h"

#import "UIButton+TCPlayButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     *  demo
     */
    UIButton *playBtton = [UIButton buttonWithType:UIButtonTypeTCPlay];
    playBtton.frame = CGRectMake(100, 100, 100, 100);
    [playBtton playState:NO];
    [playBtton backTintColor:[UIColor orangeColor]];
    [playBtton touchUpInside:^(BOOL play, UIButton *button) {
        NSLog(@"play - %d", play);
    }];
    [self.view addSubview:playBtton];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
