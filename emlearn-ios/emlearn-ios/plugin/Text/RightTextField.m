#import "RightTextField.h"


@implementation RightTextField


-(instancetype)initWithFrame:(CGRect)frame Icon:(UIImageView *)icon{
    self=[super initWithFrame:frame];

    if (self) {
        self.rightView=icon;
     }
    return self;

}


-(CGRect)rightViewRectForBounds:(CGRect)bounds{
    CGRect iconRect=[super rightViewRectForBounds:bounds];

    iconRect.origin.x-=10;

    return iconRect;

}


@end
