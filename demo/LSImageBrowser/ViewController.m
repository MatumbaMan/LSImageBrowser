//
//  ViewController.m
//  LSImageBrowser
//
//  Created by HouKinglong on 16/4/19.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import "ViewController.h"
#import "LSImageBrowser.h"

@interface ViewController () <LSImageBrowserDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"浏览" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    saveButton.layer.borderWidth = 0.1;
    saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    saveButton.layer.cornerRadius = 2;
    saveButton.clipsToBounds = YES;
    saveButton.frame = CGRectMake(100, 100, 200, 30);
    [saveButton addTarget:self action:@selector(browser) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
}

- (void)browser {
    LSImageBrowser * ib = [LSImageBrowser new];
    [ib setDelegate:self];
    [ib setImageCount:10];
    [ib setCurrentImageIndex:10];
    [ib showInViewController:self];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (NSString *)imageBrowser:(LSImageBrowser *)viewController highQualityImageForIndex:(NSInteger)index {
    return @"aaa";
}

- (UIImage *)imageBrowser:(LSImageBrowser *)viewController thumbnailImageForIndex:(NSInteger)index {
    return [UIImage imageNamed:@"test"];
}

- (UIImage *)imageBrowser:(LSImageBrowser *)viewController placeImageForIndex:(NSInteger)index {
    return [UIImage imageNamed:@"test"];
}

- (NSString *)imageBrowser:(LSImageBrowser *)viewController nameForIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"林小雨_右眼_0%zi", index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
