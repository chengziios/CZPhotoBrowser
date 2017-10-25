//
//  CZPhotoIMGBrowser.m
//  CZ
//
//  Created by 程健 on 2015/10/10.
//  Copyright © 2015年 程健. All rights reserved.
//

#import "CZPhotoIMGBrowser.h"
#import "CZProgressHUD.h"
#import <YYKit.h>


#pragma mark - 扩展一个loadingView
static NSString *kYSStrokeAnimationKey = @"mmmaterialdesignspinner.stroke";
static NSString *kYSRotationAnimationKey = @"mmmaterialdesignspinner.rotation";
@interface CZPhotoIMGLoadingView : UIView
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL hidesWhenStopped;
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic) BOOL isAnimating;
@property(nonatomic) float progress;
@property (nonatomic, strong) UILabel *progressLabel;
- (void)setAnimating:(BOOL)animate;
- (void)startAnimating;
- (void)stopAnimating;
@end

@implementation CZPhotoIMGLoadingView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addSublayer:self.progressLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    _progressLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _progressLabel.layer.masksToBounds = YES;
    _progressLabel.layer.cornerRadius = self.bounds.size.width/2;
    _progressLabel.font = [UIFont systemFontOfSize:14];
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_progressLabel];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self updatePath];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
}

- (void)resetAnimations
{
    if (self.isAnimating) {
        [self stopAnimating];
        [self startAnimating];
    }
}

- (void)setAnimating:(BOOL)animate {
    (animate ? [self startAnimating] : [self stopAnimating]);
}

- (void)startAnimating {
    if (self.isAnimating)
        return;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 4.f;
    animation.fromValue = @(0.f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animation forKey:kYSRotationAnimationKey];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = 1.f;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(0.25f);
    headAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = 1.f;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.f);
    tailAnimation.timingFunction = self.timingFunction;
    
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = 1.f;
    endHeadAnimation.duration = 0.5f;
    endHeadAnimation.fromValue = @(0.25f);
    endHeadAnimation.toValue = @(1.f);
    endHeadAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = 1.f;
    endTailAnimation.duration = 0.5f;
    endTailAnimation.fromValue = @(1.f);
    endTailAnimation.toValue = @(1.f);
    endTailAnimation.timingFunction = self.timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:1.5f];
    [animations setAnimations:@[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animations forKey:kYSStrokeAnimationKey];
    
    
    self.isAnimating = true;
    
    if (self.hidesWhenStopped) {
        self.hidden = NO;
    }
}

- (void)stopAnimating {
    if (!self.isAnimating)
        return;
    
    [self.progressLayer removeAnimationForKey:kYSRotationAnimationKey];
    [self.progressLayer removeAnimationForKey:kYSStrokeAnimationKey];
    self.isAnimating = false;
    
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

#pragma mark - Private
- (void)updatePath
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
    CGFloat startAngle = (CGFloat)(0);
    CGFloat endAngle = (CGFloat)(2*M_PI);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
    
    self.progressLayer.strokeStart = 0.f;
    self.progressLayer.strokeEnd = 0.f;
}

#pragma mark - Properties


-(void)setProgress:(float)progress
{
    int num = floorf(progress*100);
    [_progressLabel setText:[NSString stringWithFormat:@"%d%%",num]];
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 1.5f;
    }
    return _progressLayer;
}

- (BOOL)isAnimating {
    return _isAnimating;
}

- (CGFloat)lineWidth {
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.progressLayer.lineWidth = lineWidth;
    [self updatePath];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    _hidesWhenStopped = hidesWhenStopped;
    self.hidden = !self.isAnimating && hidesWhenStopped;
}
@end







#pragma mark - 扩展一个CZPhotoIMG实体类

@interface CZPhotoIMG : NSObject
@property (nonatomic, strong) id imageSource;           // 大图
@property (nonatomic, strong) UIImage *thumbImage;      // 缩略图
@property (nonatomic, assign) CGRect thumbFrame;       // 缩略图初始位置
@property (nonatomic, copy) NSString *title;            // 图片描述
@property (nonatomic, copy) NSString *subtitle;         // 图片详情
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isFirstShow;
@end

@implementation CZPhotoIMG
@end






#pragma mark - 扩展一个CZPhotoIMGView图片类

#define kCZPhotoIMGBrowserPadding 10.0f                   // 两个图片间的间距
#define kCZPhotoIMGBrowserMaxZoomScale 2.0f               // 最大缩放倍数
#define kCZPhotoIMGBrowserToolbarHeight  44.0f            // 底部工具条默认宽度
static NSString *const kCZPhotoIMGBrowserHide = @"kNotifacationSingleTapped";
static NSString *const kCZPhotoIMGBrowserPhotoViewSingleTap = @"kCZPhotoIMGBrowserPhotoViewSingleTap";
@interface CZPhotoIMGView : UIScrollView <UIScrollViewDelegate>
{
    YYAnimatedImageView     *_imageView;                        // 图片视图
}
@property (nonatomic) NSInteger currentIndex;           // 和photo的index匹对以区分是否接收通知
@property (nonatomic, strong) CZPhotoIMG *photo;
@property (nonatomic, strong) CZPhotoIMGLoadingView *loadingView;
@property (nonatomic, strong) UIView *backGroupView;

- (void)reset;
@end

@implementation CZPhotoIMGView

- (void)dealloc
{
   
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 基本属性
        self.clipsToBounds = YES;
        self.scrollEnabled = YES;
        self.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        
        // 展示的图片控件
        _imageView = [[YYAnimatedImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        
        _backGroupView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_backGroupView setBackgroundColor:[UIColor blackColor]];
        [_backGroupView setAlpha:0.5];
        [_backGroupView setHidden:YES];
        [self addSubview:_backGroupView];
        
        
        
        // 添加指示器
        _loadingView = [[CZPhotoIMGLoadingView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _loadingView.tintColor = [UIColor whiteColor];
        _loadingView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,
                                          [UIScreen mainScreen].bounds.size.height/2);
        _loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView];
        
        
        // 添加手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        UILongPressGestureRecognizer *longTag = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handLongTap:)];
        [longTag setMinimumPressDuration:0.4f];
        [self addGestureRecognizer:longTag];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

#pragma mark - 设置图片
- (void)setPhoto:(CZPhotoIMG *)photo
{
    self.userInteractionEnabled = YES;
    if (_photo == photo) return;
    _photo = photo;
    if (!_photo) {
        _imageView.image = nil;
        return;
    }
    
    
    if ([photo.imageSource isKindOfClass:[UIImage class]]) {
        
        [_imageView setImage:photo.imageSource];
        
        
    }else if ([photo.imageSource isKindOfClass:[NSString class]]) {
        
        [_backGroupView setHidden:NO];
        [self.loadingView startAnimating];
        @weakify(self);
        [_imageView setImageWithURL:[NSURL URLWithString:photo.imageSource] placeholder:_photo.thumbImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            @strongify(self);
            if (!self) return;
            CGFloat progress = receivedSize / (float)expectedSize;
            progress = progress < 0.01 ? 0.01 : progress > 1 ? 1 : progress;
            if (isnan(progress)) progress = 0;
            [self.loadingView setProgress:progress];
            
            
        } transform:nil completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
            
            @strongify(self);
            if (!self) return;
            [self.loadingView stopAnimating];
            [self.backGroupView setHidden:YES];
            
            if (stage == YYWebImageStageFinished) {
                self.maximumZoomScale = 3;
                if (stage == YYWebImageStageFinished) {
                    [self adjustFrame];
                    
                }else{
                    [CZProgressHUD showTitle:@"图片下载失败" toView:nil];
                }
            }
        }];
    }
    [self adjustFrame];
}



#pragma mark 调整frame
- (CGRect)adjustFrame
{
    if (!_imageView.image) return CGRectZero;
    self.userInteractionEnabled = YES;
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    
    // 计算水平和垂直方向缩放比(保证过长或过宽有一个方向充满屏幕)
    CGFloat scale_H = boundsSize.width / imageSize.width;
//    CGFloat scale_V = boundsSize.height / imageSize.height;
    
    CGFloat minScale = scale_H;
//    CGFloat minScale = MIN(scale_H, scale_V);
    // 如果图片水平和垂直都小于屏幕则不缩放
//    if (scale_H >= 1 && scale_V >= 1) minScale = 1.0;
    
    self.maximumZoomScale = kCZPhotoIMGBrowserMaxZoomScale;
    
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    if (minScale>1) {
        self.minimumZoomScale = 1.0;
        self.zoomScale = 1.0;
    }
    
    // 设置imageView的frame
    CGRect imageViewRect = CGRectMake(0,
                                      0,
                                      imageSize.width * minScale,
                                      imageSize.height * minScale);
    // 居中
    if (imageViewRect.size.width < boundsSize.width)
        imageViewRect.origin.x = floor((boundsSize.width - imageViewRect.size.width) / 2);
    if (imageViewRect.size.height < boundsSize.height)
        imageViewRect.origin.y = floor((boundsSize.height - imageViewRect.size.height) / 2);
    
    if (_photo.isFirstShow) { // 第一次显示的图片
        
        _photo.isFirstShow = NO; // 已经显示过了
        if (_photo.thumbFrame.size.width>0&&_photo.thumbFrame.size.height>0&&_photo.thumbImage) {
            
            [_imageView setFrame:_photo.thumbFrame];
            
            self.userInteractionEnabled = NO;
            __weak typeof(self)ws = self;
            [UIView animateWithDuration:0.3 animations:^{
                _imageView.frame = imageViewRect;
            } completion:^(BOOL finished) {
                ws.userInteractionEnabled = YES;
            }];
        }else{
             _imageView.frame = imageViewRect;
        }
    } else {
        _imageView.frame = imageViewRect;
    }
    return imageViewRect;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // 图像缩小时候始终居中(分别计算x-y的偏差)
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - 手势
- (void)handleSingleTap:(UITapGestureRecognizer *)tap
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCZPhotoIMGBrowserPhotoViewSingleTap object:self];
    [self.loadingView stopAnimating];
    self.contentOffset = CGPointZero;
//    if () {
    
        __weak typeof(self)ws = self;
        self.userInteractionEnabled = NO;
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        
        if ((_photo.thumbFrame.origin.x < bounds.size.width||_photo.thumbFrame.origin.x > (0-_photo.thumbFrame.size.width) ||  _photo.thumbFrame.origin.y < bounds.size.height||_photo.thumbFrame.origin.y > (0-_photo.thumbFrame.size.height))&&_photo.thumbFrame.size.width>0&&_photo.thumbFrame.size.height>0&&_photo.thumbImage) {
            
            [UIView animateWithDuration:0.3 animations:^{
                _imageView.frame = ws.photo.thumbFrame;
            }completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCZPhotoIMGBrowserHide object:self];
                ws.userInteractionEnabled = YES;
                _imageView.image = ws.photo.thumbImage;
            }];
            
        }else{
            
            [UIView animateWithDuration:0.3 animations:^{
                [_imageView setTransform:CGAffineTransformScale(_imageView.transform, 0.8, 0.8)];
                [_imageView setAlpha:0];
            }completion:^(BOOL finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCZPhotoIMGBrowserHide object:self];
                ws.userInteractionEnabled = YES;
            }];
//            [self setZoomScale:self.minimumZoomScale animated:YES];
        }
        
//    }else{
//        
//        [self setZoomScale:self.minimumZoomScale animated:NO];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kCZPhotoIMGBrowserHide object:self];
//    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture
{
    if (self.zoomScale == self.minimumZoomScale) {
        // 放大倍数(self.maximumZoomScale + self.minimumZoomScale)/2 ,这里取1.3
        CGFloat newScale = (self.maximumZoomScale + self.minimumZoomScale)/2;
        // 手势点击位置(放大中心点)
        CGPoint touchPoint = [gesture locationInView:gesture.view];
        CGRect zoomRect;
        // 显示的部分按比例缩小scale倍数，即为放大
        zoomRect.size.width = self.frame.size.width / newScale;
        zoomRect.size.height = self.frame.size.height / newScale;
        // 根据点击中心获得一个缩放矩形
        zoomRect.origin.x = touchPoint.x/self.zoomScale - zoomRect.size.width/2;
        zoomRect.origin.y = touchPoint.y/self.zoomScale - zoomRect.size.height/2;
        [self zoomToRect:zoomRect animated:YES];
    } else
        [self setZoomScale:self.minimumZoomScale animated:YES];
}


- (void)handLongTap:(UITapGestureRecognizer *)longPress
{
    if(longPress.state != UIGestureRecognizerStateBegan)return;
    if (!_imageView.image) {
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:(id<UIActionSheetDelegate>)self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"保存到相册",nil];
    [actionSheet showInView:self];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            });
        }break;
        case 1:{
            
        }break;
    }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [CZProgressHUD showTitle:@"失败" toView:nil];
    } else {
        [CZProgressHUD showTitle:@"成功" toView:nil];
    }
}



#pragma mark - 重置
- (void)reset
{
    self.maximumZoomScale = 1.0;
    self.minimumZoomScale = 1.0;
    [self setZoomScale:1.0];
    self.contentSize = CGSizeZero;
    self.userInteractionEnabled = NO;
    
    _imageView.frame = CGRectZero;
    _imageView.image = nil;
    self.photo = nil;
    [self.loadingView stopAnimating];
}
@end

#pragma mark - 本体类的实现
@interface CZPhotoIMGBrowser () <UIScrollViewDelegate>
{
    UIScrollView    *_photoScrollView;  // 滑动视图
    NSMutableSet    *_visibleViews;     // 可见视图集合
    NSMutableSet    *_reusableViews;    // 回收的(可重用)视图集合
    
    NSMutableArray  *_photosArray;      // 图片对象集合
    NSInteger       _currentIndex;      // 当前展示的下标
    
    UIView       *_toolbar;          // 工具条
}
@end

@implementation CZPhotoIMGBrowser

+ (instancetype)showPhotos:(NSArray *)photos thumbs:(NSArray *)thumbs atIndex:(NSInteger)index
{
    return [[CZPhotoIMGBrowser alloc] initWithPhotos:photos
                                            thumbs:thumbs
                                           atIndex:index];
}

- (instancetype)initWithPhotos:(NSArray *)photos thumbs:(NSArray *)thumbs atIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        // 初始化配置
        _currentIndex = index;
        _photosArray = [self arrayWithPhotos:photos thumbs:thumbs];
        
        _visibleViews = [NSMutableSet set];
        _reusableViews = [NSMutableSet set];
        
        [self show];
    }
    return self;
}

- (NSMutableArray *)arrayWithPhotos:(NSArray *)photos thumbs:(NSArray *)thumbs
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSInteger count = MAX(photos.count, thumbs.count);
    for (NSInteger i=0; i<count; i++) {
        CZPhotoIMG *photo = [[CZPhotoIMG alloc] init];
        photo.index = i;
        photo.isFirstShow = (i==_currentIndex? YES: NO);
        
        if (i < thumbs.count) {
            photo.thumbImage = thumbs[i][CZPhotoIMGThumbs_Key_Image];
            photo.thumbFrame = CGRectFromString(thumbs[i][CZPhotoIMGThumbs_Key_Frame]);
        }
        
        if (i < photos.count) {
            photo.title = photos[i][CZPhotoIMGPhotos_Key_Title];
            photo.subtitle = photos[i][CZPhotoIMGPhotos_Key_SubTitle];
            photo.imageSource = photos[i][CZPhotoIMGPhotos_Key_Photo];
        }
        [resultArray addObject:photo];
    }
    
    return resultArray;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self addScrollView];
    [self addToolbarControl];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - 添加视图
- (void)addScrollView
{
    
    UIScrollView *s  = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [s setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:s];
    
    CGRect frame = self.view.bounds;
    frame.origin.x -= kCZPhotoIMGBrowserPadding;
    frame.size.width += kCZPhotoIMGBrowserPadding * 2;
    
    _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
    _photoScrollView.delegate = self;
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.clipsToBounds = YES;
    _photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.showsHorizontalScrollIndicator = NO;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_photoScrollView];
    
    _photoScrollView.contentSize = CGSizeMake(frame.size.width * _photosArray.count, 0);
    _photoScrollView.contentOffset = CGPointMake(_currentIndex * frame.size.width, 0);
}

- (void)addToolbarControl
{
    CGRect toolbarFrame = CGRectMake(0,
                                     self.view.bounds.size.height-kCZPhotoIMGBrowserToolbarHeight,
                                     self.view.bounds.size.width,
                                     kCZPhotoIMGBrowserToolbarHeight);
    _toolbar = [[UIView alloc] initWithFrame:toolbarFrame];
    [self.view addSubview:_toolbar];
    
    UIView *back = [[UIView alloc] initWithFrame:_toolbar.bounds];
    [back setTag:99];
    [back setBackgroundColor:[UIColor blackColor]];
    [back setAlpha:0.6];
    [_toolbar addSubview:back];
    
    
    [self initToolbarItems];
    
    // 显示隐藏控制按钮
    UIButton *controlBtn = [UIButton buttonWithType:0];
    [controlBtn setTag:88];
    controlBtn.frame = CGRectMake(self.view.bounds.size.width-kCZPhotoIMGBrowserToolbarHeight,
                                  self.view.bounds.size.height-44,
                                  44,
                                  kCZPhotoIMGBrowserToolbarHeight);
     [controlBtn setImage:[UIImage imageNamed:@"CZPhotoIcon.bundle/icon_more_down.png"] forState:0];
    [controlBtn addTarget:self action:@selector(showOrHideToolbar:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:controlBtn];
}

#pragma mark - toolbar相关
- (void)initToolbarItems
{
    // 详情
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.tag = 100;
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    subtitleLabel.textAlignment = NSTextAlignmentLeft;
    subtitleLabel.font = [UIFont systemFontOfSize:12];
    [_toolbar addSubview:subtitleLabel];
    
    // 分割线
    UILabel *lineLabel = [[UILabel alloc] init];
    lineLabel.frame = CGRectMake(0,
                                 CGRectGetHeight(_toolbar.frame)-kCZPhotoIMGBrowserToolbarHeight,
                                 CGRectGetWidth(_toolbar.frame),
                                 0.5);
    lineLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    lineLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [_toolbar addSubview:lineLabel];
    
    // 主标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(44/2,
                                  CGRectGetHeight(_toolbar.frame)-kCZPhotoIMGBrowserToolbarHeight,
                                  CGRectGetWidth(_toolbar.frame)-44,
                                  kCZPhotoIMGBrowserToolbarHeight);
    titleLabel.tag = 101;
    titleLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [_toolbar addSubview:titleLabel];
}

- (void)showOrHideToolbar:(UIButton *)btn
{
    BOOL isShowing = _toolbar.alpha;
    CGFloat height = CGRectGetHeight(_toolbar.frame);
    [UIView animateWithDuration:0.3 animations:^{
        
        if (isShowing) {
            [btn setTransform:CGAffineTransformMakeRotation(M_PI)];
        }else{
            [btn setTransform:CGAffineTransformMakeRotation(0)];
        }
        _toolbar.alpha = isShowing? 0: 1;
        _toolbar.frame = CGRectMake(0,
                                    self.view.bounds.size.height-(isShowing? 0: height),
                                    self.view.bounds.size.width,
                                    height);
    }];
}

- (void)updateToolbarAtIndex:(NSInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didChangedToPageAtIndex:)]) {
        [self.delegate  photoBrowser:self didChangedToPageAtIndex:index];
    }
    
    if (!_toolbar) return;
    
    _toolbar.frame = _toolbar.frame;
    
    CZPhotoIMG *photo = _photosArray[index];
    NSNumber *currentIndex = [NSNumber numberWithInteger:index+1];
    NSNumber *totalCount = [NSNumber numberWithInteger:_photosArray.count];
    
    // 更新主标题
    UILabel *titleLabel = (UILabel *)[_toolbar viewWithTag:101];

    titleLabel.text = [NSString stringWithFormat:@"%@(%@ / %@)",photo.title,currentIndex,totalCount];
    
    // 更新副标题描述
    UILabel *subtitleLabel = (UILabel *)[_toolbar viewWithTag:100];
    subtitleLabel.text = photo.subtitle;
    
    CGFloat textHeight = 0;
    if (photo.subtitle.length && photo.subtitle) {
        CGSize size = [self sizeForString:photo.subtitle
                                     font:subtitleLabel.font
                                     size:CGSizeMake(CGRectGetWidth(_toolbar.frame)-20, MAXFLOAT)];
        textHeight = MAX(size.height+20, 40);
    }
    CGFloat newHeight = kCZPhotoIMGBrowserToolbarHeight + textHeight;
    _toolbar.frame = CGRectMake(0,
                                self.view.bounds.size.height - newHeight,
                                self.view.bounds.size.width,
                                newHeight);
    subtitleLabel.frame = CGRectMake(10, 0, CGRectGetWidth(_toolbar.frame)-20, textHeight);
    UIView *v = [_toolbar viewWithTag:99];
    [v setFrame:_toolbar.bounds];
}

#pragma mark - calculate
- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font size:(CGSize)size;
{
    CGRect newRect = [string boundingRectWithSize:size
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName : font}
                                          context:nil];
    return newRect.size;
}

#pragma mark - 浏览图片
- (void)hide
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)photoViewSingleTap
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    [_toolbar removeFromSuperview];
    [[self.view viewWithTag:88] removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)show
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoViewSingleTap) name:kCZPhotoIMGBrowserPhotoViewSingleTap object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hide) name:kCZPhotoIMGBrowserHide object:nil];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    [self showPhotos];
}

- (void)showPhotos
{
    // bounds:{{0, 0}, {size.width+offset(左正右负), size.height}}
    CGRect visibleBounds = _photoScrollView.bounds;
    NSInteger firstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+kCZPhotoIMGBrowserPadding*2) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-kCZPhotoIMGBrowserPadding*2) / CGRectGetWidth(visibleBounds));
    
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photosArray.count) firstIndex = _photosArray.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photosArray.count) lastIndex = _photosArray.count - 1;
    
    // 回收不再显示的ImageView
    for (CZPhotoIMGView *photoView in _visibleViews) {
        NSInteger index = photoView.photo.index;
        if (index < firstIndex || index > lastIndex) {
            // 回收之前把状态清空
            [photoView reset];
            [_reusableViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    // 移除相同的元素
    [_visibleViews minusSet:_reusableViews];
    
    // 保持只重用队列只存在一个对象
    while (_reusableViews.count > 1)
        [_reusableViews removeObject:[_reusableViews anyObject]];
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++)
    {
        // 判断当前要展示的图片是否已经展示.
        if (![self isShowingPhotoViewAtIndex:index])
            [self showPhotoViewAtIndex:index];
    }
    
    // 取得拉到屏幕中间时候的index,更新对应的toolbar
    NSInteger controlIndex = floor((_photoScrollView.contentOffset.x + self.view.bounds.size.width/2) / _photoScrollView.bounds.size.width);
    if (controlIndex < 0)
        controlIndex = 0;
    if (controlIndex > _photosArray.count-1)
        controlIndex = _photosArray.count-1;
    [self updateToolbarAtIndex:controlIndex];
}

- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index
{
    for (CZPhotoIMGView *photoView in _visibleViews) {
        if (photoView.photo.index == index)
            return YES;
    }
    return  NO;
}

- (void)showPhotoViewAtIndex:(NSInteger)index
{
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    
    // 因为滚动视图可见范围左右多了kPadding差
    photoViewFrame.origin.x = (bounds.size.width * index) + kCZPhotoIMGBrowserPadding;
    photoViewFrame.size.width -= kCZPhotoIMGBrowserPadding * 2;
    
    CZPhotoIMGView *photoView = [self dequeueReusablePhotoView];
    // 如果集合中不存在可重用的对象
    if (!photoView) {
        photoView = [[CZPhotoIMGView alloc] init];
    }
    
    CZPhotoIMG *photo = _photosArray[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    photoView.currentIndex = photo.index;
    
    [_visibleViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
}

#pragma mark 循环利用某个view
- (CZPhotoIMGView *)dequeueReusablePhotoView
{
    // 取集合中任意一对象重用
    CZPhotoIMGView *photoView = [_reusableViews anyObject];
    if (photoView)
        [_reusableViews removeObject:photoView];
    
    return photoView;
}

#pragma mark - 滚动视图代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self showPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
