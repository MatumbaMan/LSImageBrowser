//
//  ImageBrowserView.h
//  LSImageBrowser
//
//  Created by HouKinglong on 16/6/9.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSImageBrowserView : UIView

@property (nonatomic,strong) UIScrollView *     scrollview;
@property (nonatomic,strong) UIImageView *      imageview;
@property (nonatomic, assign) CGFloat           progress;
@property (nonatomic, assign) BOOL              beginLoadingImage;

//单击回调
@property (nonatomic, strong) void (^singleTapBlock)(UITapGestureRecognizer *recognizer);

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder path:(NSString *)path;

- (void)rotateLeft;
- (void)rotateRight;
- (void)enlarge;
- (void)narrow;

@end
