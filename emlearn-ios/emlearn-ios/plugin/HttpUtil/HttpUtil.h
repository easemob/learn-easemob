#import <Foundation/Foundation.h>

typedef void(^CallBlock)(NSString *retStr,NSError *error);

@interface HttpUtil : NSObject

+(void)HttpGet:(NSString *)urlString
    paramaters:(NSMutableDictionary *)param
    headers:(NSMutableDictionary *)header
    callBlock:(CallBlock)call;

+(void)HttpPost:(NSString *)urlString 
    paramaters:(NSMutableDictionary *)param
    headers:(NSMutableDictionary *)header
    callBlock:(CallBlock)call;
@end
