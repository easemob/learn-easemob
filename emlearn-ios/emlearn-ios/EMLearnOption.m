
#import "EMLearnOption.h"
#import "EMDefines.h"

static EMLearnOption *sharedOptions = nil;
@implementation EMLearnOption
-(instancetype)init{
    EMLearnOption* p = [super init];
    if(p){
        [p initServerOptions];
    }
    return p;
}
- (void)initServerOptions
{
    self.SERVER_URL = @"https://cgame.bjictc.com";
    self.EASEMOB_SERVER_URL = @"https://a1.easemob.com";
    self.EASEMOB_ORG = @"1108200509113038";
    self.EASEMOB_APP = @"chatapp";
    self.EASEMOB_APPKEY = @"1108200509113038#chatapp";
    self.roleType = ROLE_TYPE_TEACHER;
    self.confrType = CONFR_TYPE_ONE;
    self.whiteRoomId = @"";
    
    self.specifyServer = NO;
    self.chatServer = @"116.85.43.118";
    self.chatPort = 6717;
    self.restServer = @"a1-hsb.easemob.com";
    self.openCamera = YES;
    self.openMicrophone = YES;
    self.resolutionrate = ResolutionRate_480p;
    self.nickName = @"";
    self.cdnUrl = @"";
    self.isMerge = NO;
    self.isRecord = NO;
    self.isBackCamera = NO;
    self.liveWidth = 640;
    self.liveHeight = 480;
    self.livePureAudio = NO;
    self.recordExt = RecordExtAUTO;
    self.isClarityFirst = NO;
    self.isJoinAsAudience = NO;
}
+ (instancetype)sharedOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOptions = [[EMLearnOption alloc] init];;
    });
    
    return sharedOptions;
}
@end

