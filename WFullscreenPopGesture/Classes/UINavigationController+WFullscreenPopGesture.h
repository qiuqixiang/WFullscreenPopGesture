//
//  UINavigationController+WFullscreenPopGesture.h
//  Pods-WFullscreenPopGesture_Example
//
//  Created by qiuqixiang on 2020/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WNavigationBar;

// MARK - delegate
@interface _WFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

// MARK - UINavigationController
@interface UINavigationController (WFullscreenPopGesture)

/// The gesture recognizer that actually handles interactive pop.
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *wFullscreenPopGestureRecognizer;

/// A view controller is able to control navigation bar's appearance by itself,
/// rather than a global way, checking "fd_prefersNavigationBarHidden" property.
/// Default to YES, disable it if you don't want so.
@property (nonatomic, assign) BOOL wViewControllerBasedNavigationBarAppearanceEnabled;

/// 是否开启fd功能，默认NO
@property (nonatomic, assign) BOOL wOpen;

// 默认返回按钮: image/UIView
@property (strong,nonatomic) id wBackItem;

@end

/// Allows any view controller to disable interactive pop gesture, which might
/// be necessary when the view controller itself handles pan gesture in some
/// cases.
@interface UIViewController (WFullscreenPopGesture)

/// Whether the interactive pop gesture is disabled when contained in a navigation
/// stack.
@property (nonatomic, assign) BOOL wInteractivePopDisabled;

/// Indicate this view controller prefers its navigation bar hidden or not,
/// checked when view controller based navigation bar's appearance is enabled.
/// Default to NO, bars are more likely to show.
@property (nonatomic, assign) BOOL wPrefersNavigationBarHidden;

/// Max allowed initial distance to left edge when you begin the interactive pop
/// gesture. 0 by default, which means it will ignore this limit.
@property (nonatomic, assign) CGFloat wInteractivePopMaxAllowedInitialDistanceToLeftEdge;

/// 是否显示自定义导航栏
@property (nonatomic, assign) BOOL wShowCustomNavigationBar;

/// 自定义NavigationBar
@property (strong,nonatomic,readonly) UINavigationBar *wCustomNavigationBar;

@end

// MARK - WNavigationBar
// 一定要重写bgroundView的frame
@interface WNavigationBar : UINavigationBar


@end


NS_ASSUME_NONNULL_END
