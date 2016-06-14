//
//  LSFullScreenViewController.m
//  LSImageBrowser
//
//  Created by HouKinglong on 16/6/14.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import "LSFullScreenViewController2.h"
#import "LSImageBrowserConfig.h"

@interface LSFullScreenViewController2 () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * scrollview;
@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation LSFullScreenViewController2


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
    [self addGestureRecognizerToView:self.imageView];
    //    [self setupFrame];
    [self adjustFrames];
}

- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.delegate = self;
        _scrollview.clipsToBounds = YES;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.backgroundColor = [UIColor orangeColor];
        [_scrollview setUserInteractionEnabled:YES];
        [_scrollview setMultipleTouchEnabled:YES];
        [_scrollview addSubview:self.imageview];
    }
    return _scrollview;
}

- (UIImageView *)imageview
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = self.image;
        //        _imageView.userInteractionEnabled = YES;
        [_imageView setUserInteractionEnabled:YES];
        [_imageView setMultipleTouchEnabled:YES];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void)layoutSubviews {
    _scrollview.frame = self.view.bounds;
    [self adjustFrames];
}

- (void)adjustFrames
{
    _scrollview.frame = self.view.bounds;
    CGRect frame = self.scrollview.frame;
    if (self.imageview.image) {
        CGSize imageSize = self.imageview.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        //        if (kIsFullWidthForLandScape) {
        CGFloat ratio = frame.size.width/imageFrame.size.width;
        imageFrame.size.height = imageFrame.size.height*ratio;
        imageFrame.size.width = frame.size.width;
        //        } else{
        //            if (frame.size.width<=frame.size.height) {
        //
        //                CGFloat ratio = frame.size.width/imageFrame.size.width;
        //                imageFrame.size.height = imageFrame.size.height*ratio;
        //                imageFrame.size.width = frame.size.width;
        //            }else{
        //                CGFloat ratio = frame.size.height/imageFrame.size.height;
        //                imageFrame.size.width = imageFrame.size.width*ratio;
        //                imageFrame.size.height = frame.size.height;
        //            }
        //        }
        
        self.imageview.frame = imageFrame;
        self.scrollview.contentSize = self.imageview.frame.size;
        self.imageview.center = [self centerOfScrollViewContent:self.scrollview];
        
        
        CGFloat maxScale = frame.size.height/imageFrame.size.height;
        maxScale = frame.size.width/imageFrame.size.width>maxScale?frame.size.width/imageFrame.size.width:maxScale;
        maxScale = maxScale>kMaxZoomScale?maxScale:kMaxZoomScale;
        
        self.scrollview.minimumZoomScale = kMinZoomScale;
        self.scrollview.maximumZoomScale = maxScale;
        self.scrollview.zoomScale = 1.0f;
    }else{
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


// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePicture)];
    [view addGestureRecognizer:tap];
    
    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
}

- (void)setupFrame {
    CGRect frame = self.view.frame;
    CGSize imageSize = self.imageView.image.size;
    CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    CGFloat ratio = frame.size.width/imageFrame.size.width;
    imageFrame.size.height = imageFrame.size.height*ratio;
    imageFrame.size.width = frame.size.width;
    
    self.imageView.frame = imageFrame;
    self.imageView.center = self.view.center;
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
        int rotate = (int)((degree + 45) / 90) * 90;
        view.transform = CGAffineTransformMakeRotation(rotate * M_PI / 180.0);
    }
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}
@end
