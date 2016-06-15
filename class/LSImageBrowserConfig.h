//
//  ImageBrowserConfig.h
//  LSImageBrowser
//
//  Created by HouKinglong on 16/6/8.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#ifndef LSImageBrowserConfig_h
#define LSImageBrowserConfig_h

#define kNavigationTintColor        [UIColor colorWithRed:0.369  green:0.596  blue:0.890 alpha:1]
#define kImageBrowserBackgrounColor [UIColor colorWithRed:1 green:1 blue:1 alpha:1]

#define kAppScreenWidth     [UIScreen mainScreen].bounds.size.width
#define kAppScreenHeight    [UIScreen mainScreen].bounds.size.height

#define kImageBrowserMarginVertical(isPortrait)     (isPortrait ? 60 : 5)
#define kImageBrowserMarginHorizontal(isPortrait)     (isPortrait ? 20 : 60)

#define kImageBrowserImageViewMargin    10

#define kPreviewImageViewMarginVertical    5
#define kPreviewImageViewMarginHorizontal    5

#define kPreviewWidth       100
#define kPreviewHeight      75

#define kToolviewHeight     50
#define kToolviewMargin     10

#define kInfoLableHeight    30

//是否支持横屏
#define kIsSupportLandscape YES

//图片缩放比例
#define kMinZoomScale 0.5f
#define kMaxZoomScale 3.0f

#endif /* ImageBrowserConfig_h */
