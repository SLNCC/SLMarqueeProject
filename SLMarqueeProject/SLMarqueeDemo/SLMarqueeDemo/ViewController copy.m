//
//  ViewController.m
//  SLMarqueeDemo
//
//  Created by joedd on 2024/10/8.
//

#import "ViewController.h"
#import "SLMarqueeView.h"
@interface ViewController ()
@property(nonatomic, strong) SLMarqueeView *oneMarqueeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.oneMarqueeView];
    self.oneMarqueeView.textList = @[@"好，非常好，很好，👌",@"不错，非常不错，很不错，😌"];
}

-(SLMarqueeView *)oneMarqueeView {
    if (!_oneMarqueeView) {
        _oneMarqueeView = [[SLMarqueeView alloc] initWithFrame:CGRectMake(0, 180, [UIScreen mainScreen].bounds.size.width, 29)];
        _oneMarqueeView.backgroundColor = [UIColor clearColor];
        _oneMarqueeView.textColor = [UIColor whiteColor];
        _oneMarqueeView.textBgColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _oneMarqueeView.textBorderSpacing = 20;
        _oneMarqueeView.textCornerRadius = YES;
        _oneMarqueeView.clipsToBounds = YES;
        _oneMarqueeView.font = [UIFont systemFontOfSize:12.f weight: UIFontWeightMedium];
        _oneMarqueeView.isRunARound = YES;
    }
    return _oneMarqueeView;
}


@end
