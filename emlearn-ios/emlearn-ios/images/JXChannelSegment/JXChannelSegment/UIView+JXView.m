//
//  UIView+JXView.m
//  QZH
//
//  Created by JackXu on 2016/9/25.
//  Copyright © 2016年 BFMobile. All rights reserved.
//

#import "UIView+JXView.h"

@implementation UIView (JXView)

-(CGFloat)x{
    return self.frame.origin.x;
}

-(CGFloat)y{
    return self.frame.origin.y;
}

-(CGFloat)width{
    return self.frame.size.width;
}

-(CGFloat)height{
    return self.frame.size.height;
}

-(void)setX:(CGFloat)pointX{
    CGRect frame = self.frame;
    frame.origin.x = pointX;
    self.frame = frame;
}

-(void)setY:(CGFloat)pointY{
    CGRect frame = self.frame;
    frame.origin.y = pointY;
    self.frame = frame;
}

-(void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(void)setCornerWithRadii:(CGSize)cornerRadii byRoundCornorners:(UIRectCorner)corner{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:cornerRadii];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    });
}

- (void)addTarget:(id)target tapAction:(SEL)action {
    self.userInteractionEnabled = YES;
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:gesture];
}


@end
