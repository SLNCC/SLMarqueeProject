//
//  SLMarqueeView.m
//  SLMarqueeViewDemo
//
//  Created by joedd on 2024/10/8.
//

#import "SLMarqueeView.h"
#import "SLYYWeakProxy.h"
#import "SLColor.h"

@interface SLMarqueeView()

@property(nonatomic,assign) enum MarqueeState state;
@property(nonatomic,assign) BOOL isRunning;
@property(nonatomic,assign) BOOL isPaused;
@property(nonatomic,assign) BOOL isStopped;
@property(nonatomic,assign) NSInteger nextIndex;
@property(nonatomic,strong) CADisplayLink * displayLink;
@property(nonatomic,strong) UIView *marqueeLabelContainerView;
@property(nonatomic,strong) NSMutableArray<UILabel *> *onScreenMarqueeLabels;
@property(nonatomic,strong) NSMutableArray<UILabel *> *offScreenMarqueeLabels;


@end

@implementation SLMarqueeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.state = MarqueeStateStopped;
        self.nextIndex = NSNotFound;
        self.textSpacing = 20.f;
        self.textScrollSpeed = 60.f;
        self.onScreenMarqueeLabels = [NSMutableArray array];
        self.offScreenMarqueeLabels = [NSMutableArray array];
        self.marqueeLabelContainerView.backgroundColor = [UIColor clearColor];
        self.textColor = [SLColor colorWithHexString:@"#FFF7CB"];
        self.font = [UIFont systemFontOfSize:17.f];
        [self setupView];
    }
    return self;
}

// MARK: ------------------ 赋值操作 ------------------

- (void)setTextList:(NSArray<NSString *> *)textList {
    _textList = textList;
    [self stop];
    [self resetIndex];
    [self run];
}

- (void)insertText:(NSString *)text {
    NSMutableArray *muArray = [NSMutableArray arrayWithArray:_textList];
    if (_nextIndex < _textList.count) {
        [muArray insertObject:text atIndex:_nextIndex];
    }else {
        [muArray addObject:text];
    }
    _textList = muArray;
    if (self.displayLink == nil) {
        [self resetIndex];
        if (_nextIndex == NSNotFound) {
            return;
        }
        [self run];
    }
}

// MARK: ------------------ 滚动控制 ------------------

// 开始滚动
- (void)run {
    if (self.isRunning)  return;
    if (self.textList.count <= 0)  return;

    if (self.state == MarqueeStateStopped) {
        [self addOnScreenMarqueeLabel];
    }
 
    [self resumeDisplayLink];
    self.state = MarqueeStateRunning;
}

// 暂停滚动
- (void)pause {
    if (!self.isRunning)  return;
    [self pauseDisplayLink];
    self.state = MarqueeStatePaused;
}

// 停止滚动
- (void)stop {
    if (self.isPaused) return ;
    [self resetIndex];
    [self pauseDisplayLink];
    [self clearOnScreenMarqueeLabels];
    [self resetContainerViewBounds];
    self.state = MarqueeStateStopped;
}

// MARK: ------------------ 事件回调 ------------------

- (void)tapAction:(UITapGestureRecognizer *) sender {
    NSInteger tag = sender.view.tag;
    if (self.didSelectedIndexBlock) {
        self.didSelectedIndexBlock(tag);
    }
}

// MARK: ------------------ 布局 ------------------

- (void)layoutSubviews {
    [super layoutSubviews];
    self.marqueeLabelContainerView.frame = self.bounds;

}

- (void)setupView {
    self.marqueeLabelContainerView = [[UIView alloc] init];
    [self addSubview:self.marqueeLabelContainerView];
}

- (void)resetContainerViewBounds {
    CGRect rect = self.marqueeLabelContainerView.bounds;
    rect.origin = CGPointZero;
    self.marqueeLabelContainerView.bounds = rect;
}

// MARK: ------------------ 添加移除标签 ------------------

- (void)addOnScreenMarqueeLabel {
    NSInteger currentIndex = _nextIndex;
    [self increaseIndex];
    CGFloat height = self.frame.size.height;
    height = height > 0 ? height : 38.0;
    UILabel * marqueeLabel = [self dequeueReusableMarqueeLabel];
    marqueeLabel.textColor = self.textColor;
    marqueeLabel.font = self.font;
    marqueeLabel.textAlignment = NSTextAlignmentCenter;
    marqueeLabel.tag = currentIndex;
    marqueeLabel.text = self.textList[currentIndex];
    if (self.textBgColor != nil) {
        marqueeLabel.backgroundColor = self.textBgColor;
    
    }else {
        marqueeLabel.backgroundColor = [UIColor clearColor];
    }
    if (self.textCornerRadius) {
        marqueeLabel.layer.cornerRadius = height/2.f;
        marqueeLabel.layer.masksToBounds = YES;
    }
    [marqueeLabel sizeToFit];
    
    CGRect rect ;
    rect.size.height = height;
    rect.size.width = marqueeLabel.frame.size.width + self.textBorderSpacing;
    
    if ([self.onScreenMarqueeLabels lastObject]) {
        rect.origin.x = CGRectGetMaxX([self.onScreenMarqueeLabels lastObject].frame) + self.textSpacing;
    } else {
        rect.origin.x = 0;
    }
    if (self.isRunARound) {
        if (currentIndex == 0) {
            CGFloat width = self.frame.size.width;
            if (width == 0) width = [UIScreen mainScreen].bounds.size.width;
            rect.origin.x += width;
        }
    }
    rect.origin.y = 0;
    marqueeLabel.frame = rect;
    [marqueeLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer * tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [marqueeLabel addGestureRecognizer:tapGR];
    
    [self.onScreenMarqueeLabels addObject:marqueeLabel];
    [self.marqueeLabelContainerView addSubview:marqueeLabel];
}

-(void)clearOnScreenMarqueeLabels {
    for (UILabel *label in self.onScreenMarqueeLabels) {
        [self recycle:label];
    }
    [self.onScreenMarqueeLabels removeAllObjects];
}

-(void)removeOffScreenMarqueeLabel {
    UILabel *marqueeLabel = [self.onScreenMarqueeLabels firstObject];
    [self recycle:marqueeLabel];
    [self.onScreenMarqueeLabels removeObject:marqueeLabel];
}

// MARK: ------------------ 循环利用 ------------------
- (UILabel *)dequeueReusableMarqueeLabel {
    UILabel * oldLabel = [self.offScreenMarqueeLabels lastObject] ;
    [self.offScreenMarqueeLabels removeLastObject];
    if (oldLabel != nil) {
        return oldLabel;
    }
    UILabel * newLabel = [[UILabel alloc] init];
    newLabel.textColor = self.textColor;
    newLabel.font = self.font;
    newLabel.textAlignment = NSTextAlignmentCenter;
    return newLabel;
}

- (void)recycle:(UILabel *)marqueeLabel {
    [self.offScreenMarqueeLabels addObject:marqueeLabel];
}


//MARK: ------------------ 更新索引 ------------------

- (void)increaseIndex {
    _nextIndex = (_nextIndex + 1) % self.textList.count;
}

- (void)resetIndex {
    _nextIndex = self.textList.count <= 0 ? NSNotFound : 0;
}


//MARK: ------------------ 定时器处理 ------------------

-(void)invalidateDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

-(void)resumeDisplayLink {
    if (self.displayLink == nil) {
        CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget:[SLYYWeakProxy proxyWithTarget:self] selector:@selector(step:)];
        self.displayLink = displayLink;
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    self.displayLink.paused = NO;
}

-(void)pauseDisplayLink {
    self.displayLink.paused = YES;
}

-(void)step:(CADisplayLink *) displayLink {
    
    CGFloat duration =  displayLink.duration;
    CGFloat originXOffset = self.textScrollSpeed * duration;
    
    UILabel * firstLabel = [self.onScreenMarqueeLabels firstObject];
    CGRect rect = self.marqueeLabelContainerView.bounds;
    rect.origin.y = 0;
    rect.origin.x = self.marqueeLabelContainerView.bounds.origin.x + originXOffset;
    self.marqueeLabelContainerView.bounds = rect;
    
    if (firstLabel != nil && CGRectGetMaxX(firstLabel.frame) <= CGRectGetMinX(self.marqueeLabelContainerView.bounds)) {
        [self removeOffScreenMarqueeLabel];
    }
    
    UILabel * lastLabel = [self.onScreenMarqueeLabels lastObject];
    if (lastLabel != nil && ((CGRectGetMaxX(self.marqueeLabelContainerView.bounds) - CGRectGetMaxX(lastLabel.frame)) >= self.textSpacing)) {
        [self addOnScreenMarqueeLabel];
    }
 
}

// MARK: ------------------ 视图关系变更 ------------------

- (void)willMoveToWindow:(UIWindow *)newWindow {
    
    if (newWindow == nil) {
        [self pauseDisplayLink];
    } else if (self.isRunning) {
        [self resumeDisplayLink];
    }
    [super willMoveToWindow: newWindow];
}

// MARK: ------------------ GETTER ------------------

- (BOOL)isRunning {
    return self.state == MarqueeStateRunning;
}

- (BOOL)isPaused {
    return self.state == MarqueeStatePaused;
}

- (BOOL)isStopped {
    return self.state == MarqueeStateStopped;
}

@end
