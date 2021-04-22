//
//  UIView+JXView.h
//  QZH
//
//  Created by JackXu on 2016/9/25.
//  Copyright © 2016年 BFMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JXView)

/**
 *  设置圆角
 **/
-(void)setCornerWithRadii:(CGSize)cornerRadii byRoundCornorners:(UIRectCorner)corner;

/**
 *  添加点击事件
 **/
- (void)addTarget:(id)target tapAction:(SEL)action ;

-(CGFloat)x;
-(CGFloat)y;
-(CGFloat)width;
-(CGFloat)height;
-(void)setX:(CGFloat)pointX;
-(void)setY:(CGFloat)pointY;
-(void)setWidth:(CGFloat)width;
-(void)setHeight:(CGFloat)height;

@end
