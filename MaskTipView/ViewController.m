//
//  ViewController.m
//  MaskTipView
//
//  Created by Mac on 2018/11/29.
//  Copyright © 2018 DuWenliang. All rights reserved.
//

#import "ViewController.h"
#import "DWL_MaskTipView.h"


@interface ViewController ()

@property (nonatomic,strong) UIButton *btn;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_btn setTitle:@"right" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_btn];
}

-(void)go
{
    CGRect frameInNaviView = [self.navigationController.view convertRect:_btn.frame fromView:_btn.superview];
    
    [DWL_MaskTipView showWithFrame:[UIScreen mainScreen].bounds focusFrames:@[@(frameInNaviView), @(CGRectMake(0, 100, 100, 120)), @(CGRectMake(100, 500, 50, 50)), @(CGRectMake(100, 200, 40, 50))] focusShapes:@[@(dRectShape), @(dStarShape), @(dOtherShape), @(dCircleShape)]];
}



@end
