//
//  UINavigationController+WFullscreenPopGesture.m
//  Pods-WFullscreenPopGesture_Example
//
//  Created by qiuqixiang on 2020/7/30.
//

#import <objc/runtime.h>
#import "UINavigationController+WFullscreenPopGesture.h"

// 公共回调
typedef void (^_WViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

// MARK - _WFullscreenPopGestureRecognizerDelegate
@implementation _WFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.wInteractivePopDisabled) {
        return NO;
    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.wInteractivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }

    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL isLeftToRight = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier = isLeftToRight ? 1 : - 1;
    if ((translation.x * multiplier) <= 0) {
        return NO;
    }
    
    return YES;
}
@end


// MARK - 扩展协议
@interface UIViewController (FDFullscreenPopGesturePrivate)

@property (nonatomic, copy) _WViewControllerWillAppearInjectBlock fd_willAppearInjectBlock;

@end

@implementation UIViewController (FDFullscreenPopGesturePrivate)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method viewWillAppear_originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
        Method viewWillAppear_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewWillAppear:));
        method_exchangeImplementations(viewWillAppear_originalMethod, viewWillAppear_swizzledMethod);
    
        Method viewWillDisappear_originalMethod = class_getInstanceMethod(self, @selector(viewWillDisappear:));
        Method viewWillDisappear_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewWillDisappear:));
        method_exchangeImplementations(viewWillDisappear_originalMethod, viewWillDisappear_swizzledMethod);
        
        Method viewDidLoad_originalMethod = class_getInstanceMethod(self, @selector(viewDidLoad));
        Method viewDidLoad_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewDidLoad));
        method_exchangeImplementations(viewDidLoad_originalMethod, viewDidLoad_swizzledMethod);
        
        Method viewDidLayout_originalMethod = class_getInstanceMethod(self, @selector(viewDidLayoutSubviews));
        Method viewDidLayout_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewDidLayoutSubviews));
        method_exchangeImplementations(viewDidLayout_originalMethod, viewDidLayout_swizzledMethod);
        
        Method viewDidAppear_originalMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
        Method viewDidAppear_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewDidAppear));
        method_exchangeImplementations(viewDidAppear_originalMethod, viewDidAppear_swizzledMethod);
    });
}

- (void)fd_viewWillAppear:(BOOL)animated
{
    // Forward to primary implementation.
    [self fd_viewWillAppear:animated];

    if (self.fd_willAppearInjectBlock) {
        self.fd_willAppearInjectBlock(self, animated);
    }
}

- (void)fd_viewWillDisappear:(BOOL)animated
{
    // Forward to primary implementation.
    [self fd_viewWillDisappear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *viewController = self.navigationController.viewControllers.lastObject;
        if (viewController && !viewController.wPrefersNavigationBarHidden && viewController.navigationController.wOpen) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    });
}

- (_WViewControllerWillAppearInjectBlock)fd_willAppearInjectBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFd_willAppearInjectBlock:(_WViewControllerWillAppearInjectBlock)block
{
    objc_setAssociatedObject(self, @selector(fd_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)fd_viewDidLoad{
    [self fd_viewDidLoad];
    [self setBackNavigationItem];
}

- (void)fd_viewDidLayoutSubviews {
    [self fd_viewDidLayoutSubviews];
    if (self.wShowCustomNavigationBar) {
        [self.view bringSubviewToFront:self.wCustomNavigationBar];
    }
}

- (void)fd_viewDidAppear{
    [self fd_viewDidAppear];
    if (self.wShowCustomNavigationBar && self.navigationController) {
        [self.wCustomNavigationBar pushNavigationItem:self.navigationItem animated:false];
    }
}

/// 设置导航栏默认返回样式
- (void)setBackNavigationItem{
    /// 设置导航栏默认返回样式
    if (self.navigationController.viewControllers.count > 1 && self.navigationController.topViewController == self && self.navigationController.wBackItem) {
        
        if ([self.navigationController.wBackItem isKindOfClass:[UIImage class]]) {
            UIImage *img = self.navigationController.wBackItem;
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
        }else if ([self.navigationController.wBackItem isKindOfClass:[UIView class]]){
            [self.navigationController.wBackItem addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftBtnAction)]];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navigationController.wBackItem];
        }else if ([self.navigationController.wBackItem isKindOfClass:[NSString class]]) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.navigationController.wBackItem style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
        }
    }
}

#pragma mark - 返回
- (void)leftBtnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

// MARK - UINavigationController
@implementation UINavigationController (WFullscreenPopGesture)

+ (void)load
{
    // Inject "-pushViewController:animated:"
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(pushViewController:animated:);
        SEL swizzledSelector = @selector(wPushViewController:animated:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        //Inject "-setViewControllers:animated:"
        SEL setVCoriginalSelector = @selector(setViewControllers:animated:);
        SEL setVCswizzledSelector = @selector(wSetViewControllers:animated:);
        
        Method setVCoriginalMethod = class_getInstanceMethod(class, setVCoriginalSelector);
        Method setVCswizzledMethod = class_getInstanceMethod(class, setVCswizzledSelector);
        
        BOOL setVCSuccess = class_addMethod(class, setVCoriginalSelector, method_getImplementation(setVCswizzledMethod), method_getTypeEncoding(setVCswizzledMethod));
        if (setVCSuccess) {
            class_replaceMethod(class, setVCswizzledSelector, method_getImplementation(setVCoriginalMethod), method_getTypeEncoding(setVCoriginalMethod));
        } else {
            method_exchangeImplementations(setVCoriginalMethod, setVCswizzledMethod);
        }
    });
}

- (void)wPushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.wFullscreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.wFullscreenPopGestureRecognizer];
        
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.wFullscreenPopGestureRecognizer.delegate = self.wPopGestureRecognizerDelegate;
        [self.wFullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        
        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // Handle perferred navigation bar appearance.
    [self wSetupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    
    // Forward to primary implementation.
    if (![self.viewControllers containsObject:viewController]) {
        [self wPushViewController:viewController animated:animated];
    }
}

- (void)wSetViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
    [self wAddFullscreenPopGestureRecognizer];
    
    // Handle perferred navigation bar appearance.
    for (UIViewController *viewController in viewControllers) {
        [self wSetupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    }
    
    [self wSetViewControllers:viewControllers animated:animated];
}

- (void)wAddFullscreenPopGestureRecognizer
{
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.wFullscreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.wFullscreenPopGestureRecognizer];
        
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.wFullscreenPopGestureRecognizer.delegate = self.wPopGestureRecognizerDelegate;
        [self.wFullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        
        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)wSetupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController
{
    if (!self.wViewControllerBasedNavigationBarAppearanceEnabled) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _WViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && viewController.navigationController.wOpen) {
            [strongSelf setNavigationBarHidden:viewController.wPrefersNavigationBarHidden animated:animated];
        }
    };
    
    // Setup will appear inject block to appearing view controller.
    // Setup disappearing view controller as well, because not every view controller is added into
    // stack by pushing, maybe by "-setViewControllers:".
    appearingViewController.fd_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.fd_willAppearInjectBlock) {
        disappearingViewController.fd_willAppearInjectBlock = block;
    }
}

- (_WFullscreenPopGestureRecognizerDelegate *)wPopGestureRecognizerDelegate
{
    _WFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    
    if (!delegate) {
        delegate = [[_WFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)wFullscreenPopGestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

- (BOOL)wViewControllerBasedNavigationBarAppearanceEnabled
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    self.wViewControllerBasedNavigationBarAppearanceEnabled = YES;
    return YES;
}

- (void)setWViewControllerBasedNavigationBarAppearanceEnabled:(BOOL)enabled {
    SEL key = @selector(wViewControllerBasedNavigationBarAppearanceEnabled);
    objc_setAssociatedObject(self, key, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)wOpen{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setWOpen:(BOOL)wOpen {
    SEL key = @selector(wOpen);
    objc_setAssociatedObject(self, key, @(wOpen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)wBackItem {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWBackItem:(id)wBackItem {
    SEL key = @selector(wBackItem);
    objc_setAssociatedObject(self, key, wBackItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation WNavigationBar

- (void)layoutSubviews{
    [super layoutSubviews];
    UIView *bgView = self.subviews.firstObject;
    CGRect frame = bgView.frame;
    if (frame.size.height == self.frame.size.height) {
        frame.size.height = UIApplication.sharedApplication.statusBarFrame.size.height+self.frame.size.height;
        frame.origin.y = -UIApplication.sharedApplication.statusBarFrame.size.height;
        bgView.frame = frame;
    }
}


@end
