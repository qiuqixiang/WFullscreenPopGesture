//
//  WFULLSCREENPOPGESTUREPREFIXAppDelegate.m
//  WFullscreenPopGesture
//
//  Created by qiuqixiang on 07/30/2020.
//  Copyright (c) 2020 qiuqixiang. All rights reserved.
//

#import "WFULLSCREENPOPGESTUREPREFIXAppDelegate.h"
#import "WFULLSCREENPOPGESTUREPREFIXViewController.h"
#import "WNavigationController.h"
@implementation WFULLSCREENPOPGESTUREPREFIXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = UIColor.whiteColor;
        
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
        [UINavigationBar appearance].shadowImage = [UIImage new];
        [[UINavigationBar appearance] setBackgroundImage:[self imageWithColor:[UIColor orangeColor] andSize:CGSizeMake(1, 1)] forBarMetrics:0];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blueColor,
        NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0f]}];
    //    [UINavigationBar appearance].translucent = NO;
        
        
        WNavigationController *navi = [[WNavigationController alloc] initWithRootViewController:[WFULLSCREENPOPGESTUREPREFIXViewController new]];
           navi.modalPresentationStyle = UIModalPresentationFullScreen;
        self.window.rootViewController = navi;
    // Override point for customization after application launch.
    return YES;
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
