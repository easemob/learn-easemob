#import "HttpUtil.h"

@implementation HttpUtil
//实现GET请求方法

+ (void)HttpGet:(NSString *)urlString 
    paramaters:(NSMutableDictionary *)param
    headers:(NSMutableDictionary *)header
    callBlock:(CallBlock)call{
    NSMutableString *strM = [[NSMutableString alloc] init];
//遍历参数字典将value和key拼装在一起
    [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,
                                                    id  _Nonnull obj, BOOL * _Nonnull stop) {
           // 服务器接收参数的 key 值.
        NSString *paramaterKey = key;
             // 参数内容
        NSString *paramaterValue = obj;
        // appendFormat :可变字符串直接拼接的方法!
        [strM appendFormat:@"%@=%@&",paramaterKey,paramaterValue];
    }];
    urlString = [NSString stringWithFormat:@"%@?%@",urlString,strM];
    // 截取字符串的方法!
    urlString = [urlString substringToIndex:urlString.length - 1];
    NSLog(@"urlString:%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    if (header != nil){
            [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,
                                                            id  _Nonnull obj, BOOL * _Nonnull stop) {
                   // 服务器接收参数的 key 值.
                NSString *paramaterKey = key;
                     // 参数内容
                NSString *paramaterValue = obj;
                [request setValue:paramaterValue forHTTPHeaderField:paramaterKey];
            }];
    }
    // 2. 发送网络请求.
    // completionHandler: 说明网络请求完成!
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        call((NSString *)data,error);
        // 网络请求成功:
        // if (data && !error) {
        //     // 查看 data 是否是 JSON 数据.
        //     // JSON 解析.
        //     id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        //     // 如果 obj 能够解析,说明就是 JSON
        //     if (!obj) {
        //         obj = data;
        //     }
        //     if(call){
        //         call(obj,NULL);
        //     }
        //     // 成功回调
        //     // dispatch_async(dispatch_get_main_queue(), ^{
        //     //        if (success) {
        //     //         success(obj,response);
        //     //     }
        //     // });
        //  }else {//失败
        //     if (call) {
        //         call(NULL,error);
        //     }
        // }
    }] resume];
}

+ (void)HttpPost:(NSString *)urlString 
    paramaters:(NSMutableDictionary *)param
    headers:(NSMutableDictionary *)header
    callBlock:(CallBlock)call{
    NSMutableString *strM = [[NSMutableString alloc] init];
//遍历参数字典将value和key拼装在一起
//    [paramaters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,
//                                                    id  _Nonnull obj, BOOL * _Nonnull stop) {
//           // 服务器接收参数的 key 值.
//        NSString *paramaterKey = key;
//             // 参数内容
//        NSString *paramaterValue = obj;
//        // appendFormat :可变字符串直接拼接的方法!
//        [strM appendFormat:@"%@=%@&",paramaterKey,paramaterValue];
//    }];
    NSData *data=[NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSString *body=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    // 截取字符串的方法!
    NSLog(@"urlString:%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (header != nil){
            [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,
                                                            id  _Nonnull obj, BOOL * _Nonnull stop) {
                   // 服务器接收参数的 key 值.
                NSString *paramaterKey = key;
                     // 参数内容
                NSString *paramaterValue = obj;
                [request setValue:paramaterValue forHTTPHeaderField:paramaterKey];
            }];
    }
    request.HTTPMethod = @"POST";
//    NSString *body = [strM substringToIndex:strM.length - 1];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = bodyData;
    // 2. 发送网络请求.
    // completionHandler: 说明网络请求完成!
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        call((NSString *)data,error);
        // 网络请求成功:
        // if (data && !error) {
        //     // 查看 data 是否是 JSON 数据.
        //     // JSON 解析.
        //     id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        //     // 如果 obj 能够解析,说明就是 JSON
        //     if (!obj) {
        //         obj = data;
        //     }
        //     if(call){
        //         call(obj,NULL);
        //     }
        //     // 成功回调
        //     // dispatch_async(dispatch_get_main_queue(), ^{
        //     //        if (success) {
        //     //         success(obj,response);
        //     //     }
        //     // });
        //  }else {//失败
        //     // if (fail) {
        //     //     fail(error);
        //     // }
        //     if (call) {
        //         call(NULL,error);
        //     }
        // }
    }] resume];
}
@end
