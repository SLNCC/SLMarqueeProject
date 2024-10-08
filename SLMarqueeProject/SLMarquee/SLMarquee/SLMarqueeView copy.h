//
//  SLMarqueeView.h
//  GFMarqueeViewDemo
//
//  Created by joedd on 2024/10/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 跑马灯的滚动状态
typedef NS_ENUM(NSInteger, MarqueeState) {
    MarqueeStateRunning = 0,
    MarqueeStatePaused,
    MarqueeStateStopped,
};

typedef void(^DidSelectedIndexBlock)(NSInteger);

@interface SLMarqueeView : UIView
/// label间距
@property(nonatomic,assign) CGFloat textSpacing;
/// 滚动速度，默认 60 pt/s
@property(nonatomic,assign) CGFloat textScrollSpeed;
/// 文本颜色
@property(nonatomic,strong) UIColor *textColor;
/// 文本背景色
@property(nonatomic,strong) UIColor *textBgColor;

///文本增加宽度间距
@property(nonatomic,assign) CGFloat textBorderSpacing;

///文本切圆角
@property(nonatomic,assign) BOOL textCornerRadius;

///文本字体
@property(nonatomic,strong) UIFont *font;

/// 文本数据
@property(nonatomic,strong) NSArray<NSString *> *textList;

@property(nonatomic, assign) BOOL isRunARound;

/// 选中回调
@property(nonatomic, copy) DidSelectedIndexBlock didSelectedIndexBlock;
// 开始滚动
-(void)run;
// 暂停滚动
-(void)pause;
// 停止滚动
-(void)stop;

- (void)insertText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
