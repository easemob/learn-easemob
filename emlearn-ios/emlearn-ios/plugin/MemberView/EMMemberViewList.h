#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>
#import "EMMemberView.h"

/** 设置代理 */
@protocol RollViewDelegate <NSObject>

-(void)didSelectPicWithIndexPath:(NSInteger)index;
@end

@interface EMMemberViewList : UIView

@property (nonatomic, strong) EMMemberView *localView;
@property (nonatomic, strong) EMMemberView *teacherView;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, assign) id<RollViewDelegate> delegate;
@property (nonatomic) int viewWidth;

/**
 初始化
 
 @param frame 设置View大小
 @param distance 设置Scroll距离View两侧距离
 @param gap 设置Scroll内部 图片间距
 @return 初始化返回值
 */
- (instancetype)initWithFrame:(CGRect)frame withDistanceForScroll:(float)distance withGap:(float)gap;

/** 滚动视图数据 */
-(void)removeView:(NSString *)userName;
-(EMMemberView*)newMemberView:(NSString *)key;
-(void)addTeacherView;
-(void)addLocalView;
-(EMMemberView*)getMemberView:(NSString *)userName;
@end

