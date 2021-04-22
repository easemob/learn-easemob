#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
    @property (nonatomic,strong) NSString *emId;
    @property (nonatomic,strong) NSString *key;
    @property (nonatomic,strong) NSString *nickName;    
    @property (nonatomic,strong) NSString *name;
    @property (nonatomic,strong) NSString *roleType;
    @property (nonatomic) BOOL isWhite;
    @property (nonatomic) BOOL isMessage;
    @property (nonatomic) BOOL isVideo;
    @property (nonatomic) BOOL isAudio;

- (instancetype)init;
@end
