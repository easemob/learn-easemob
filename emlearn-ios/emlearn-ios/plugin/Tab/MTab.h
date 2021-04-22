#import <UIKit/UIKit.h>

@protocol MTabDelegate <NSObject>
    - (UIView *)changeView:(NSInteger)index;
@end

@interface MTab : UIView
    @property (nonatomic,weak) id<MTabDelegate> delegate;
    -(UIFont*)textFont;
    - (void)setTitle:(NSArray*)array;
    - (instancetype)init:(BOOL)isUp;
    - (void)setupView;
@end
