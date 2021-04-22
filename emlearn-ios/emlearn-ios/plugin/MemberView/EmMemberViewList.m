#import "EMMemberViewList.h"
#import "EMLearnOption.h"
#import <Masonry.h>
#import "EMDefines.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface EMMemberViewList ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *leftView;

@property (nonatomic, strong) UIImageView *rightView;

@property (nonatomic, strong) UIScrollView *scrollView;


@property (nonatomic, strong) NSMutableDictionary *rollDataDict;



@property (nonatomic) CGFloat scrollViewWidth;


@end

@implementation EMMemberViewList

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.leftView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.leftView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
        self.leftView.image = [UIImage imageNamed:@"left_gary"];
        self.leftView.userInteractionEnabled=YES;
        self.leftView.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *leftViewTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftViewClick:)];
        [self.leftView addGestureRecognizer:leftViewTap];
        [self addSubview:self.leftView];
        [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(@0);
            make.bottom.equalTo(self.mas_bottom);
            make.height.equalTo(self.mas_height);
            make.width.equalTo(@10);
            
        }];
        
        
        /** 设置 UIScrollView */
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
//            make.right.mas_equalTo(@250);
            make.width.mas_equalTo(SCREEN_HEIGHT);
            make.bottom.equalTo(self.mas_bottom);
            make.height.equalTo(self.mas_height);
            
        }];
        
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;
        
        self.scrollView.clipsToBounds = NO;
        
        /** 添加手势 */
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self.scrollView addGestureRecognizer:tap];
        self.scrollView.showsHorizontalScrollIndicator = YES;
        
        self.rightView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.rightView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
        self.rightView.image = [UIImage imageNamed:@"right_gary"];
        
        self.rightView.userInteractionEnabled=YES;
        self.rightView.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *rightViewTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rightViewClick:)];
        [self.rightView addGestureRecognizer:rightViewTap];
        [self addSubview:self.rightView];
        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(@0);
            make.bottom.equalTo(self);
            make.height.equalTo(self);
            make.width.equalTo(@10);

        }];
//        int v =SCREEN_WIDTH;
//        int h =SCREEN_HEIGHT;
        
        
        /** 数据初始化 */
        self.rollDataDict = [[NSMutableDictionary alloc] init];
        self.scrollViewWidth = 0;
        
        [self bringSubviewToFront:self.rightView];
        [self bringSubviewToFront:self.leftView];
        if(SCREEN_HEIGHT > SCREEN_WIDTH){
            self.viewWidth = SCREEN_HEIGHT/ 6;
        }else{
            self.viewWidth = SCREEN_WIDTH/ 6;
        }
        self.viewWidth += 40;
    }
    
    
    return self;
}
- (void)leftViewClick:(UIGestureRecognizer *)sender
{
    int width = self.scrollView.contentOffset.x + self.viewWidth / 2;
    if(width + SCREEN_WIDTH  >self.scrollViewWidth){
        if(self.scrollViewWidth < SCREEN_WIDTH){
            return;
        }else{
            self.scrollView.contentOffset = CGPointMake(self.scrollViewWidth - SCREEN_WIDTH, 0);
        }
    }else{
        self.scrollView.contentOffset = CGPointMake(width, 0);
    }
}
- (void)rightViewClick:(UIGestureRecognizer *)sender
{
    int width = self.scrollView.contentOffset.x - self.viewWidth / 2;
    if(width  < 0){
        self.scrollView.contentOffset = CGPointMake(0, 0);
    }else{
        self.scrollView.contentOffset = CGPointMake(width, 0);
    }
}
#pragma mark - 视图数据
-(void)removeView:(NSString *)userName{
    EMMemberView* mv = [self.rollDataDict objectForKey:userName];
    if(mv != NULL){
        [mv setStream:NULL];
        if(userName !=@"sys-teacher"){
            [mv removeFromSuperview];
            [self.rollDataDict removeObjectForKey:userName];
        }
        
    }
    
}
-(EMMemberView*)getMemberView:(NSString *)userName{
    return [self.rollDataDict objectForKey:userName];
}

-(EMMemberView*)newMemberView:(NSString *)key{
    EMMemberView* mv = [[EMMemberView alloc]initWithFrame:CGRectZero role:ROLE_TYPE_STUDENT];
    [mv setVideoStatus:NO];
    [mv setAudioStatus:NO];

    
    [self.rollDataDict setObject:mv forKey:key];
    [self.scrollView addSubview:mv];
    long count = [self.rollDataDict count];
    
    mv.expanBlock = ^(NSInteger tag){
        if(tag == 1){
            [mv removeFromSuperview];
            [self.parentView layoutSubviews];
            [self.scrollView addSubview:mv];
            [mv mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.scrollView.mas_top);
                make.height.mas_equalTo(self.mas_height);
                make.width.mas_equalTo(self.viewWidth);
                if(count == 1){
                    make.left.equalTo(self.scrollView.mas_left);
                    self.scrollViewWidth = self.viewWidth;
                }else{
                    make.left.equalTo(self.scrollView.mas_left).offset((count-1) * self.viewWidth + (count-1) *5);
                    self.scrollViewWidth = count * self.viewWidth+ count *5;
                    
                }
            }];
        }else{
            [mv removeFromSuperview];
            [self.parentView layoutSubviews];
            [self.parentView addSubview:mv];
            [mv mas_remakeConstraints:^(MASConstraintMaker *make) {
                // make.centerX.mas_equalTo(self.parentView.mas_centerX);
                // make.centerY.mas_equalTo(self.parentView.mas_centerY);
                // make.width.mas_equalTo(400);
                // make.height.mas_equalTo(300);
                make.top.equalTo(self.scrollView.mas_top);
                make.height.mas_equalTo(self.mas_height);
                make.width.mas_equalTo(self.viewWidth);
                if(count == 1){
                    make.left.equalTo(self.scrollView.mas_left);
                    self.scrollViewWidth = self.viewWidth;
                }else{
                    make.left.equalTo(self.scrollView.mas_left).offset((count-1) * self.viewWidth + (count-1) *5);
                    self.scrollViewWidth = count * self.viewWidth+ count *5;
                    
                }
            }];
        }
        [self.parentView setNeedsUpdateConstraints];
    };
    mv.expanBlock(1);
    
//    [mv mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.scrollView.mas_top);
//        make.height.mas_equalTo(self.viewWidth);
//        make.width.mas_equalTo(self.viewWidth);
//        if(count == 1){
//            make.left.equalTo(self.scrollView.mas_left);
//            self.scrollViewWidth = self.viewWidth;
//        }else{
//            make.left.equalTo(self.scrollView.mas_left).offset((count-1) * self.viewWidth + (count-1) *5);
//            self.scrollViewWidth = count * self.viewWidth+ count *5;
           
//        }
//    }];
    [self.scrollView layoutIfNeeded];
    NSLog(@"mvmv:%@", mv);
    
    //设置轮播图当前的显示区域
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollViewWidth , 0);
    return mv;
}
-(void)addTeacherView{
    NSString *nickName = [EMLearnOption sharedOptions].nickName;
    self.teacherView = [[EMMemberView alloc]initWithFrame:CGRectZero role:ROLE_TYPE_TEACHER];
    [self.teacherView setRoleName:@"老师"];
    if([EMLearnOption sharedOptions].roleType == ROLE_TYPE_TEACHER){
        [self.teacherView setNickName:nickName];
    }
    
    [self.teacherView setVideoStatus:NO];
    [self.teacherView setAudioStatus:NO];
    
    [self.rollDataDict setObject:self.teacherView forKey:@"sys-teacher"];
    [self.scrollView addSubview:self.teacherView];
    long count = [self.rollDataDict count];
    
    self.teacherView.expanBlock = ^(NSInteger tag){
        if(tag == 1){
            [self.teacherView removeFromSuperview];
            [self.parentView layoutSubviews];
            [self.scrollView addSubview:self.teacherView];
            [self.teacherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.scrollView.mas_top);
                make.height.mas_equalTo(self.mas_height);
                make.width.mas_equalTo(self.viewWidth);
                if(count == 1){
                    make.left.equalTo(self.scrollView.mas_left);
                    self.scrollViewWidth = self.viewWidth;
                }else{
                    make.left.equalTo(self.scrollView.mas_left).offset((count-1) * self.viewWidth + (count-1) *5);
                    self.scrollViewWidth = count * self.viewWidth+ count *5;
                    
                }
            }];
        }else{
            [self.teacherView removeFromSuperview];
            [self.parentView layoutSubviews];
            [self.parentView addSubview:self.teacherView];
            [self.teacherView mas_remakeConstraints:^(MASConstraintMaker *make) {
                // make.centerX.mas_equalTo(self.parentView.mas_centerX);
                // make.centerY.mas_equalTo(self.parentView.mas_centerY);
                // make.width.mas_equalTo(400);
                // make.height.mas_equalTo(300);
                make.top.equalTo(self.scrollView.mas_top);
                make.height.mas_equalTo(self.mas_height);
                make.width.mas_equalTo(self.viewWidth);
                if(count == 1){
                    make.left.equalTo(self.scrollView.mas_left);
                    self.scrollViewWidth = self.viewWidth;
                }else{
                    make.left.equalTo(self.scrollView.mas_left).offset((count-1) * self.viewWidth + (count-1) *5);
                    self.scrollViewWidth = count * self.viewWidth+ count *5;
                    
                }
            }];
        }
        [self.parentView setNeedsUpdateConstraints];
    };
    self.teacherView.expanBlock(1);
    
//    [self.teacherView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.scrollView.mas_top);
//        make.height.mas_equalTo(self.viewWidth);
//        make.width.mas_equalTo(self.viewWidth);
//        if(count == 1){
//            make.left.equalTo(self.scrollView.mas_left);
//            self.scrollViewWidth = self.viewWidth;
//        }else{
//            make.left.equalTo(self.scrollView.mas_left).offset((count-1) * self.viewWidth + (count-1) *5);
//            self.scrollViewWidth = count * self.viewWidth+ count *5;

//        }
//    }];
    [self.scrollView layoutIfNeeded];
    NSLog(@"mvmv:%@", self.teacherView);
    
    //设置轮播图当前的显示区域
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollViewWidth , 0);
    
}
-(void)addLocalView{
    NSString *nickName = [EMLearnOption sharedOptions].nickName;
    self.localView = [[EMMemberView alloc]initWithFrame:CGRectZero role:ROLE_TYPE_STUDENT];
    [self.localView setRoleName:@"学生"];
    
    [self.localView setLocal];
    [self.localView setNickName:nickName];
    [self.localView setVideoStatus:NO];
    [self.localView setAudioStatus:NO];
    
    [self.rollDataDict setObject:self.localView forKey:[EMLearnOption sharedOptions].userName];
    [self.scrollView addSubview:self.localView];
    long count = [self.rollDataDict count];
    
    self.localView.expanBlock = ^(NSInteger tag){
        if(tag == 1){
            [self.localView removeFromSuperview];
            [self.parentView layoutSubviews];
            [self.scrollView addSubview:self.localView];
            [self.localView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.scrollView.mas_top);
                make.height.mas_equalTo(self.mas_height);
                make.width.mas_equalTo(self.viewWidth);
                if(count == 1){
                    make.left.equalTo(self.scrollView.mas_left);
                    self.scrollViewWidth = self.viewWidth;
                }else{
                    make.left.equalTo(self.scrollView.mas_left).offset((count-1) * self.viewWidth + (count-1) *5);
                    self.scrollViewWidth = count * self.viewWidth+ count *5;
                    
                }
            }];
        }else{
            [self.localView removeFromSuperview];
            [self.parentView layoutSubviews];
            [self.parentView addSubview:self.localView];
            [self.localView mas_remakeConstraints:^(MASConstraintMaker *make) {
                // make.centerX.mas_equalTo(self.parentView.mas_centerX);
                // make.centerY.mas_equalTo(self.parentView.mas_centerY);
                // make.width.mas_equalTo(400);
                // make.height.mas_equalTo(300);
                make.top.equalTo(self.scrollView.mas_top);
                make.height.mas_equalTo(self.viewWidth);
                make.width.mas_equalTo(self.viewWidth);
                if(count == 1){
                    make.left.equalTo(self.scrollView.mas_left);
                    self.scrollViewWidth = self.viewWidth;
                }else{
                    make.left.equalTo(self.scrollView.mas_left).offset((count-1) * self.viewWidth + (count-1) *5);
                    self.scrollViewWidth = count * self.viewWidth+ count *5;
                    
                }
            }];
        }
        [self.parentView setNeedsUpdateConstraints];
    };
    self.localView.expanBlock(1);
    
    [self.scrollView layoutIfNeeded];
    NSLog(@"mvmv:%@", self.localView);
    
    //设置轮播图当前的显示区域
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.contentSize = CGSizeMake(self.scrollViewWidth , 0);
    
}

#pragma mark - UIScrollViewDelegate 方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scroll x:%f scroll y:%f",scrollView.contentOffset.x,scrollView.contentOffset.y);
//    NSInteger curIndex = scrollView.contentOffset.x  / self.scrollView.frame.size.width;
//
//    if (curIndex == self.rollDataArr.count + 1) {
//
//        scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
//    }else if (curIndex == 0){
//
//        scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * self.rollDataArr.count, 0);
//    }
    
}

#pragma mark - 轻拍手势的方法
-(void)tapAction:(UITapGestureRecognizer *)tap{
//
//    if ([self.rollDataArr isKindOfClass:[NSArray class]] && (self.rollDataArr.count > 0)) {
//
//        [_delegate didSelectPicWithIndexPath:(self.scrollView.contentOffset.x / self.scrollView.frame.size.width)];
//    }else{
//
//        [_delegate didSelectPicWithIndexPath:-1];
//    }
    
}
@end
