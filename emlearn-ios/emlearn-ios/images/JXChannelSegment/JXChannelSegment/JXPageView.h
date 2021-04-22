//
//  JXPageView.h
//  JXChannelSegment
//
//  Created by JackXu on 16/9/16.
//  Copyright © 2016年 BFMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXPageView;

@protocol JXPageViewDataSource <NSObject>

- (NSInteger)numberOfItemInJXPageView:(JXPageView*)pageView;
- (UIView*)pageView:(JXPageView*)pageView viewAtIndex:(NSInteger)index;

@end

@protocol JXPageViewDelegate <NSObject>

- (void)didScrollToIndex:(NSInteger)index;

@end


@interface JXPageView : UIView

@property(nonatomic,strong) UIScrollView *scrollview;
@property(nonatomic,assign) NSInteger numberOfItems;
@property(nonatomic,assign) BOOL scrollAnimation;
@property(nonatomic,weak) id<JXPageViewDataSource> datasource;
@property(nonatomic,weak) id<JXPageViewDelegate> delegate;

- (void)reloadData;
- (void)changeToItemAtIndex:(NSInteger)index;

@end
