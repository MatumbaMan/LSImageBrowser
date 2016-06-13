//
//  UINavigationController+AutoRotate.m
//  LSImageBrowser
//
//  Created by HouKinglong on 16/6/8.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import "UINavigationController+AutoRotate.h"

@implementation UINavigationController (AutoRotate)

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
