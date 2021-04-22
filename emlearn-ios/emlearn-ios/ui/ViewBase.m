#import "ViewBase.h"
#import "EMLearnOption.h"
#import "../plugin/AlertWin/AlertWin.h"
#import "SysUtils.h"
@interface ViewBase ()

@end


@implementation ViewBase

+(NSString*)GetConfigVal:(NSString *)val{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePath];
    NSString *ret = [infoDict objectForKey:val];
    return ret;
}

- (void)viewDidLoad {
    [SysUtils SetCurView:self.view];

}



- (void)showHint:(NSString *)hint handler:(HitCallBlock)hit
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:hint preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(hit != NULL){
                hit();
            }
        }]];
        // 弹出对话框
        [self presentViewController:alert animated:true completion:nil];
    });
    
    
}
- (void)showHint:(NSString *)hint
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:hint preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        // 弹出对话框
        [self presentViewController:alert animated:true completion:nil];
    });
    
    
}

+ (void) EMHttpPost:(NSString*) url paramaters:(NSMutableDictionary *)param callBlock:(EmCallBlock) call {
    NSMutableString *strM = [[NSMutableString alloc] init];
    [strM appendFormat:@"%@/%@/%@/%@",
        [EMLearnOption sharedOptions].EASEMOB_SERVER_URL,[EMLearnOption sharedOptions].EASEMOB_ORG,[EMLearnOption sharedOptions].EASEMOB_APP,url];
    void (^block)(NSString *retStr,NSError *error) = ^(NSString *retStr,NSError *error) {
        if (retStr && !error) {
            id obj = [NSJSONSerialization JSONObjectWithData:retStr options:0 error:NULL];
            if (!obj) {
                obj = retStr;
            }
            if(call){
                call(obj,NULL);
            }
        }
    };
    [HttpUtil HttpPost:strM paramaters:param headers:nil callBlock:block];
}

+ (void) EMHttpGet:(NSString*) url paramaters:(NSMutableDictionary *)param callBlock:(EmCallBlock) call{
    NSMutableString *strM = [[NSMutableString alloc] init];
    [strM appendFormat:@"%@/%@/%@/%@",
        [EMLearnOption sharedOptions].EASEMOB_SERVER_URL,[EMLearnOption sharedOptions].EASEMOB_ORG,[EMLearnOption sharedOptions].EASEMOB_APP,url];
    void (^block)(NSString *retStr,NSError *error) = ^(NSString *retStr,NSError *error) {
        if (retStr && !error) {
            id obj = [NSJSONSerialization JSONObjectWithData:retStr options:0 error:NULL];
            if (!obj) {
                obj = retStr;
            }
            if(call){
                call(obj,NULL);
            }
        }
    };
    [HttpUtil HttpGet:strM paramaters:param headers:nil callBlock:block];
}

+ (void) HttpPost:(NSString*) url
          paramaters:(NSMutableDictionary *)param
          headers:(NSMutableDictionary *)header
          callBlock:(EmCallBlock) call {
    NSMutableString *strM = [[NSMutableString alloc] init];
    [strM appendFormat:@"%@/%@",
        [EMLearnOption sharedOptions].SERVER_URL,url];
    void (^block)(NSString *retStr,NSError *error) = ^(NSString *retStr,NSError *error) {
        if (retStr && !error) {
            id obj = [NSJSONSerialization JSONObjectWithData:retStr options:0 error:NULL];
            if (!obj) {
                obj = retStr;
            }
            if(call){
                call(obj,NULL);
            }
        }
    };
    [HttpUtil HttpPost:strM paramaters:param headers:header callBlock:block];
}

+ (void) HttpGet:(NSString*) url
      paramaters:(NSMutableDictionary *)param
         headers:(NSMutableDictionary *)header
       callBlock:(EmCallBlock) call{
    NSMutableString *strM = [[NSMutableString alloc] init];
    [strM appendFormat:@"%@/%@",
        [EMLearnOption sharedOptions].SERVER_URL,url];
    void (^block)(NSString *retStr,NSError *error) = ^(NSString *retStr,NSError *error) {
        if (retStr && !error) {
            id obj = [NSJSONSerialization JSONObjectWithData:retStr options:0 error:NULL];
            if (!obj) {
                obj = retStr;
            }
            if(call){
                call(obj,NULL);
            }
        }
    };
    [HttpUtil HttpGet:strM paramaters:param headers:header callBlock:block];
}

@end

