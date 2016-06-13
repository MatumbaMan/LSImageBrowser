//
//  ImageBrowserViewController.h
//  LSImageBrowser
//
//  Created by HouKinglong on 16/6/8.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSImageBrowser;

@protocol LSImageBrowserDelegate <NSObject>

@optional
- (NSString *)imageBrowser:(LSImageBrowser *)viewController nameForIndex:(NSInteger)index;
- (NSString *)imageBrowser:(LSImageBrowser *)viewController pathForIndex:(NSInteger)index;
- (NSString *)imageBrowser:(LSImageBrowser *)viewController highQualityImageForIndex:(NSInteger)index;
- (UIImage *)imageBrowser:(LSImageBrowser *)viewController thumbnailImageForIndex:(NSInteger)index;
- (UIImage *)imageBrowser:(LSImageBrowser *)viewController placeImageForIndex:(NSInteger)index;

@end

@interface LSImageBrowser : UIViewController

@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;

@property(nonatomic, assign) id<LSImageBrowserDelegate> delegate;

- (void)showInViewController:(UIViewController *)viewController;

@end
