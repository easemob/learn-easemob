#import "ViewBaseMain.h"
#import "EMLearnOption.h"
#import <Masonry.h>
#import "ViewLogin.h"
#import "EMDefines.h"
#import "CharView.h"
#import "MTab.h"
#import "TableView.h"
#import "UserInfo.h"
#import "ServerCall.h"

// #import "IQKeyboardManager.h"
@interface ViewBaseMain ()<MTabDelegate,EMConferenceManagerDelegate,EMChatroomManagerDelegate>
    @property (nonatomic, strong) NSString *desktopStreamId;
    
    @property (nonatomic, strong) NSString *remoteDesktopStreamId;


    @property (nonatomic) UIImageView *shareBut;
@end


@implementation ViewBaseMain



- (instancetype)initWithConfence
{
    self = [super init];
    if (self) {
        self.membersDict = [NSMutableDictionary dictionary];
        EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
        options.isClarityFirst = [EMLearnOption sharedOptions].isClarityFirst;
        _userDictionary = [[NSMutableDictionary alloc] init];
        _streamDict = [[NSMutableDictionary alloc] init];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    return self;
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}
// - (void) viewWillAppear: (BOOL)animated {
//          //打开键盘事件相应
//           [IQKeyboardManager sharedManager].enable = YES;
// }
- (void)viewDidLoad {
    [super viewDidLoad];
    _localStreamId = NULL;
    NSInteger screenHeight = SCREEN_HEIGHT;
    NSInteger screenWidth = SCREEN_WIDTH;
    if(screenHeight > screenWidth){
        self.ScreenWidth = screenHeight;
        self.ScreenHeight = screenWidth;
    }else{
        self.ScreenWidth = screenWidth;
        self.ScreenHeight = screenHeight;
    }
    self.TopViewHeight = self.ScreenHeight * 0.1;
    self.GroupMemberViewHeight = self.ScreenHeight * 0.9;
    
    self.remoteDesktopView = [[EMMemberView alloc]initWithFrame:CGRectZero];
    self.topViewMain = [[ViewBaseMainTop alloc] initWithConfVC:self];
    [self.view addSubview:self.topViewMain.view];
    [self.topViewMain.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
//        make.height.equalTo(self.view).multipliedBy(0.1);
        make.height.mas_equalTo(self.TopViewHeight);
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    [self joinWhiteBoard];
    
    
    [[[EMClient sharedClient] conferenceManager] addDelegate:self delegateQueue:nil];
    [[[EMClient sharedClient] conferenceManager] startMonitorSpeaker:[EMLearnOption sharedOptions].conference timeInterval:2 completion:^(EMError *aError) {
        
    }];
    [[[EMClient sharedClient] roomManager] addDelegate:self delegateQueue:nil];
    
    [[[EMClient sharedClient] conferenceManager] getConference:[EMLearnOption sharedOptions].conference.confId password:[EMLearnOption sharedOptions].roomPswd completion:^(EMCallConference *aCall, EMError *aError) {
        [EMLearnOption sharedOptions].conference.adminIds = [aCall.adminIds copy];
    }];
    self.charView = [[CharView alloc] init];
    self.tableView = [[TableView alloc] init: _userDictionary];
    NSLog(@"ui:%@",self.view);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}
-(void)orientationDidChange{
    
}
-(void)joinChatroom{
    
    NSString * chatRoomId = [EMLearnOption sharedOptions].chatRoomId;
    [[EMClient sharedClient].roomManager joinChatroom:chatRoomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (aError) {
            [self showHint:@"加入聊天室失败"];
            [self leaveAction];
        } else {
            [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
            dispatch_async(dispatch_get_main_queue(), ^(void){
//                [self createMidView];
//                [self.view addSubview:self.midView];
                [self _setupCharView];
                [self joinConfence];
            });
        }
        
    }];
}

-(void)joinWhiteBoard{
    NSString * roomName = [EMLearnOption sharedOptions].roomName;
    NSString * roomPswd = [EMLearnOption sharedOptions].roomPswd;
    [[EMClient sharedClient].conferenceManager joinWhiteboardRoomWithName:roomName username:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken roomPassword:roomPswd completion:^(EMWhiteboard *aWhiteboard, EMError *aError) {
        if (!aError) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                self.whiteBoardView = [[WhiteBoardView alloc] initWithWBUrl:aWhiteboard];
                [self.view addSubview:self.whiteBoardView.view];
                [self _setupWhiteBoard];
                [self createButtonGroup];
            });
            [EMLearnOption sharedOptions].whiteRoomId =aWhiteboard.roomId;
            [self joinChatroom];
        } else {
            if (aError.code == EMErrorCallRoomNotExist) {
                if([EMLearnOption sharedOptions].conference.role == EMConferenceRoleAudience) {
                    [self showHint:@"观众不能创建白板" handler:NULL];
                    [self leaveAction];
                    return;
                }
                [[EMClient sharedClient].conferenceManager createWhiteboardRoomWithUsername:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken roomName:roomName roomPassword:roomPswd interact:YES completion:^(EMWhiteboard *aWhiteboard, EMError *aError) {
                    if (!aError) {
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            self.whiteBoardView = [[WhiteBoardView alloc] initWithWBUrl:aWhiteboard];
                            [self.view addSubview:self.whiteBoardView.view];
                            [self _setupWhiteBoard];
                            [self createButtonGroup];
                        });
                        [EMLearnOption sharedOptions].whiteRoomId =aWhiteboard.roomId;
                        [self joinChatroom];
                    } else {
                        NSLog(@"---err create whiteboard:%@",aError.errorDescription);
                        [self showHint:aError.errorDescription handler:^{
                            [self leaveAction];
//                            ViewLogin* loginView = [[ViewLogin alloc] init];
//                            loginView.modalPresentationStyle = 0;
//                            [self presentViewController:loginView animated:YES completion:nil];
                        }];
                        return;
                    }
                }];
            } else {
                NSLog(@"---err join whiteboard:%@",aError.errorDescription);
                [self showHint:aError.errorDescription handler:^{
                    [self leaveAction];
//                    ViewLogin* loginView = [[ViewLogin alloc] init];
//                    loginView.modalPresentationStyle = 0;
//                    [self presentViewController:loginView animated:YES completion:nil];
                }];
                return;
            }
        }

        
    }];
}

-(void)joinConfence{
    if(self){
        __weak typeof(self) weakself = self;
        EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
        pubConfig.streamName = [EMClient sharedClient].currentUsername;
        pubConfig.enableVideo = YES;
        pubConfig.isMute = NO;
        EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
        pubConfig.maxAudioKbps = (int)options.maxAudioKbps;
        switch ([EMLearnOption sharedOptions].resolutionrate) {
            case ResolutionRate_720p:
                pubConfig.videoResolution = EMCallVideoResolution1280_720;
                break;
            case ResolutionRate_360p:
                pubConfig.videoResolution = EMCallVideoResolution352_288;
                break;
            case ResolutionRate_480p:
                pubConfig.videoResolution = EMCallVideoResolution640_480;
                break;
            default:
                pubConfig.videoResolution = options.videoResolution;
                break;
        }

        pubConfig.isBackCamera = NO;
        EMCallLocalView *localView = [[EMCallLocalView alloc] init];
        //视频通话页面缩放方式
        localView.scaleMode = EMCallViewScaleModeAspectFill;//EMCallViewScaleModeAspectFit;
        //显示本地视频的页面
        pubConfig.localView = localView;
        EMMemberView *localMemberView = [self _getLocalMemberView];
        [localMemberView setNickName:[EMLearnOption sharedOptions].nickName];
        [localMemberView setVideoStatus:NO];
        [localMemberView setAudioStatus:NO];
//        [[EMClient sharedClient].conferenceManager updateConference:[EMLearnOption sharedOptions].conference enableVideo:YES];
//        [[EMClient sharedClient].conferenceManager updateConference:[EMLearnOption sharedOptions].conference isMute:YES];
        void(^block)(NSString *aPubStreamId, EMError *aError) = ^(NSString *aPubStreamId, EMError *aError){
            if (aError) {
                NSLog(@"---err pubilsh:%@",aError.errorDescription);
                [self showHint:aError.errorDescription handler:^{
                    ViewLogin* loginView = [[ViewLogin alloc] init];
                    loginView.modalPresentationStyle = 0;
                    [self presentViewController:loginView animated:YES completion:nil];
                }];
                return;
            }
            self.localStreamId = aPubStreamId;
            
            [localMemberView setVideoStatus:YES];
            [localMemberView setAudioStatus:YES];
            [localMemberView setDisplayView:localView];
            [self _loadFinish];
        };
        pubConfig.ext = [NSString stringWithFormat:@"{\"nickName\":\"%@\"}",[EMLearnOption sharedOptions].nickName];
        [[EMClient sharedClient].conferenceManager publishConference:[EMLearnOption sharedOptions].conference streamParam:pubConfig completion:block];
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker
                                error:nil];
            [audioSession setActive:YES error:nil];
            
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if(authStatus == AVAuthorizationStatusAuthorized) {
                NSLog(@"Granted access to %@", mediaType);
            } else if(authStatus == AVAuthorizationStatusDenied){
                NSLog(@"denied access to %@", mediaType);
            } else if(authStatus == AVAuthorizationStatusRestricted){
                NSLog(@"restricted access to %@", mediaType);
              // restricted, normally won't happen
            } else if(authStatus == AVAuthorizationStatusNotDetermined){
              // not determined?!
              [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if(granted){
                  NSLog(@"Granted access to %@", mediaType);
                } else {
                  NSLog(@"Not granted access to %@", mediaType);
                }
              }];
            }
        });
    }
}



-(void)createButtonGroup{
    self.buttonGroup= [[UIView alloc] init];
    self.buttonGroup.layer.cornerRadius = 8;
    self.buttonGroup.layer.masksToBounds = NO;
    self.buttonGroup.layer.shadowColor = [UIColor blackColor].CGColor;
    self.buttonGroup.layer.shadowOpacity = 0.8f;
    self.buttonGroup.layer.shadowRadius = 4.f;
    self.buttonGroup.layer.shadowOffset = CGSizeMake(4,4);

//    self.buttonGroup.layer.borderWidth = 1;
//    self.buttonGroup.layer.borderColor =[ [UIColor grayColor] CGColor];
    
    self.buttonGroup.backgroundColor = UIColor.whiteColor;
    
    UIImageView *whiteBut = [[UIImageView alloc] initWithFrame:CGRectZero];
    whiteBut.tag = 1;
//    whiteBut.backgroundColor =kColor_LightGray;
    whiteBut.image = [UIImage imageNamed:@"button_white_on"];
    
    whiteBut.userInteractionEnabled=YES;
    whiteBut.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *whiteButImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(whiteAction:)];
    [whiteBut addGestureRecognizer:whiteButImageTap];
    [self.buttonGroup addSubview:whiteBut];
    [whiteBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.buttonGroup).multipliedBy(0.4);
        make.left.equalTo(self.buttonGroup).offset(5);
        make.top.equalTo(self.buttonGroup).offset(5);
        make.bottom.equalTo(self.buttonGroup.mas_bottom).offset(-5);
    }];

    self.shareBut = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.shareBut.tag = 0;
//    shareBut.backgroundColor =kColor_LightGray;
    self.shareBut.image = [UIImage imageNamed:@"button_share_off"];
    
    self.shareBut.userInteractionEnabled=YES;
    self.shareBut.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *shareButImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sharedAction:)];
    [self.shareBut addGestureRecognizer:shareButImageTap];
    [self.buttonGroup addSubview:self.shareBut];
    [self.shareBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.buttonGroup).multipliedBy(0.4);
        make.left.equalTo(whiteBut.mas_right).offset(3);
        make.top.equalTo(self.buttonGroup).offset(5);
        make.bottom.equalTo(self.buttonGroup.mas_bottom).offset(-5);
    }];

//    UIImageView *recordBut = [[UIImageView alloc] initWithFrame:CGRectZero];
//    recordBut.tag = 0;
//    recordBut.backgroundColor =kColor_LightGray;
//    recordBut.image = [UIImage imageNamed:@"button_record_off"];
//
//    recordBut.userInteractionEnabled=YES;
//    recordBut.contentMode = UIViewContentModeScaleAspectFit;
//    UITapGestureRecognizer *recordButImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recordAction:)];
//    [recordBut addGestureRecognizer:recordButImageTap];
//    [self.buttonGroup addSubview:recordBut];
//    [recordBut mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(self.buttonGroup).multipliedBy(0.25);
//        make.left.equalTo(shareBut.mas_right).offset(3);
//        make.top.equalTo(self.buttonGroup).offset(3);
//    }];
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_TEACHER]){
        [self.view addSubview:self.buttonGroup];
    }
    
    
    
    //    [self.view bringSubviewToFront:buttonGroup];
    
}
-(void)recordAction:(UIGestureRecognizer *)sender{
    if(sender.view.tag == 1){
        sender.view.tag = 0;
        ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_record_off"];
    }else{
        sender.view.tag = 1;
        ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_record_on"];
    }
}

-(void)sharedAction:(UIGestureRecognizer *)sender{
    if((self.whiteBoardView == nil || [self.desktopStreamId length] > 0) && sender.view.tag == 0){
        [self showHint:@"正在进行共享任务，不能再共享桌面"];
        return;
    }
    if(sender.view.tag == 1){
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [[[EMClient sharedClient] conferenceManager] unpublishConference:[EMLearnOption sharedOptions].conference streamId:weakself.desktopStreamId completion:^(EMError *aError) {
                if(aError){
                    NSLog(@"---err share:%@",aError.errorDescription);
                    [self showHint:@"取消共享桌面流失败，请重试"];
                    return ;
                }
                sender.view.tag = 0;
                ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_share_off"];
                weakself.desktopStreamId = @"";
            }];
        });
    }else{
        [self publishSharedDesktop:sender];
        
        // if (@available(iOS 13.0, *)){
        //     UIControlEvents event = UIControlEventTouchDown;
        //     if(@available(iOS 13.0, *)) {
        //         event = UIControlEventTouchUpInside;
        //     }
        //     for (UIView *view in _picker.subviews)
        //     {
        //         if ([view isKindOfClass:[UIButton class]])
        //         {
        //             [self.sharedDefaults setObject:[NSNumber numberWithInt:0] forKey:@"result"];
        //             [self startRecordTimer];
        //             [self startSharedDesktop:^(){
        //                 [(UIButton*)view sendActionsForControlEvents:event];
        //             }];
        //             return;
        //         }
        //     }
        // }else
        // {
        //     [self showHint:@"该功能需要iOS 13.0及以上版本，请升级系统"];
        // }
    }
}




-(void)publishSharedDesktop:(UIGestureRecognizer *)sender
{
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    
    pubConfig.maxAudioKbps = 200;
    pubConfig.type = EMStreamTypeDesktop;
    pubConfig.desktopView = self.view;
    pubConfig.videoResolution = EMCallVideoResolution_Custom;

    CGFloat screenX = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenY = [UIScreen mainScreen].bounds.size.height;
    pubConfig.videoWidth = screenY;
    pubConfig.videoHeight = screenX ;
    
    __weak typeof(self) weakself = self;
//    [[[EMClient sharedClient] conferenceManager] inputVideoPixelBuffer:buffer sampleBufferTime:t rotation:[UIDevice currentDevice].orientation conference:[EMLearnOption sharedOptions].conference publishedStreamId:_desktopStreamId completion:^(EMError *aError) {
//   //                data = nil;
//               }];
    
    //上传视频流
    [[EMClient sharedClient].conferenceManager publishConference:[EMLearnOption sharedOptions].conference streamParam:pubConfig completion:^(NSString *aPubStreamId, EMError *aError) {
        if (aError) {
            [self showHint:@"上传共享桌面流失败，请重试"];
            return ;
        }
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIDeviceOrientationFaceUp];
                [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                [UIViewController attemptRotationToDeviceOrientation];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.shareBut.image = [UIImage imageNamed:@"button_share_on"];
            sender.view.tag = 1;
        });
        
        weakself.desktopStreamId = aPubStreamId;
    }];
    
}

- (void)startSharedDesktop:(void (^)())aCompletion
{
    if(aCompletion)
        aCompletion();
}


-(void)whiteAction:(UIGestureRecognizer *)sender{
    if([EMLearnOption sharedOptions].whiteRoomId== @""){
        [self showHint:@"未创建白板"];
        return ;
    }
    bool isOpen ;
    if(sender.view.tag == 1){
        isOpen = NO;
    }else{
        isOpen = YES;
    }
    NSArray *serventIds = [NSArray arrayWithObject:[EMLearnOption sharedOptions].userId];
    [[EMClient sharedClient].conferenceManager updateWhiteboardRoomWithRoomId:[EMLearnOption sharedOptions].whiteRoomId
     username:[EMClient sharedClient].currentUsername
     userToken:[EMClient sharedClient].accessUserToken intract:isOpen allUsers:YES serventIds:serventIds completion:^(EMError *aError) {
        if (aError) {
            NSLog(@"---white update state:%@",aError.errorDescription);
            
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
             if(sender.view.tag == 1){
                 sender.view.tag = 0;
                 ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_white_off"];
             }else{
                 sender.view.tag = 1;
                 ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_white_on"];
             }
         });
    }];
    // NSMutableDictionary *param =
    // [NSMutableDictionary dictionaryWithDictionary:@{
    //     @"UserNames":@[[EMLearnOption sharedOptions].userName],
    //     @"confrId":[EMLearnOption sharedOptions].conference.confId,
    //     @"isOpen":isOpen,
    // }];
    // NSMutableDictionary *header =
    // [NSMutableDictionary dictionaryWithDictionary:@{
    //     @"Authorization":[EMLearnOption sharedOptions].sysAccessToken,
    // }];
    // [ViewBase HttpPost:@"Conference/SetWhiteStatus" paramaters:param headers:header callBlock:^void (id object,NSError *error){
    //     if ([object isKindOfClass:[NSDictionary class]]){
    //         NSDictionary *dictionary = (NSDictionary *)object;
    //         NSString *code = [dictionary objectForKey:@"code"];
    //         if([code isEqual: @"1"]){
    //             dispatch_async(dispatch_get_main_queue(), ^(void){
    //                 if(sender.view.tag == 1){
    //                     sender.view.tag = 0;
    //                     ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_white_off"];
    //                 }else{
    //                     sender.view.tag = 1;
    //                     ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_white_on"];
    //                 }
    //             });
    //         }
            
    //     }
        
    // }];
    
}
-(void)updateAdminView
{

}
-(void)leaveAction{
//    [[[EMClient sharedClient] conferenceManager] destroyWhiteboardRoomWithUsername:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken roomId:self.whiteBoard.roomId completion:^(EMError *aError) {
//        if(!aError) {
//        }
//    }];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient].conferenceManager removeDelegate:self];


    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@	"确定离开房间" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSMutableDictionary *param =
            [NSMutableDictionary dictionaryWithDictionary:@{
                @"confrId":[EMLearnOption sharedOptions].conference.confId,
                @"userName":[EMLearnOption sharedOptions].userName,
            }];
            NSMutableDictionary *header =
            [NSMutableDictionary dictionaryWithDictionary:@{
                @"Authorization":[EMLearnOption sharedOptions].sysAccessToken,
            }];
            [ViewBase HttpPost:@"Conference/Leave" paramaters:param headers:header callBlock:^void (id object,NSError *error){
                if ([object isKindOfClass:[NSDictionary class]]){
                    NSDictionary *dictionary = (NSDictionary *)object;
                    NSString *code = [dictionary objectForKey:@"code"];
                    if([code isEqual: @"1"]){
                        
                    }else{
                    
                        [self showHint:@"通知退出会议失败"];
                    }
                }else{
                    [self showHint:@"通知退出会议失败"];
                }
            }];
            [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:@"whiteBoard" completion:^(EMError *aError) {
                if(!aError) {
                }
            }];
            __weak typeof(self) weakself = self;
            void(^block)(EMError*err) = ^(EMError*err){
                [weakself _clearResource];
                [weakself dismissViewControllerAnimated:NO completion:nil];
                
                ViewLogin* loginView = [[ViewLogin alloc] init];
                loginView.modalPresentationStyle = 0;
                
                
                [self presentViewController:loginView animated:YES completion:nil];
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*0.1), dispatch_get_main_queue(), ^{
                if([EMLearnOption sharedOptions].conference) {
                    if(self.localStreamId != NULL){
                        [[EMClient sharedClient].conferenceManager unsubscribeConference:[EMLearnOption sharedOptions].conference
                            streamId:self.localStreamId completion:^(EMError *aError) {
                            if (aError) {
                                NSLog(@"---err unsub stream:%@",aError.errorDescription);
                                
                                return ;
                            }
                        }];
                    }
                    
                    [[EMClient sharedClient].conferenceManager stopMonitorSpeaker:[EMLearnOption sharedOptions].conference];
                    [[EMClient sharedClient].conferenceManager leaveConference:[EMLearnOption sharedOptions].conference completion:block];
                    [EMLearnOption sharedOptions].conference = nil;
                }else{
                    ViewLogin* loginView = [[ViewLogin alloc] init];
                    loginView.modalPresentationStyle = 0;
                    [EMLearnOption sharedOptions].conference = nil;
                    [self presentViewController:loginView animated:YES completion:nil];
                }
            });

        }]];
        // 弹出对话框
        [self presentViewController:alert animated:true completion:nil];
    });
    
    
        
}

-(void)setAction{
    [self showHint:@"12345"];
        
}

-(void)_loadFinish{
    
}

-(EMMemberView*)_getLocalMemberView{
    return NULL;
}
- (void)_subStream:(EMCallStream *)aStream{

}
- (void)_mute:(BOOL)isMute{

}
- (void)_removeStream:(StreamInfo *)aStream{

}

-(void)_clearResource{
}
-(void) _setupWhiteBoard{}
-(void)_setupCharView{};

-(void)dealloc{
    [self leaveAction];
}
    
-(void)_memberChange:(UserInfo *)u{

}
-(void)memberChange:(NSString*)key User:(UserInfo *)u oflag:(int)flag{
    NSArray *keys = [key componentsSeparatedByString:@"_"];
    NSString *rkey = @"";
    if([keys count] >1){
        rkey = keys[1];
    }else{
        rkey = keys[0];
    }
    if([key hasSuffix:@".tea"]){
        u.roleType = ROLE_TYPE_TEACHER;
    }else{
        u.roleType = ROLE_TYPE_STUDENT;
    }
    u.key = rkey;
    if(flag >= 1){
        u.name = rkey;
        [_userDictionary setObject:u forKey:rkey];
    }else if(flag == -1){
        [_userDictionary removeObjectForKey:rkey];    
    }
    if(self.tableView != nil){
        [self.tableView reloadData];
    }
    if([EMLearnOption sharedOptions].confrType == CONFR_TYPE_SMALL){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.tableView setItems:_userDictionary];
        });
    }
    if(flag > 1){
        [self _memberChange:u];
    }
}
#pragma mark - EMConferenceManagerDelegate

- (void)memberDidJoin:(EMCallConference *)aConference
               member:(EMCallMember *)aMember
{
    NSLog(@"join member:%@",aMember.nickname);
    if ([aConference.callId isEqualToString: [EMLearnOption sharedOptions].conference.callId]) {
        [self.membersDict setObject:aMember forKey:aMember.memberName];
        
//        NSString *message = [NSString stringWithFormat:@"%@ 加入会议", aMember.nickname];
//        [self showHint:message];
        [ServerCall GetNickName:aMember.memberName callBlock:^void (NSString* nickName){
            UserInfo * u = [[UserInfo alloc]init];
            u.emId = aMember.memberId;
            u.nickName = nickName;
            u.isAudio = YES;
            u.isVideo = YES;
            u.isMessage = YES;
            u.isWhite = YES;
            [self memberChange:aMember.memberName User:u oflag:1];
        }];
        
    }
}

- (void)memberDidLeave:(EMCallConference *)aConference
                member:(EMCallMember *)aMember
{
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        [self.membersDict removeObjectForKey:aMember.memberName];
        NSLog(@"leave confr");
//        NSString *message = [NSString stringWithFormat:@"%@ 离开会议", aMember.nickname];
//        [self showHint:message];
        [self memberChange:aMember.memberName User:NULL oflag:-1];
    }
}
//有新的数据流上传
- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream
{
    NSLog(@"add stream:%@",aStream.userName);
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        if(aStream.type == EMStreamTypeDesktop){
            self.remoteDesktopStreamId = aStream.streamId;
        }
        StreamInfo * si = [[StreamInfo alloc]init];
        si.userName = aStream.userName;
        si.type = aStream.type;
        [self.streamDict setValue:si forKey:aStream.streamId];
        [self _subStream:aStream];
    }
}

- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream
{
    NSLog(@"update stream:%@",aStream.userName);
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        [[[EMClient sharedClient] conferenceManager] unsubscribeConference:[EMLearnOption sharedOptions].conference streamId:aStream.streamId completion:^(EMError *aError) {
            
        }];
        [self.streamDict removeObjectForKey:aStream.streamId];
        StreamInfo* si = [[StreamInfo alloc]init];
        si.streamId = aStream.streamId;
        si.userName = aStream.userName;
        si.type = aStream.type;
        [self _removeStream:si];
    }
}

- (void)adminDidChanged:(EMCallConference *)aConference
               newAdmin:(NSString*)adminmemid
{
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        
    }
}

- (void)adminDidChanged:(EMCallConference *)aConference
            removeAdmin:(NSString*)adminmemid
{
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        
    }
}

- (void)streamPubDidFailed:(EMCallConference *)aConference error:(EMError*)aError
{
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        
    }
}

- (void)DesktopStreamDidPubFailed:(EMCallConference *)aConference error:(EMError*)aError
{
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        NSString* msg = [NSString stringWithFormat:@"Pub共享桌面失败：%@",aError.errorDescription ];
        __weak typeof(self) weakself = self;
        [[[EMClient sharedClient] conferenceManager] unpublishConference:[EMLearnOption sharedOptions].conference streamId:weakself.desktopStreamId completion:^(EMError *aError) {
            weakself.desktopStreamId = nil;
        }
        ];
        [self showHint:msg];
    }
}
- (void)streamUpdateDidFailed:(EMCallConference *)aConference error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        
    }
}

- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError
{
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        
        
    }
}
//数据流有更新（是否静音，视频是否可用）(有人静音自己/关闭视频)
- (void)streamDidUpdate:(EMCallConference *)aConference
                 stream:(EMCallStream *)aStream
{
    if (![aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId] || aStream == nil) {
        return;
    }
    UserInfo * u = [_userDictionary objectForKey:aStream.userName];
    if(u != NULL){
        u.isVideo = aStream.enableVideo;
        u.isAudio = aStream.enableVoice;
        [self memberChange:u.name User:u oflag:2];
    }
}
//数据流已经开始传输数据
- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId
{
    if ([aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        
    }
}

- (void)conferenceNetworkDidChange:(EMCallConference *)aSession
                            status:(EMCallNetworkStatus)aStatus
{
    NSString *str = @"";
    switch (aStatus) {
        case EMCallNetworkStatusNormal:
            
            break;
        case EMCallNetworkStatusUnstable:
            
            break;
        case EMCallNetworkStatusNoData:
            
            break;
            
        default:
            break;
    }
    if ([str length] > 0) {
        [self showHint:str];
    }
}
- (void)streamIdDidUpdate:(EMCallConference*)aConference rtcId:(NSString*)rtcId streamId:(NSString*)streamId
{
    if (![aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        return;
    }
    
}

- (void)streamStateUpdated:(EMCallConference*)aConference type:(EMMediaType)aType state:(EMMediaState)state streamId:(NSString*)streamId
{
    if (![aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        return;
    }
    NSString* type = @"音频";
    if(aType == EMMediaTypeVideo)
        type = @"视频";
    NSString* dataState = @"无数据";
    if(state == EMMediaStateNormal) {
        dataState = @"正常";
    }
    NSString* aStream = streamId;
    if([streamId length] > 0) {
//        EMStreamItem* stream = [self.streamItemDict objectForKey:streamId];
//        if(stream) {
//            NSString* memberName = stream.stream.memberName;
//            EMCallMember* member = [self.membersDict objectForKey:memberName];
//            if(member) {
//                if([member.nickname length] > 0) {
//                    aStream = member.nickname;
//                }
//            }else{
//                aStream = memberName;
//            }
//        }
        StreamInfo * stream = [self.streamDict objectForKey:streamId];
        if(aType == EMMediaTypeVideo && state == EMMediaStateNoData){
            [self _removeStream:stream];
        }
    }
    NSLog(@"streamStateUpdated t:%@ s:%@ sId:%@",type,dataState,streamId);
//    NSString *message = [NSString stringWithFormat:@"流%@ %@通信%@", aStream,type,dataState];
//    [self showHint:message];
}

- (void)confrenceDidUpdated:(EMCallConference*)aConference state:(EMConferenceState)aState
{
}

//用户A用户B在同一个会议中，用户A开始说话时，用户B会收到该回调
- (void)conferenceSpeakerDidChange:(EMCallConference *)aConference
                 speakingStreamIds:(NSArray *)aStreamIds
{
    if (![aConference.callId isEqualToString:[EMLearnOption sharedOptions].conference.callId]) {
        return;
    }
    
    
}

- (void)conferenceDidUpdated:(EMCallConference *)aConference
                     muteAll:(BOOL)aMuteAll
{
    if(aConference.callId == [EMLearnOption sharedOptions].conference.callId){
        [self _mute:aMuteAll];
    }
}

- (void)conferenceReqSpeaker:(EMCallConference*)aConference
                       memId:(NSString*)aMemId
                    nickName:(NSString*)nickName
                     memName:(NSString*)aMemName
{
    
}

- (void)conferenceReqAdmin:(EMCallConference*)aConference
                     memId:(NSString*)aMemId
                  nickName:(NSString*)nickName
                   memName:(NSString*)aMemName
{
    
}

- (void)conferenceDidUpdated:(EMCallConference*)aConference liveCfg:(NSDictionary*) aLiveConfig
{
    
}


- (void)conferenceDidUpdated:(EMCallConference *)aConference mute:(BOOL)aMute
{
    if(aConference.callId == [EMLearnOption sharedOptions].conference.callId){
        [self _mute:aMute];
    }
    
}

- (void)conferenceReqSpeakerRefused:(EMCallConference*)aConference adminId:(NSString*)aAdminId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showHint:@"上麦申请被拒绝"];
    });
}

- (void)conferenceReqAdminRefused:(EMCallConference*)aConference adminId:(NSString*)aAdminId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showHint:@"主持人申请被拒绝"];
    });
}

- (void)conferenceAttributeUpdated:(EMCallConference *)aConference
                        attributes:(NSArray <EMConferenceAttribute *>*)attrs
{
    
}

- (void)conferenceDidUpdate:(EMCallConference*)aConference
                   streamId:(NSString*)streamId
                 statReport:(EMRTCStatsReport *)aReport
{
    if(aReport) {
//        NSLog(@"video bps:%d",aReport.localVideoActualBps);
//        NSLog(@"width:%d,height:%d",aReport.localCaptureWidth,aReport.localCaptureHeight);
//        NSLog(@"encodewidth:%d,encodeheight:%d,fps:%d",aReport.localEncodedWidth,aReport.localEncodedHeight,aReport.localEncodedFps);
//        NSLog(@"target bps:%d",aReport.localVideoTargetBps);
    }
}

- (void)roleDidChanged:(EMCallConference *)aConference
{
    
}

#pragma arguments roomManager
/*!
 *  有用户加入聊天室
 *
 *  @param aChatroom    加入的聊天室
 *  @param aUsername    加入者
 */
- (void)userDidJoinChatroom:(EMChatroom *)aChatroom
                       user:(NSString *)aUsername{
    NSLog(@"chat join:%@",aUsername);
}
/*!
 *  有成员被加入禁言列表
 *
 *  @param aChatroom        聊天室
 *  @param aMutedMembers    被禁言的成员
 *  @param aMuteExpire      禁言失效时间，暂时不可用
 */
- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire{
    NSLog(@"mute:%@",aMutes);
    for (NSString * aMute in aMutes){
        UserInfo *ui = [_userDictionary objectForKey:aMute];
        if(ui != NULL){
            ui.isMessage = NO;
        }
        if(aMute == [EMLearnOption sharedOptions].userName){
            self.charView.chatBar.isChat = NO;
        }
        
//        [self memberChange:ui.name User:ui oflag:1];
    }
    	
}

/*!
 *  有成员被移出禁言列表
 *
 *  @param aChatroom        聊天室
 *  @param aMutedMembers    移出禁言列表的成员
 */
- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes{
    for (NSString * aMute in aMutes){
        UserInfo *ui = [_userDictionary objectForKey:aMute];
        if(ui != NULL){
            ui.isMessage = YES;
        }
        [self memberChange:ui.name User:ui oflag:1];
    }
}

- (void)chatroomAllMemberMuteChanged:(EMChatroom *)aChatroom
                    isAllMemberMuted:(BOOL)aMuted{
    NSLog(@"mute:%d",aMuted);
    self.charView.chatBar.isChat = !aMuted;
}
@end

