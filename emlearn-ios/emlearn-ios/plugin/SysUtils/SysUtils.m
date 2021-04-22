

#import "SysUtils.h"

static UIView * sysCurView;
@interface SysUtils()

@end


@implementation SysUtils
+(UIWindow*)GetWindow{
    UIView* window = nil;
 
    if (@available(iOS 13.0, *))
    {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
        {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                window = windowScene.windows.firstObject;

                break;
            }
        }
    }else{
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

+(void)SetCurView:(UIView*)curView{
    sysCurView = curView;
}
+(UIView *)GetCurView{
    return sysCurView;
}
@end
