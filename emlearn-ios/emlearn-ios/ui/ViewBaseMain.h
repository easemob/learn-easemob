#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>
#import "ViewBase.h"
#import "ViewBaseMainTop.h"
#import "WhiteBoardView.h"
#import "CharView.h"
#import "MTab.h"
#import "EMMemberView.h"
#import "TableView.h"
#import "UserInfo.h"
#import "StreamInfo.h"

@interface ViewBaseMain : ViewBase<EMConferenceManagerDelegate,EMChatroomManagerDelegate>

@property (nonatomic, strong) NSString *localStreamId;

@property (nonatomic, strong) NSMutableDictionary *membersDict;

@property (nonatomic) EMConferenceRole role;

@property (nonatomic) ViewBaseMainTop* topViewMain;

@property (nonatomic) WhiteBoardView *whiteBoardView;

@property (nonatomic, strong) UIView *buttonGroup;

//@property (nonatomic) UIView *midView;
//
//@property (nonatomic, strong) MTab *midTab;

@property (nonatomic, strong)UIImageView *chatImgBut;

@property (nonatomic, strong)UIImageView *authImgBut;

//@property (nonatomic) UIView *moveMidView;

@property (nonatomic, strong) CharView *charView;

@property (nonatomic, strong) TableView *tableView;

@property (nonatomic) EMMemberView *remoteDesktopView;

@property (nonatomic) NSInteger ScreenHeight;
@property (nonatomic) NSInteger ScreenWidth;
@property (nonatomic) NSInteger TopViewHeight;
@property (nonatomic) NSInteger WhiteBoardViewWidth;
@property (nonatomic) NSInteger GroupMemberViewWidth;
@property (nonatomic) NSInteger GroupMemberViewHeight;
@property (nonatomic) NSInteger MemberViewHeight;

@property (nonatomic, strong) NSMutableDictionary *userDictionary;
@property (nonatomic, strong) NSMutableDictionary *streamDict;
- (instancetype)initWithConfence;

- (void)_subStream:(EMCallStream *)aStream;

- (void)_removeStream:(StreamInfo *)aStream;
-(void)_setupWhiteBoard;
-(void)_setupCharView;
- (void)_mute:(BOOL)isMute;
-(void)leaveAction;
-(void)_memberChange:(UserInfo *)u;
@end


