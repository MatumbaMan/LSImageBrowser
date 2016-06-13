//
//  ImageBrowserView.m
//  LSImageBrowser
//
//  Created by HouKinglong on 16/6/9.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import "LSImageBrowserView.h"
#import "ImageBrowserConfig.h"
#import "LSImageIndicatorView.h"

@interface LSImageBrowserView () <UIScrollViewDelegate>

@property (nonatomic, weak) LSImageIndicatorView  *indicatorView;
@property (nonatomic, assign) BOOL hasLoadedImage;//图片下载成功为YES 否则为NO

@end

@implementation LSImageBrowserView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollview];
    }
    return self;
}

- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.frame = self.frame;
        _scrollview.delegate = self;
        _scrollview.clipsToBounds = YES;
        _scrollview.userInteractionEnabled = YES;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.showsVerticalScrollIndicator = NO;
        [_scrollview addSubview:self.imageview];
    }
    return _scrollview;
}

- (UIImageView *)imageview
{
    if (!_imageview) {
        _imageview = [[UIImageView alloc] init];
        _imageview.frame = self.frame;
        _imageview.userInteractionEnabled = YES;
        _imageview.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageview;
}

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder path:(NSString *)path {
    
    //添加进度指示器
    LSImageIndicatorView  *indicatorView = [[LSImageIndicatorView alloc] init];
    indicatorView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    [self addSubview:self.indicatorView = indicatorView];
    
    
    self.imageview.image = placeholder;
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        self.hasLoadedImage = YES;
        [self.indicatorView removeFromSuperview];
        [self.imageview setImage:[UIImage imageWithContentsOfFile:path]];
        return;
    }
    
    self.hasLoadedImage = YES;
    //下载
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicatorView.center = self.scrollview.center;
    self.scrollview.frame = self.bounds;
    [self adjustFrames];
}

- (void)adjustFrames
{
    CGRect frame = self.scrollview.frame;
    
    if (self.imageview.image) {
        CGSize imageSize = self.imageview.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);

        if (frame.size.width<=frame.size.height) {
            
            CGFloat ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        }else{
            CGFloat ratio = frame.size.height/imageFrame.size.height;
            imageFrame.size.width = imageFrame.size.width*ratio;
            imageFrame.size.height = frame.size.height;
        }

        
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

#pragma mark 双击
- (void)rotateLeft {
    //图片加载完之后才能响应双击放大
    if (!self.hasLoadedImage) {
        return;
    }
    
    //左转
    CGAffineTransform currentTransform = self.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, -90 * M_PI / 180.0); // 在现在的基础上旋转指定角度
    self.transform = newTransform;
    
}

- (void)rotateRight {
    //图片加载完之后才能响应双击放大
    if (!self.hasLoadedImage) {
        return;
    }
    
    //右转
    CGAffineTransform currentTransform = self.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, 90 * M_PI / 180.0); // 在现在的基础上旋转指定角度
    self.transform = newTransform;
}

- (void)enlarge
{
    //图片加载完之后才能响应双击放大
    if (!self.hasLoadedImage) {
        return;
    }
    
    [self.scrollview setZoomScale:self.scrollview.zoomScale * 2 animated:YES];
}

- (void)narrow {
    //图片加载完之后才能响应双击放大
    if (!self.hasLoadedImage) {
        return;
    }
    
    [self.scrollview setZoomScale:self.scrollview.zoomScale * 0.5 animated:YES];
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
