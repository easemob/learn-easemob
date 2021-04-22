
#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>
NS_ASSUME_NONNULL_BEGIN


@interface EMLearnOption : NSObject
typedef NS_ENUM(int,EMResolutionRate) {
    ResolutionRate_720p,
    ResolutionRate_480p,
    ResolutionRate_360p
};

@property(nonatomic,strong) NSString* SERVER_URL;
@property(nonatomic,strong) NSString* EASEMOB_SERVER_URL;
@property(nonatomic,strong) NSString* EASEMOB_ORG ;
@property(nonatomic,strong) NSString* EASEMOB_APP;
@property(nonatomic,strong) NSString* EASEMOB_APPKEY ;
@property(nonatomic,strong) NSString * roleType;
@property(nonatomic,strong) NSString * confrType;

@property (nonatomic) NSString* roomName;
@property (nonatomic) NSString* roomPswd;
@property (nonatomic) NSString* roomId;
@property (nonatomic) NSString* chatRoomId;
@property (nonatomic) NSString* whiteRoomId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *sysAccessToken;

@property (nonatomic) BOOL specifyServer;
@property (nonatomic, assign) int chatPort;
@property (nonatomic, copy) NSString *chatServer;
@property (nonatomic, copy) NSString *restServer;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *pswd;
@property (nonatomic, copy) NSString *headImage;
@property (nonatomic) BOOL openCamera;
@property (nonatomic) BOOL openMicrophone;
@property (nonatomic) BOOL openCDN;
@property (nonatomic) NSString* cdnUrl;
@property (nonatomic) EMResolutionRate resolutionrate;
@property (nonatomic) RecordExt recordExt;

@property (nonatomic) EMCallConference* conference;
@property (nonatomic) NSMutableDictionary* headImageDic;
@property (nonatomic) BOOL isRecord;
@property (nonatomic) BOOL isMerge;
@property (nonatomic) BOOL isBackCamera;
@property (nonatomic) long liveWidth;
@property (nonatomic) long liveHeight;
@property (nonatomic) BOOL muteAll;
@property (nonatomic) BOOL livePureAudio;
@property (nonatomic) BOOL isClarityFirst;
@property (nonatomic) BOOL isJoinAsAudience;

+ (instancetype)sharedOptions;

@end

NS_ASSUME_NONNULL_END

