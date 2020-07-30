//
//  WFULLSCREENPOPGESTUREPREFIXViewController.m
//  WFullscreenPopGesture
//
//  Created by qiuqixiang on 07/30/2020.
//  Copyright (c) 2020 qiuqixiang. All rights reserved.
//

#import "WFULLSCREENPOPGESTUREPREFIXViewController.h"
#import "Demo0ViewController.h"
#import "UINavigationController+WFullscreenPopGesture.h"
@interface WFULLSCREENPOPGESTUREPREFIXViewController ()

@end

@implementation WFULLSCREENPOPGESTUREPREFIXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = NSStringFromClass([self class]);
    self.view.backgroundColor = UIColor.orangeColor;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction{
    Demo0ViewController *vc = [Demo0ViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
