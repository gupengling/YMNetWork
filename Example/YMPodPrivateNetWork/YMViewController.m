//
//  YMViewController.m
//  YMPodPrivateNetWork
//
//  Created by gupengling on 12/27/2018.
//  Copyright (c) 2018 gupengling. All rights reserved.
//

#import "YMViewController.h"
#import "YMNetWork.h"

@interface YMViewController ()

@end

@implementation YMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    YMNetWork *ym = [[YMNetWork alloc] init];
    [ym test:@"dodododoodoodododododododoodo"];

    XYZNet *net = [[XYZNet alloc] initWithBaseURL:[NSURL URLWithString:@""]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
