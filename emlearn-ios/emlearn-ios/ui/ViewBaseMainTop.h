#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewBaseMainTop : UIViewController
@property(nonatomic,strong) UILabel* roomNameLable;
@property(nonatomic,strong) UILabel* timeLabel;

@property (nonatomic) UIViewController* confVC;

@property (nonatomic, assign) int timeLength;
@property (strong, nonatomic) NSTimer *timeTimer;


- (instancetype)initWithConfVC:(UIViewController*)confVC;
@end

NS_ASSUME_NONNULL_END
