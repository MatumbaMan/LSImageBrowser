//
//  ImageBrowserViewController.m
//  LSImageBrowser
//
//  Created by HouKinglong on 16/6/8.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import "LSImageBrowser.h"
#import "LSImageBrowserView.h"
#import "LSImageBrowserConfig.h"

#import "LSFullScreenViewController.h"
#import "UINavigationController+AutoRotate.h"

@interface LSImageBrowser () <UIScrollViewDelegate> {
    BOOL _saving;
}

@property (nonatomic, strong) UIScrollView *    mainScrollView;
@property (nonatomic, strong) UILabel *         infoLabel;
@property (nonatomic, strong) UIView *          toolView;
@property (nonatomic, strong) UIScrollView *    previewScrollView;

@property (nonatomic,assign) BOOL hasShowImageBrowser;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, copy)   NSString *        albumName;
@property (nonatomic, strong) NSMutableArray *  savePhotoList;

@end

@implementation LSImageBrowser

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
    [self initNavigationBar];
}

#pragma mark navigationbar style
- (void)initNavigationBar {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"查看图片";
    
    [self.navigationController.navigationBar setBarTintColor:kNavigationTintColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:18], NSFontAttributeName, nil]];

    // 3.关闭按钮
    UIButton *hideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
    [hideButton setTitle:@"返回" forState:UIControlStateNormal];
    [hideButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [hideButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    hideButton.clipsToBounds = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:hideButton];
    
    
    // 2.保存按钮
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    saveButton.clipsToBounds = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveButton];
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 保存图像
- (void)saveImage {
    
    if (_saving) {
        return;
    }
    _saving = YES;
    
    int index = self.mainScrollView.contentOffset.x / self.mainScrollView.bounds.size.width;
    
    LSImageBrowserView *currentView = self.mainScrollView.subviews[index];
    
    if ([self.savePhotoList containsObject:currentView.imageview.image]) {
        return;
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.view.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

//show action
- (void)showInViewController:(UIViewController *)viewController {
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:self];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:nav animated:YES completion:nil];
}

#pragma mark addSubviews
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kImageBrowserBackgrounColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.currentImageIndex = MIN(self.currentImageIndex, self.imageCount - 1);
    [self addSubView];
}

- (void)resizeViewForOrientation:(UIInterfaceOrientation)orientation {

    BOOL isPortrait = (orientation == UIDeviceOrientationPortrait);
    
    CGFloat viewHeight = self.view.bounds.size.height;
    
    CGFloat mainBackgroundHeight = isPortrait ? viewHeight - kPreviewHeight - kToolviewHeight : viewHeight - kToolviewHeight;
    CGFloat mainBackgroundWidth = isPortrait ? kAppScreenWidth : kAppScreenWidth - kPreviewWidth;
    
    CGFloat mainHeight = mainBackgroundHeight - kImageBrowserMarginVertical(isPortrait) * 2 - kInfoLableHeight;
    CGFloat mainWidth = mainBackgroundWidth - kImageBrowserMarginHorizontal(isPortrait) * 2 ;
    
    CGFloat previewX = isPortrait ? 0 : mainBackgroundWidth;
    CGFloat previewY = isPortrait ? mainBackgroundHeight + kToolviewHeight : 0;
    CGFloat previewWidth = isPortrait ? kAppScreenWidth : kPreviewWidth;
    CGFloat previewHeight = isPortrait ? kPreviewHeight : mainBackgroundHeight;
    
    CGFloat mainCenterY = mainBackgroundHeight * 0.5 - 15;
    
    self.mainScrollView.frame = CGRectMake(0, 0, mainWidth, mainHeight);
    self.mainScrollView.center = CGPointMake(mainBackgroundWidth * 0.5, mainCenterY);
    self.mainScrollView.contentSize = CGSizeMake(self.imageCount * mainWidth, mainHeight);
    self.mainScrollView.contentOffset = CGPointMake(self.currentImageIndex * self.mainScrollView.frame.size.width, 0);
    [self.mainScrollView.subviews enumerateObjectsUsingBlock:^(LSImageBrowserView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = kImageBrowserImageViewMargin + idx * mainWidth;
        obj.frame = CGRectMake(x, 0, mainWidth - kImageBrowserImageViewMargin * 2, mainHeight);
    }];
    
    self.infoLabel.frame = CGRectMake((mainBackgroundWidth - mainWidth) * 0.5, mainCenterY + mainHeight * 0.5, mainWidth, kInfoLableHeight);
    
    self.toolView.frame = CGRectMake(0, mainBackgroundHeight, kAppScreenWidth, kToolviewHeight);
    [self.toolView.subviews enumerateObjectsUsingBlock:^(UIView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.center = CGPointMake(kAppScreenWidth * 0.5, kToolviewHeight * 0.5);
    }];
    
    self.previewScrollView.frame = CGRectMake(previewX, previewY, previewWidth, previewHeight);
    self.previewScrollView.contentSize = isPortrait ? CGSizeMake(self.imageCount * kPreviewWidth + kPreviewImageViewMarginHorizontal, kPreviewHeight) :CGSizeMake(kPreviewWidth, self.imageCount * kPreviewHeight + kPreviewImageViewMarginVertical);
    [self.previewScrollView.subviews enumerateObjectsUsingBlock:^(UIImageView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (isPortrait) {
            CGFloat x = kPreviewImageViewMarginVertical + idx * kPreviewWidth;
            obj.frame = CGRectMake(x, kPreviewImageViewMarginVertical, kPreviewWidth - kPreviewImageViewMarginHorizontal, kPreviewHeight - kPreviewImageViewMarginVertical * 2);
        } else {
            CGFloat y = kPreviewImageViewMarginVertical + idx * kPreviewHeight;
            obj.frame = CGRectMake(kPreviewImageViewMarginHorizontal, y, kPreviewWidth - kPreviewImageViewMarginHorizontal * 2, kPreviewHeight - kPreviewImageViewMarginVertical);
        }
        
    }];
    [self changePreviewOffset];
}

- (void)addSubView {
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.infoLabel];
    [self.view addSubview:self.toolView];
    [self.view addSubview:self.previewScrollView];
    
    self.mainScrollView.layer.borderColor = [UIColor greenColor].CGColor;
    self.mainScrollView.layer.borderWidth = 2.0f;
    self.mainScrollView.backgroundColor = [UIColor blackColor];

    self.infoLabel.backgroundColor = [UIColor lightGrayColor];
    
//    self.previewScrollView.layer.borderColor = [UIColor blueColor].CGColor;
//    self.previewScrollView.layer.borderWidth = 2.0f;
    self.previewScrollView.backgroundColor = [UIColor colorWithRed:73/255.0 green:81/255.0 blue:91/255.0 alpha:1.0f];
    
    self.toolView.backgroundColor = [UIColor colorWithRed:73/255.0 green:81/255.0 blue:91/255.0 alpha:1.0f];
}

- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _mainScrollView.delegate = self;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.hidden = NO;
        
        for (int i = 0; i < self.imageCount; i++) {
            LSImageBrowserView * view = [[LSImageBrowserView alloc]init];
            view.tag = i;
            
            //处理单击
            __weak __typeof(self)weakSelf = self;
            view.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf fullScreenShow:recognizer];
            };
            
            [_mainScrollView addSubview:view];
        }
        [self setupImageOfImageViewForIndex:self.currentImageIndex];
        [self setIndex:self.currentImageIndex];
        [self.infoLabel setText:[self nameAtIndex:self.currentImageIndex]];
    }
    return _mainScrollView;
}

- (UIView *)toolView {
    if (!_toolView) {
        _toolView = [[UIView alloc]init];
        
        UIView * container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kToolviewHeight * 4 + kToolviewMargin * 3, kToolviewHeight)];
        [_toolView addSubview:container];
        
        UIButton * rotateLeft = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kToolviewHeight, kToolviewHeight)];
        [rotateLeft setBackgroundImage:[UIImage imageNamed:@"rotate-left"] forState:UIControlStateNormal];
        [rotateLeft addTarget:self action:@selector(rotateLeft) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:rotateLeft];
        
        UIButton * rotateRight = [[UIButton alloc]initWithFrame:CGRectMake(kToolviewHeight + kToolviewMargin, 0, kToolviewHeight, kToolviewHeight)];
        [rotateRight setBackgroundImage:[UIImage imageNamed:@"rotate-right"] forState:UIControlStateNormal];
        [rotateRight addTarget:self action:@selector(rotateRight) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:rotateRight];

        UIButton * enlarge = [[UIButton alloc]initWithFrame:CGRectMake((kToolviewHeight + kToolviewMargin) * 2, 0, kToolviewHeight, kToolviewHeight)];
        [enlarge setBackgroundImage:[UIImage imageNamed:@"enlarge"] forState:UIControlStateNormal];
        [enlarge addTarget:self action:@selector(enlarge) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:enlarge];
        
        UIButton * narrow = [[UIButton alloc]initWithFrame:CGRectMake((kToolviewHeight + kToolviewMargin) * 3, 0, kToolviewHeight, kToolviewHeight)];
        [narrow setBackgroundImage:[UIImage imageNamed:@"narrow"] forState:UIControlStateNormal];
        [narrow addTarget:self action:@selector(narrow) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:narrow];
        
        UILabel * line = [[UILabel alloc]initWithFrame:CGRectMake(0, kToolviewHeight - 2, (kToolviewHeight + kToolviewMargin) * 4, 2)];
        line.backgroundColor = [UIColor colorWithRed:80/255.0 green:87/255.0 blue:96/255.0 alpha:1.0f];;
        [container addSubview:line];
    }
    return _toolView;
}

- (UIScrollView *)previewScrollView {
    if (!_previewScrollView) {
        _previewScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _previewScrollView.delegate = self;
        _previewScrollView.clipsToBounds = YES;
        _previewScrollView.userInteractionEnabled = YES;
        _previewScrollView.bounces = NO;
        
        for (int i = 0; i < self.imageCount; i++) {
            UIImageView * imageView = [[UIImageView alloc]init];
            imageView.image = [self thumbnailAtIndex:i];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            imageView.layer.borderWidth = 2.f;
            [_previewScrollView addSubview:imageView];
            
            UILabel * index = [[UILabel alloc]initWithFrame:CGRectMake(2, 2, 15, 12)];
            index.numberOfLines = 1;
            index.text = [NSString stringWithFormat:@"%zi", i + 1];
            index.layer.backgroundColor = [UIColor blackColor].CGColor;
            index.layer.cornerRadius = 6;
            index.textColor = [UIColor whiteColor];
            index.font = [UIFont systemFontOfSize:9];
            index.textAlignment = NSTextAlignmentCenter;
            [imageView addSubview:index];
            
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewTap:)];
            [imageView addGestureRecognizer:tap];
        }
        
        [self setupIndexOfPreviewViewForIndex:self.currentImageIndex];
    }
    return _previewScrollView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc]init];
        _infoLabel.numberOfLines = 1;
        _infoLabel.textColor = [UIColor grayColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _infoLabel;
}

#pragma mark 重置各控件frame（处理屏幕旋转）
- (void)setIndex:(NSInteger)index {
    self.currentImageIndex = index;
    self.infoLabel.text = [self nameAtIndex:index];
//    [self.navigationItem setTitle:[NSString stringWithFormat:@"查看图片(%zi/%zi)", index + 1, self.imageCount]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self resizeViewForOrientation:[self getCurrentOrientation]];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

#pragma mark 屏幕旋转
- (BOOL)shouldAutorotate {
    return kIsSupportLandscape;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (kIsSupportLandscape) {
        return UIInterfaceOrientationMaskAll;
    } else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation)getCurrentOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

#pragma self delegate
- (void)setupImageOfImageViewForIndex:(NSInteger)index {
    LSImageBrowserView * view = self.mainScrollView.subviews[index];
    if (view.beginLoadingImage) return;
    if ([self highQualityImageURLAtIndex:index]) {
        [view setImageWithURL:[self highQualityImageURLAtIndex:index] placeholderImage:[self placeholderImageAtIndex:index] path:[self pathAtIndex:index]];
    } else {
        view.imageview.image = [self placeholderImageAtIndex:index];
    }
    view.beginLoadingImage = YES;
}

- (void)setupIndexOfPreviewViewForIndex:(NSInteger)index {
    UIImageView * view = self.previewScrollView.subviews[index];
    if (index == self.currentImageIndex) {
        view.layer.borderColor = [UIColor blueColor].CGColor;
    } else {
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

- (NSString *)pathAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(imageBrowser:pathForIndex:)]) {
        return [self.delegate imageBrowser:self pathForIndex:index];
    }
    return nil;
}

- (NSString *)highQualityImageURLAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(imageBrowser:highQualityImageForIndex:)]) {
        return [self.delegate imageBrowser:self highQualityImageForIndex:index];
    }
    return nil;
}

- (UIImage *)placeholderImageAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(imageBrowser:placeImageForIndex:)]) {
        return [self.delegate imageBrowser:self placeImageForIndex:index];
    }
    return nil;
}

- (UIImage *)thumbnailAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(imageBrowser:thumbnailImageForIndex:)]) {
        return [self.delegate imageBrowser:self thumbnailImageForIndex:index];
    }
    return nil;
}

- (NSString *)nameAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(imageBrowser:nameForIndex:)]) {
        return [self.delegate imageBrowser:self nameForIndex:index];
    }
    return nil;
}

#pragma mark button method
- (void)rotateLeft {
    //左转
    LSImageBrowserView * view = self.mainScrollView.subviews[self.currentImageIndex];
    [view rotateLeft];
}

- (void)rotateRight {
    //右转
    LSImageBrowserView * view = self.mainScrollView.subviews[self.currentImageIndex];
    [view rotateRight];
}

- (void)enlarge {
    //放大
    LSImageBrowserView * view = self.mainScrollView.subviews[self.currentImageIndex];
    [view enlarge];
}

- (void)narrow {
    //缩小
    LSImageBrowserView * view = self.mainScrollView.subviews[self.currentImageIndex];
    [view narrow];
}

- (void)fullScreenShow:(UITapGestureRecognizer *)recognizer {
    LSFullScreenViewController * fullscreen = [LSFullScreenViewController new];

    fullscreen.sourceView = self.mainScrollView;
    NSString * imagePath = [self highQualityImageURLAtIndex:self.currentImageIndex];
    if (imagePath) {
        if ([[NSFileManager defaultManager]fileExistsAtPath:imagePath]) {
            fullscreen.image = [UIImage imageWithContentsOfFile:imagePath];
        } else {
            fullscreen.image = [self placeholderImageAtIndex:self.currentImageIndex];
        }
    } else {
        fullscreen.image = [self placeholderImageAtIndex:self.currentImageIndex];
    }

    [self presentViewController:fullscreen animated:NO completion:nil];
}

#pragma mark scrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.mainScrollView]) {
        int index = self.mainScrollView.contentOffset.x  / self.mainScrollView.bounds.size.width;
        
        long left = index - 2;
        long right = index + 2;
        left = left > 0 ? left : 0;
        right = right > self.imageCount ? self.imageCount:right;
        
        //预加载三张图片
        for (long i = left; i < right; i++) {
            [self setupImageOfImageViewForIndex:i];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.mainScrollView]) {
        int autualIndex = self.mainScrollView.contentOffset.x  / self.mainScrollView.bounds.size.width;
        
        [self setIndex:autualIndex];
        [self changePreviewOffset];
        
        //将不是当前imageview的缩放全部还原 (这个方法有些冗余，后期可以改进)
        for (LSImageBrowserView *view in self.mainScrollView.subviews) {
            if (view.imageview.tag != autualIndex) {
                view.scrollview.zoomScale = 1.0;
            }
            view.transform = CGAffineTransformMakeRotation(0);
        }
        
        [self changePreviewSelect];
    }
}

- (void)changePreviewOffset {
    
    if (UIInterfaceOrientationPortrait == [self getCurrentOrientation]) {
        CGFloat maxWidth = self.previewScrollView.contentSize.width;
        CGFloat width = maxWidth / self.imageCount;
        CGFloat offset = (self.currentImageIndex - 1) * width;

        while (maxWidth - offset < self.previewScrollView.frame.size.width) {
            offset = maxWidth - self.previewScrollView.frame.size.width;
        }
        
        [self.previewScrollView setContentOffset:CGPointMake(MAX(offset, 0), 0) animated:YES];
        
    } else {
        CGFloat maxHeight = self.previewScrollView.contentSize.height;
        CGFloat height = maxHeight / self.imageCount;
        CGFloat offset = (self.currentImageIndex - 1) * height;
        
        while (maxHeight - offset < self.previewScrollView.frame.size.height) {
            offset = maxHeight - self.previewScrollView.frame.size.height;
        }
        
        [self.previewScrollView setContentOffset:CGPointMake(0, MAX(offset, 0)) animated:YES];
    }
    [self changePreviewSelect];
}

- (void)previewTap:(UITapGestureRecognizer *)tap {
    [self setIndex:tap.view.tag];
    [self changePreviewOffset];
    
    [self.mainScrollView setContentOffset:CGPointMake(self.currentImageIndex * self.mainScrollView.frame.size.width, 0) animated:YES];
    
    [self changePreviewSelect];
}

- (void)changePreviewSelect {
    for (UIImageView * view in self.previewScrollView.subviews) {
        if (view.tag != self.currentImageIndex) {
            view.layer.borderColor = [UIColor whiteColor].CGColor;
        } else {
            view.layer.borderColor = kNavigationTintColor.CGColor;
        }
    }
}

@end
