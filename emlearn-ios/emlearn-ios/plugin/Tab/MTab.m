//
//  JXPageView.m
//  JXChannelSegment
//
//  Created by JackXu on 16/9/16.
//  Copyright © 2016年 BFMobile. All rights reserved.
//

#import "MTab.h"
#import <Masonry.h>

@interface MTab()

    @property (nonatomic,strong) NSMutableArray *itemsArray;
    @property(nonatomic,assign) BOOL isSetTitle;
    @property(nonatomic,assign) BOOL isUp;
    @property (nonatomic,strong) UIFont *textFont;
    @property (nonatomic,assign) NSInteger selectedIndex;
    @property(nonatomic,strong) UIScrollView *titleScrollview;
    @property(nonatomic,strong) UIView *planeScrollview;
    @property(nonatomic,strong) UIView *midPlaneView;
@end


@implementation MTab

- (instancetype)init:(BOOL)isUp{
    if (self = [super init]) {
        _titleScrollview = [[UIScrollView alloc] init];
        _titleScrollview.pagingEnabled = YES;
        _titleScrollview.showsHorizontalScrollIndicator = NO;
        [self addSubview:_titleScrollview];
        _isSetTitle = NO;


        _planeScrollview = [[UIView alloc] init];
        _planeScrollview.backgroundColor = UIColor.yellowColor;
//        _planeScrollview.pagingEnabled = YES;
//        _planeScrollview.showsHorizontalScrollIndicator = NO;
        [self addSubview:_planeScrollview];
        self.isUp = isUp;
        self.midPlaneView = NULL;
        
    }
    return self;
}
-(void)setupView{
    if(self.isUp){
        [_planeScrollview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(self).multipliedBy(0.9);
            make.left.equalTo(self);
            make.bottom.equalTo(self);
        }];
        [_titleScrollview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(self).multipliedBy(0.1);
            make.left.equalTo(self);
            make.bottom.equalTo(_planeScrollview.mas_top);
        }];
    }else{
        [_planeScrollview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(self).multipliedBy(0.9);
            make.left.equalTo(self);
            make.top.equalTo(self);
        }];
        [_titleScrollview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(self).multipliedBy(0.1);
            make.left.equalTo(self);
            make.top.equalTo(_planeScrollview.mas_bottom);
        }];
    }
}

-(UIFont*)textFont{
    return _textFont?:[UIFont systemFontOfSize:16];
}

- (void)setTitle:(NSArray*)array{
    _isSetTitle = YES;
    UIButton *oldButton = NULL;
    for (int i = 0; i < array.count; i++) {
        NSString *string = [array objectAtIndex:i];
        UIButton *button = [[UIButton alloc] init];
        button.tag = 1000 + i;
        [button.titleLabel setFont:self.textFont];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [button setTitle:string forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickSegmentButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleScrollview addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@70);
            make.height.equalTo(self.titleScrollview);
            if(oldButton != NULL){
                make.left.equalTo(oldButton.mas_right);
            }else{
                make.left.equalTo(self.titleScrollview);
            }
            make.top.equalTo(self.titleScrollview);
        }];
        if (i == 0) {
            [button setSelected:YES];
            _selectedIndex = 0;
            [self didChangeToIndex:i];
        }
        oldButton = button;
    }
}

- (void)clickSegmentButton:(UIButton*)selectedButton{
    UIButton *oldSelectButton = (UIButton*)[_titleScrollview viewWithTag:(1000 + _selectedIndex)];
    [oldSelectButton setSelected:NO];
    
    [selectedButton setSelected:YES];
    _selectedIndex = selectedButton.tag - 1000;
    //移除原始子元素
    if(self.midPlaneView != NULL){
        [self.midPlaneView removeFromSuperview];
    }
    
    self.midPlaneView= [_delegate changeView:_selectedIndex];
    [self.planeScrollview addSubview:self.midPlaneView];
    [self.midPlaneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(self);
        make.left.equalTo(self);
        make.top.equalTo(self.titleScrollview.mas_bottom);
    }];
    
}

- (void)didChangeToIndex:(NSInteger)index{
    
    UIButton *selectedButton = [self.titleScrollview viewWithTag:(1000 + index)];
    [self clickSegmentButton:selectedButton];
    
}

@end
