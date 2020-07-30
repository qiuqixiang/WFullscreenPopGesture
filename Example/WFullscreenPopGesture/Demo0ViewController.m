//
//  Demo0ViewController.m
//  WZFullscreenPopGesture
//
//  Created by 牛胖胖 on 2019/12/4.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

#import "Demo0ViewController.h"
#import "Demo1ViewController.h"
#import "UINavigationController+WFullscreenPopGesture.h"
@interface Demo0ViewController ()

@end

@implementation Demo0ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSStringFromClass([self class]);
    self.view.backgroundColor = UIColor.orangeColor;
    [self addUITapGestureRecognizer];
    UINavigationBar *baaa = self.navigationController.navigationBar;
    BOOL  xxxx = self.navigationController.wOpen;
    NSLog(@"%f",baaa.frame.size.height);
}
 
- (void)addUITapGestureRecognizer{
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction{
    Demo1ViewController *vc = [Demo1ViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
