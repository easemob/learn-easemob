#import "ViewBase.h"

typedef void(^GetNickNameBlock)(NSString* nickName);

@interface ServerCall : NSObject

+(void)GetNickName:(NSString*)userName callBlock:(GetNickNameBlock)call;

+(void)OperRole:(NSString *)userName role:(NSString *)inrole;
@end
