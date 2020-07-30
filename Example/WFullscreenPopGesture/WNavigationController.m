//
//  WNavigationController.m
//  WFullscreenPopGesture_Example
//
//  Created by qiuqixiang on 2020/7/30.
//  Copyright © 2020 qiuqixiang. All rights reserved.
//

#import "WNavigationController.h"

#import "UINavigationController+WFullscreenPopGesture.h"
@interface WNavigationController ()

@end

@implementation WNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wBackItem = [UIImage imageNamed:@"navBack"];
    self.wOpen = YES;
}


- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
