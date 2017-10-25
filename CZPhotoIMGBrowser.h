//
//  CZPhotoIMGBrowser.h
//  CZ
//
//  Created by 程健 on 2015/10/10.
//  Copyright © 2015年 程健. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CZPhotoIMGPhotos_Key_Photo      @"photo"
#define CZPhotoIMGPhotos_Key_Title      @"title"
#define CZPhotoIMGPhotos_Key_SubTitle   @"subtitle"

#define CZPhotoIMGThumbs_Key_Image      @"image"
#define CZPhotoIMGThumbs_Key_Frame      @"frame"


@class CZPhotoIMGBrowser;
@protocol CZPhotoIMGBrowserDelegate <NSObject>
@optional
// 切换到某一页图片
- (void)photoBrowser:(CZPhotoIMGBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
@end

@interface CZPhotoIMGBrowser : UIViewController
@property(nonatomic,weak)id<CZPhotoIMGBrowserDelegate>delegate;

/**
 启动图片浏览器
 
 @param photos 将要显示的图片信息集合(NSDictionary元素)
 例如: 
 {
    photo: (网络URL 或 ImageView.image 或 本地Image),
    title: @"主标题",
    subtitle: @"副标题(一般表示图片详情介绍)"
 }
 @param thumbs 缩略图集合 (ImageView.image 或 本地Image)
 @param index  当前浏览的图片所处下标索引
 */
+ (instancetype)showPhotos:(NSArray *)photos
                    thumbs:(NSArray *)thumbs
                   atIndex:(NSInteger)index;


- (instancetype)initWithPhotos:(NSArray *)photos thumbs:(NSArray *)thumbs atIndex:(NSInteger)index;
@end



