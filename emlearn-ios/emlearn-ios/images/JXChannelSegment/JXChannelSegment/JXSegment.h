//
//  JXSegment.h
//  JXChannelSegment
//
//  Created by JackXu on 16/9/16.
//  Copyright © 2016年 BFMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JXSegment;

@protocol JXSegmentDelegate <NSObject>

- (void)JXSegment:(JXSegment*)segment didSelectIndex:(NSInteger)index;

@end


@interface JXSegment : UIControl

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIFont *textFont;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,weak) id<JXSegmentDelegate> delegate;
@property(nonatomic,assign) BOOL isOneChannelPage;

- (void)updateChannels:(NSArray*)array;
- (void)didChengeToIndex:(NSInteger)index;

@end
