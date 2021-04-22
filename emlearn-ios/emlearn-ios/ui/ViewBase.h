#import <UIKit/UIKit.h>
#import "../plugin/HttpUtil/HttpUtil.h"

typedef void(^EmCallBlock)(id object,NSError *error);
typedef void(^HitCallBlock)();

@interface ViewBase : UIViewController

+ (void) EMHttpPost:(NSString*) url paramaters:(NSMutableDictionary *)param callBlock:(EmCallBlock) call;
+ (void) EMHttpGet:(NSString*) url paramaters:(NSMutableDictionary *)param callBlock:(EmCallBlock) call;

+ (void) HttpPost:(NSString*) url paramaters:(NSMutableDictionary *)param headers:(NSMutableDictionary *)header callBlock:(EmCallBlock) call;
+ (void) HttpGet:(NSString*) url paramaters:(NSMutableDictionary *)param headers:(NSMutableDictionary *)header callBlock:(EmCallBlock) call;

- (void)showHint:(NSString *)hint handler:(HitCallBlock)hit;
- (void)showHint:(NSString *)hint;
@end
