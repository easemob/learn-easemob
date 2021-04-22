#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>

typedef enum {
    StreamStatusNormal = 0,
    StreamStatusConnecting,
    StreamStatusConnected,
    StreamStatusTalking,
} StreamStatus;

typedef void(^MemberExpanCallBlock)(NSInteger tag);

@interface EMMemberView : UIView
    @property (nonatomic, strong) EMCallStream *stream;

    @property (nonatomic, strong) UIView *streamView;

    @property (nonatomic, strong) UIImageView *bgView;

    @property (nonatomic, strong) UIImageView *expanView;

    @property (nonatomic, strong) UIImageView *audioStatusView;

    @property (nonatomic, strong) UIImageView *videoStatusView;

    @property (nonatomic, strong) UILabel* roleTypeLable;

    @property (nonatomic, strong) UILabel *nickNameLabel;

    @property (nonatomic, strong) UIView *upView;

    @property (nonatomic, strong) UIView *downView;

    @property (nonatomic,copy) MemberExpanCallBlock expanBlock;

    @property (nonatomic) BOOL audioStatus;

    @property (nonatomic) BOOL videoStatus;

    @property (nonatomic) BOOL isAdmin;

    @property (nonatomic) BOOL isLocal;

    @property (nonatomic) StreamStatus status;

    @property (nonatomic) int imageCount;

    @property (nonatomic) NSTimer *timeTimer;
    
    @property (nonatomic) NSString *userName;

    @property (nonatomic) NSMutableDictionary *userDictionary;

- (void)setDisplayView:(UIView *)displayView;
-(void)setStream:(EMCallStream *)aStream;
- (void)setVideoStatus:(BOOL)videoStatus;
- (void)setAudioStatus:(BOOL)audioStatus;
-(void)setNickName:(NSString *)nickName;
-(void)setRoleName:(NSString *)roleName;
-(void)setMemberId:(NSString *)memberId;
-(void)setLocal;
-(BOOL)isSetStream;
- (instancetype)initWithFrame:(CGRect)frame role:(NSString *)roleType;
@end
