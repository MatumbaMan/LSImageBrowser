//
//  LSFullScreenViewController.m
//  LSImageBrowser
//
//  Created by HouKinglong on 16/6/14.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import "LSFullScreenViewController.h"
#import "LSImageBrowserConfig.h"

@interface LSFullScreenViewController () <UIScrollViewDelegate> {
    BOOL _orientationChanged;
}

@property (nonatomic, strong) UIScrollView * scrollview;
@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation LSFullScreenViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showPicture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollview];
    [self adjustFrames];
}

- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.frame = self.view.frame;
        _scrollview.delegate = self;
        _scrollview.clipsToBounds = YES;
        _scrollview.backgroundColor = [UIColor blackColor];
        [_scrollview setUserInteractionEnabled:YES];
        [_scrollview setMultipleTouchEnabled:YES];
        [_scrollview addSubview:self.imageview];
        
//        _scrollview.layer.borderColor = [UIColor greenColor].CGColor;
//        _scrollview.layer.borderWidth = 2.0f;
        
        // 旋转手势
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
        [_scrollview addGestureRecognizer:rotationGestureRecognizer];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePicture)];
        [_scrollview addGestureRecognizer:tap];
    }
    return _scrollview;
}

- (UIImageView *)imageview
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = self.image;
        [_imageView setUserInteractionEnabled:YES];
        [_imageView setMultipleTouchEnabled:YES];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
//        _imageView.layer.borderColor = [UIColor blueColor].CGColor;
//        _imageView.layer.borderWidth = 2.0f;
    }
    return _imageView;
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
    
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat radius = atan2f(view.transform.b, view.transform.a);
        CGFloat degree = radius * (180 / M_PI);
        int rotate = [self handleRotate:degree];
        view.transform = CGAffineTransformMakeRotation(rotate * M_PI / 180.0);
        [self adjustFrames];
    }
}

- (int)handleRotate:(CGFloat)degree {
    if (degree + 45 < 0) {
        return -((abs((int)degree) + 45) / 90) * 90;
    } else {
        return (int)((degree + 45) / 90) * 90;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _orientationChanged = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (_orientationChanged) {
        _orientationChanged = NO;
        [self adjustFrames];
    }
}

- (CGRect)tranferFrame:(CGRect)target source:(CGRect)source rotate:(BOOL)rotate{
    CGFloat ratio = 1;
    if (target.size.height > source.size.height) {
        ratio = source.size.height / target.size.height;
        
        if (rotate) {
            target.size.width = target.size.height*ratio;
            target.size.height = target.size.width*ratio;
        } else {
            target.size.height = target.size.height*ratio;
            target.size.width = target.size.width*ratio;
        }
    }
    
    if (target.size.width > source.size.width) {
        ratio = source.size.width / target.size.width;
        
        if (rotate) {
            target.size.width = target.size.height*ratio;
            target.size.height = target.size.width*ratio;
        } else {
            target.size.height = target.size.height*ratio;
            target.size.width = target.size.width*ratio;
        }
    }
    return target;
}

- (void)adjustFrames
{
    self.scrollview.frame = self.view.bounds;
    self.scrollview.zoomScale = 1.0f;
    
    CGRect frame = self.view.frame;
    if (self.image) {
        CGSize imageSize = self.imageview.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        CGFloat radius = atan2f(self.scrollview.transform.b, self.scrollview.transform.a);
        CGFloat degree = radius * (180 / M_PI);
        BOOL rotate = ((abs((int)degree) + 1) / 90) % 2 != 0;
        
        if (frame.size.width <= frame.size.height) {
            
            if (rotate) {
                CGFloat ratio = frame.size.width/imageFrame.size.height;
                imageFrame.size.height = frame.size.width;
                imageFrame.size.width = imageFrame.size.width*ratio;
            } else {
                CGFloat ratio = frame.size.width/imageFrame.size.width;
                imageFrame.size.height = imageFrame.size.height*ratio;
                imageFrame.size.width = frame.size.width;
            }
            
        } else {
            
            
            if (rotate) {
                CGFloat ratio = frame.size.width/imageFrame.size.width;
                imageFrame.size.height = frame.size.height*ratio;
                imageFrame.size.width = imageFrame.size.height;
            } else {
                CGFloat ratio = frame.size.height/imageFrame.size.height;
                imageFrame.size.width = imageFrame.size.width*ratio;
                imageFrame.size.height = frame.size.height;
            }
        }

        NSLog(@"%f-%f", imageFrame.size.width, imageFrame.size.height);

        self.imageview.frame = imageFrame;
        self.scrollview.contentSize = imageFrame.size;
        
        CGPoint center = [self centerOfScrollViewContent:self.scrollview];
        self.imageview.center = center;
        
        CGFloat maxScale = frame.size.height/imageFrame.size.height;
        maxScale = frame.size.width/imageFrame.size.width>maxScale?frame.size.width/imageFrame.size.width:maxScale;
        maxScale = maxScale>kMaxZoomScale?maxScale:kMaxZoomScale;
        
        self.scrollview.minimumZoomScale = kMinZoomScale;
        self.scrollview.maximumZoomScale = maxScale;
    } else {
        frame.origin = CGPointZero;
        self.imageview.frame = frame;
        self.scrollview.contentSize = self.imageview.frame.size;
    }
    self.scrollview.contentOffset = CGPointZero;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPicture {
    CGRect rect = self.sourceView.frame;
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.frame = CGRectMake(rect.origin.x, rect.origin.y + 64, rect.size.width, rect.size.height);
    tempImageView.image = self.image;
    [self.view addSubview:tempImageView];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat placeImageSizeW = tempImageView.image.size.width;
    CGFloat placeImageSizeH = tempImageView.image.size.height;
    CGRect targetTemp;
    
    CGFloat placeHolderH = (placeImageSizeH * kAppScreenWidth)/placeImageSizeW;
    if (placeHolderH <= kAppScreenHeight) {
        targetTemp = CGRectMake(0, (kAppScreenHeight - placeHolderH) * 0.5 , kAppScreenWidth, placeHolderH);
    } else {
        targetTemp = CGRectMake(0, 0, kAppScreenWidth, placeHolderH);
    }
    
    [self.imageView setHidden:YES];
    
    [UIView animateWithDuration:0.5f animations:^{
        tempImageView.bounds = targetTemp;
        tempImageView.center = self.view.center;
    } completion:^(BOOL finished) {
        [tempImageView removeFromSuperview];
        [self.imageView setHidden:NO];
    }];
}
#pragma mark 单击隐藏图片浏览器
- (void)hidePicture
{
    CGRect rect = self.sourceView.frame;
    CGRect targetTemp = CGRectMake(rect.origin.x, rect.origin.y + 64, rect.size.width, rect.size.height);
    
    CGFloat appWidth = self.sourceView.frame.size.width;
    CGFloat appHeight = self.sourceView.frame.size.height;
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.image = self.imageView.image;
    if (tempImageView.image) {
        tempImageView.frame = CGRectMake(rect.origin.x, rect.origin.y + 64, rect.size.width, rect.size.height);
        targetTemp = CGRectMake(rect.origin.x, rect.origin.y + 64, rect.size.width, (tempImageView.image.size.height * rect.size.width)/tempImageView.image.size.width);
    } else {
        tempImageView.backgroundColor = [UIColor whiteColor];
        tempImageView.frame = CGRectMake(0, (appHeight - appWidth)*0.5, appWidth, appWidth);
    }
    
    targetTemp = CGRectMake(self.sourceView.center.x - targetTemp.size.width * 0.5, self.sourceView.center.y - targetTemp.size.height * 0.5 + 64, targetTemp.size.width, targetTemp.size.height);
    
    [self.view.window addSubview:tempImageView];
    
    if (UIInterfaceOrientationPortrait != [UIApplication sharedApplication].statusBarOrientation) {
        //强制竖屏
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }

    [self.imageView setHidden:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [UIView animateWithDuration:0.5f animations:^{
        tempImageView.frame = targetTemp;
    } completion:^(BOOL finished) {
        [tempImageView removeFromSuperview];
    }];
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageview.center = [self centerOfScrollViewContent:scrollView];
}

@end
