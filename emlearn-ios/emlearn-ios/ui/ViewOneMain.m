#import "ViewOneMain.h"
#import "../plugin/MemberView/EMMemberView.h"
#import "EMLearnOption.h"
#import <Masonry.h>
#import "EMDefines.h"
#import "UserInfo.h"
//1v1页面
@interface ViewOneMain ()
    @property (nonatomic) EMMemberView* upMemberView;
    @property (nonatomic) EMMemberView* downMemberView;
    @property (nonatomic) NSString* otherSteamId;
   @property (nonatomic) UIView *groupMemberView;
@end


@implementation ViewOneMain

- (void)viewDidLoad {
    [super viewDidLoad];
    self.upMemberView = [[EMMemberView alloc]initWithFrame:CGRectZero role:ROLE_TYPE_TEACHER];
    [self.upMemberView setVideoStatus:NO];
    [self.upMemberView setAudioStatus:NO];
    
    self.downMemberView = [[EMMemberView alloc]initWithFrame:CGRectZero role:ROLE_TYPE_STUDENT];
    [self.downMemberView setVideoStatus:NO];
    [self.downMemberView setAudioStatus:NO];
    
    
    self.GroupMemberViewWidth = self.GroupMemberViewHeight /2+20;
    self.WhiteBoardViewWidth = self.ScreenWidth - self.GroupMemberViewWidth;
    self.MemberViewHeight = self.GroupMemberViewHeight /2;
}

- (void)_removeStream:(StreamInfo *)aStream{
    NSString *username = [EMLearnOption sharedOptions].userName;
    EMMemberView* addView = NULL;
    if(aStream.type == EMStreamTypeDesktop    ){
        addView = self.remoteDesktopView;
        NSLog(@"remove desktop name:%@ up:%@",username,self.remoteDesktopView);
    }else{
        if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
            addView= self.upMemberView;
            NSLog(@"remove student up:%@",username,self.upMemberView);
        }else {
            addView= self.downMemberView;
            NSLog(@"remove teacher down:%@",username,self.downMemberView);
        }
    }
    
    [addView setStream:NULL];
    if(aStream.type == EMStreamTypeDesktop    ){
        [addView removeFromSuperview];
    }
}

- (void)_subStream:(EMCallStream *)aStream{
    NSString *username = [EMLearnOption sharedOptions].userName;
    
    EMMemberView* addView = NULL;
    if(aStream.type == EMStreamTypeDesktop    ){
        addView = self.remoteDesktopView;
        NSLog(@"sub desktop name:%@ up:%@ sId:%@",username,self.remoteDesktopView,aStream.streamId);
    }else{
        if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
            addView= self.upMemberView;
            NSLog(@"sub student name:%@ up:%@ sId:%@",username,self.upMemberView,aStream.streamId);
        }else {
            addView= self.downMemberView;
            NSLog(@"sub teacher name:%@ down:%@ sId:%@",username,self.downMemberView,aStream.streamId);
        }
    }

    
    @synchronized (self) {
        BOOL isSet = [addView isSetStream];
        if(isSet){
            EMCallStream * ostream = addView.stream;
            if(ostream.type == aStream.type){
                NSLog(@"return sub addView:%@ isSet:%d aStream:%@",addView,isSet,aStream);
                return;
            }else{
                [[EMClient sharedClient].conferenceManager unsubscribeConference:[EMLearnOption sharedOptions].conference
                    streamId:ostream.streamId completion:^(EMError *aError) {
                    if (aError) {
                        NSLog(@"---err unsub stream:%@ sId:%@",aError.errorDescription,aStream.streamId);
                        
                        return ;
                    }
                }];
                [addView setStream:NULL];
                NSLog(@"pass sub addView:%@ isSet:%d aStream:%@",addView,isSet,aStream);
            }
        }
        [addView setUserDictionary:self.userDictionary];
        [addView setStream:aStream];
    }
    self.otherSteamId = aStream.streamId;
    __weak typeof(self) weakSelf = self;
    //订阅其他人的数据流，，即订阅当前会议上麦主播的数据流
    [[EMClient sharedClient].conferenceManager subscribeConference:[EMLearnOption sharedOptions].conference
        streamId:aStream.streamId remoteVideoView:addView.streamView completion:^(EMError *aError) {
        if (aError) {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), aStream.userName];
            [self showHint:message];
            NSLog(@"---err sub stream:%@ sId:%@",aError.errorDescription,aStream.streamId);
            return ;
        }else{
            if(aStream.type == EMStreamTypeDesktop    ){
                [self.view addSubview:self.remoteDesktopView];
                [self.remoteDesktopView mas_makeConstraints:^(MASConstraintMaker *make) {
                      make.edges.equalTo(self.whiteBoardView.view);
                }];
                [self.view bringSubviewToFront:self.remoteDesktopView];
                
            }
            
        }

    }];
    
}


-(void)_setupWhiteBoard{
    [self.whiteBoardView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.WhiteBoardViewWidth);
        make.left.equalTo(self.view);
        make.top.equalTo(self.topViewMain.view.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
}
-(void)_setupCharView{
    NSInteger screenHeight = SCREEN_HEIGHT;
    NSInteger screenWidth = SCREEN_WIDTH;
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_TEACHER]){
        [self.buttonGroup mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@80);
            make.height.equalTo(@40);
            make.right.equalTo(self.whiteBoardView.view.mas_right).offset(-10);
            make.bottom.equalTo(self.whiteBoardView.view.mas_bottom).offset(-70);
        }];
    }
    
    
   self.groupMemberView = [[UIView alloc] init];
   self.groupMemberView.backgroundColor = [UIColor blackColor];
   [self.view addSubview:self.groupMemberView];
   [self.groupMemberView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(self.WhiteBoardViewWidth);
       make.width.mas_equalTo(self.GroupMemberViewWidth);
       make.height.mas_equalTo(self.GroupMemberViewHeight);
       make.top.mas_equalTo(self.TopViewHeight);
//        make.right.equalTo(self.view);

//        make.bottom.equalTo(self.view.mas_bottom);


//        make.top.equalTo(self.topViewMain.view.mas_bottom);
   }];
    
    
    [self.upMemberView setRoleName:@"老师"];
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_TEACHER]){
        [self.upMemberView setLocal];
    }
   [self.groupMemberView addSubview:self.upMemberView];
    //去除点击右上角按钮
   self.upMemberView.expanBlock = ^(NSInteger tag){
       if(tag == 1){
           [self.upMemberView removeFromSuperview];
           [self.view layoutSubviews];
           [self.groupMemberView addSubview:self.upMemberView];
           [self.upMemberView mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.width.mas_equalTo(self.groupMemberView.mas_width);
               make.height.mas_equalTo(self.groupMemberView.mas_height).multipliedBy(0.5);
               make.left.mas_equalTo(self.groupMemberView.mas_left);
               make.top.mas_equalTo(self.groupMemberView.mas_top);
           }];
       }else{
           [self.upMemberView removeFromSuperview];
           [self.view layoutSubviews];
           [self.view addSubview:self.upMemberView];
           [self.upMemberView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //    make.centerX.mas_equalTo(self.view.mas_centerX);
            //    make.centerY.mas_equalTo(self.view.mas_centerY);
            //    make.width.mas_equalTo(400);
            //    make.height.mas_equalTo(300);
               make.width.mas_equalTo(self.groupMemberView.mas_width);
               make.height.mas_equalTo(self.groupMemberView.mas_height).multipliedBy(0.5);
               make.left.mas_equalTo(self.groupMemberView.mas_left);
               make.top.mas_equalTo(self.groupMemberView.mas_top);
           }];
       }
       [self.view setNeedsUpdateConstraints];
   };
   self.upMemberView.expanBlock(1);
    
//
    
    [self.downMemberView setRoleName:@"学生"];
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
        [self.downMemberView setLocal];
    }
    
   [self.groupMemberView addSubview:self.downMemberView];
   self.downMemberView.expanBlock = ^(NSInteger tag){
       if(tag == 1){
           [self.downMemberView removeFromSuperview];
           [self.view layoutSubviews];
           [self.groupMemberView addSubview:self.downMemberView];
           [self.downMemberView mas_remakeConstraints:^(MASConstraintMaker *make) {
               make.width.mas_equalTo(self.groupMemberView.mas_width);
               make.height.mas_equalTo(self.groupMemberView.mas_height).multipliedBy(0.5);
               make.left.mas_equalTo(self.groupMemberView.mas_left);
               make.bottom.equalTo(self.groupMemberView.mas_bottom);
           }];
       }else{
           [self.downMemberView removeFromSuperview];
           [self.view layoutSubviews];
           [self.view addSubview:self.downMemberView];
           [self.downMemberView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //    make.centerX.mas_equalTo(self.view.mas_centerX);
            //    make.centerY.mas_equalTo(self.view.mas_centerY);
            //    make.width.mas_equalTo(400);
            //    make.height.mas_equalTo(300);
               make.width.mas_equalTo(self.groupMemberView.mas_width);
               make.height.mas_equalTo(self.groupMemberView.mas_height).multipliedBy(0.5);
               make.left.mas_equalTo(self.groupMemberView.mas_left);
               make.bottom.equalTo(self.groupMemberView.mas_bottom);
           }];
       }
       [self.view setNeedsUpdateConstraints];
   };
   self.downMemberView.expanBlock(1);
    
   [self.groupMemberView  layoutIfNeeded];
   [self.groupMemberView  setNeedsUpdateConstraints];
    
    self.chatImgBut = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.chatImgBut.tag = 1;
    self.chatImgBut.backgroundColor =UIColor.whiteColor;
    self.chatImgBut.image = [UIImage imageNamed:@""];

    self.chatImgBut.userInteractionEnabled=YES;
    self.chatImgBut.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *switchButImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chatAction)];
    [self.chatImgBut addGestureRecognizer:switchButImageTap];
    [self.view addSubview:self.chatImgBut];
    [self.chatImgBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@30);
        make.height.mas_equalTo(@30);
        make.right.equalTo(self.whiteBoardView.view.mas_right).offset(-10);
        make.bottom.equalTo(self.whiteBoardView.view.mas_bottom).offset(-20);
    }];
    
    
    [self.view addSubview:self.charView];
    [self.charView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.GroupMemberViewWidth);
        make.height.mas_equalTo(self.whiteBoardView.view.mas_height).multipliedBy(0.8);
        make.right.mas_equalTo(self.whiteBoardView.view.mas_right);
        make.top.mas_equalTo(self.topViewMain.view.mas_bottom);
    }];
    
    self.charView.chatImgBut = self.chatImgBut;
    [self chatAction];
    //设置聊天框
//    CGFloat tx = self.groupMemberView.frame.origin.x;
    
//    NSInteger halfWidth =screenWidth/2;
//
//    [self.midView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(halfWidth);
//        make.right.mas_equalTo(self.view.mas_right);
//        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
//        make.top.equalTo(self.topViewMain.view.mas_bottom);
//    }];
//    [self.moveMidView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(halfWidth/2);
//        make.left.mas_equalTo(self.midView.mas_left);
//        make.top.equalTo(self.topViewMain.view.mas_bottom);
//        make.bottom.equalTo(self.midView.mas_bottom).offset(-50);
//    }];
//
//
//    [self.view bringSubviewToFront:self.moveMidView];
//    [self.view sendSubviewToBack:self.midView];
    
    
//    [self.midTab setupView];
//    [self.midTab setTitle:@[@"聊天区"]];
}
-(EMMemberView*)_getLocalMemberView{
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
        return self.downMemberView;
    }else {
        return self.upMemberView;
    }
}
- (void)_mute:(BOOL)isMute{
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
        [self.downMemberView setAudioStatus:!isMute];
    }else {
        [self.upMemberView setAudioStatus:!isMute];
    }
}
-(void)chatAction{
//    [[[EMClient sharedClient] conferenceManager] setMuteMember:[EMLearnOption sharedOptions].conference memId:[EMLearnOption sharedOptions].userId mute:NO completion:^(EMError *aError) {
//        if(aError) {
//            NSLog(@"set mute err:%@",aError.errorDescription);
//            return;
//        }else{
//
//        }
//    }];
    
    if (self.chatImgBut.tag == 1){//close
        self.charView.hidden = YES;
        
        self.chatImgBut.image = [UIImage imageNamed:@"button_switch"];
        self.chatImgBut.tag = 0;
    }else{//open
        self.charView.hidden = NO;
        
        self.chatImgBut.image = [UIImage imageNamed:@""];
        self.chatImgBut.tag = 1;
    }
}
-(void)_memberChange:(UserInfo *)u{
    if(u.roleType == ROLE_TYPE_STUDENT){
        [self.downMemberView setAudioStatus:u.isAudio];
        [self.downMemberView setVideoStatus:u.isVideo];
    }else if(u.roleType == ROLE_TYPE_TEACHER){
        [self.upMemberView setAudioStatus:u.isAudio];
        [self.upMemberView setVideoStatus:u.isVideo];
    }
}
-(void)leaveAction{
    [super leaveAction];
}
@end


