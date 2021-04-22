#import "ServerCall.h"
#import "EMLearnOption.h"

@implementation ServerCall

+(void)GetNickName:(NSString *)userName callBlock:(GetNickNameBlock)call{
    NSArray *names = [userName componentsSeparatedByString:@"_"];
    NSString *rname = @"";
    if([names count] >1){
        rname = names[1];
    }else{
        rname = names[0];
    }
    NSMutableDictionary *param =
    [NSMutableDictionary dictionaryWithDictionary:@{
        @"confrKey":[EMLearnOption sharedOptions].conference.confId,
        @"userName":rname,
    }];
    NSMutableDictionary *header =
    [NSMutableDictionary dictionaryWithDictionary:@{
        @"Authorization":[EMLearnOption sharedOptions].sysAccessToken,
    }];
    [ViewBase HttpGet:@"User/GetNickName" paramaters:param headers:header callBlock:^void (id object,NSError *error){
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *dictionary = (NSDictionary *)object;
            NSString *code = [dictionary objectForKey:@"code"];
            if([code isEqual: @"1"]){
                NSString * nickName = (NSString *)[dictionary objectForKey:@"data"];
                call(nickName);
                
            }else{
                NSLog(@"获取昵称失败");
            }
        }else{
            NSLog(@"获取昵称失败");
        }
    }];
}

+(void)OperRole:(NSString *)userName role:(NSString *)inrole{
    NSArray *names = [userName componentsSeparatedByString:@"_"];
    NSString *rname = @"";
    if([names count] >1){
        rname = names[1];
    }else{
        rname = names[0];
    }
    NSMutableDictionary *param =
    [NSMutableDictionary dictionaryWithDictionary:@{
        @"confrId":[EMLearnOption sharedOptions].conference.confId,
        @"userName":rname,
    }];
    if([inrole  isEqual: @"7"]){
        param[@"role"] = @7;
    }else if([inrole  isEqual: @"3"]){
        param[@"role"] = @3;
    }
    NSMutableDictionary *header =
    [NSMutableDictionary dictionaryWithDictionary:@{
        @"Authorization":[EMLearnOption sharedOptions].sysAccessToken,
    }];
    [ViewBase HttpPost:@"Conference/Role" paramaters:param headers:header callBlock:^void (id object,NSError *error){
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *dictionary = (NSDictionary *)object;
            NSString *code = [dictionary objectForKey:@"code"];
            if([code isEqual: @"1"]){
                [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMLearnOption sharedOptions].conference.confId memberName:@"adminadmin" role:EMConferenceRoleAudience completion:^(EMError *aError) {
                    if(aError){
                        NSLog(@"change member:%@",aError.errorDescription);
                        return;
                    }
                    NSLog(@"change member pass");
                    [[[EMClient sharedClient] conferenceManager] kickMemberWithConfId:[EMLearnOption sharedOptions].conference.confId memberNames:[[NSArray alloc] initWithObjects:@"adminadmin", nil] completion:^(EMError *aError) {
                        if(aError){
                            NSLog(@"kick member:%@",aError.errorDescription);
                            return;
                        }
                        NSLog(@"kick member pass");
                    }];
                }];
                
            }else{
                NSLog(@"设置权限失败");
            }
        }else{
            NSLog(@"设置权限失败");
        }
    }];
}
@end
