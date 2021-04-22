#import "ViewSmallMain.h"
#import "EMMemberView.h"
#import <Masonry.h>
#import "EMLearnOption.h"
#import "EMDefines.h"
#import "EMMemberViewList.h"
#import "TableView.h"
//小班课页面
@interface ViewSmallMain ()
    @property (nonatomic) EMMemberViewList* scrollView;
@end


@implementation ViewSmallMain


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [[EMMemberViewList alloc] init];
    self.scrollView.parentView = self.view;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.3);
        make.left.equalTo(self.view);
        make.top.equalTo(self.topViewMain.view.mas_bottom);
    }];
    [self.scrollView addTeacherView];
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
        [self.scrollView addLocalView];
    }else {
        [self.scrollView.teacherView setLocal];
    }
}

- (void)_removeStream:(StreamInfo *)aStream{
    NSString *username = [EMLearnOption sharedOptions].userName;
    if(aStream.type == EMStreamTypeDesktop    ){
        EMMemberView* addView = self.remoteDesktopView;
        NSLog(@"remove desktop name:%@ up:%@",username,self.remoteDesktopView);
        [addView setStream:NULL];
        if(aStream.type == EMStreamTypeDesktop    ){
            [addView removeFromSuperview];
        }
    }else{
        if ([aStream.userName hasSuffix:@".tea"]){
            [self.scrollView removeView:@"sys-teacher"];
            [self.scrollView.teacherView setVideoStatus:NO];
            [self.scrollView.teacherView setAudioStatus:NO];
        }else{
            [self.scrollView removeView:aStream.userName];
        }
    }
    [[EMClient sharedClient].conferenceManager unsubscribeConference:[EMLearnOption sharedOptions].conference
                                                            streamId:aStream.streamId completion:^(EMError *aError) {
        if (aError) {
            NSLog(@"---err unsub stream:%@ sId:%@",aError.errorDescription,aStream.streamId);
            
            return ;
        }
    }];
    
}

- (void)_subStream:(EMCallStream *)aStream{
    EMMemberView* addView = NULL;
    if(aStream.type == EMStreamTypeDesktop    ){
        addView = self.remoteDesktopView;
    }else{
        if ([aStream.userName hasSuffix:@".tea"]){
            addView = [self.scrollView getMemberView:@"sys-teacher"];
            
        }else{
            addView = [self.scrollView getMemberView:aStream.userName];
            if(addView == NULL){
                addView = [self.scrollView newMemberView:aStream.userName];
            }
        }
    }
    
    @synchronized (self) {
        if(addView ==NULL){
            NSLog(@"return null sub aStream:%@",aStream);
            return;
        }
        BOOL isSet = [addView isSetStream];
        if( isSet){
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
    //订阅其他人的数据流，，即订阅当前会议上麦主播的数据流
    [[EMClient sharedClient].conferenceManager subscribeConference:[EMLearnOption sharedOptions].conference
        streamId:aStream.streamId remoteVideoView:addView.streamView completion:^(EMError *aError) {
        if (aError) {
            NSLog(@"---err sub stream:%@",aError.errorDescription);
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"alert.conference.subFail", @"Sub stream-%@ failed!"), aStream.userName];
            [self showHint:message];
            return ;
        }else{
            if(aStream.type == EMStreamTypeDesktop    ){
                [self.view addSubview:self.remoteDesktopView];
                [self.view bringSubviewToFront:self.remoteDesktopView];
                [self.remoteDesktopView mas_makeConstraints:^(MASConstraintMaker *make) {
                      make.edges.equalTo(self.whiteBoardView);
                }];
            }
            
        }

    }];
    
}

-(void)_clearResource{
    
}
-(void)_setupWhiteBoard{
    [self.whiteBoardView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.6);
        make.left.equalTo(self.view);
        make.top.equalTo(self.scrollView.mas_bottom);
    }];
    
}
-(void)_setupCharView{
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_TEACHER]){
        [self.buttonGroup mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@80);
            make.height.equalTo(@40);
            make.right.equalTo(self.whiteBoardView.view.mas_right).offset(-100);
            make.bottom.equalTo(self.whiteBoardView.view.mas_bottom).offset(-20);
        }];
    }
    self.chatImgBut = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.chatImgBut.tag = 1;
    self.chatImgBut.backgroundColor =UIColor.whiteColor;
    self.chatImgBut.image = [UIImage imageNamed:@""];

    self.chatImgBut.userInteractionEnabled=YES;
    self.chatImgBut.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *switchButImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chatAction)];
    [self.chatImgBut addGestureRecognizer:switchButImageTap];
    [self.view addSubview:self.chatImgBut];
    
    [self chatAction];
    
    
    
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    NSInteger halfWidth =width/4;
    [self.view addSubview:self.charView];
    [self.charView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(halfWidth);
        make.height.equalTo(self.whiteBoardView.view.mas_height).offset(-60);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.equalTo(self.scrollView.mas_bottom);
    }];
    self.charView.chatImgBut = self.chatImgBut;
    
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_TEACHER]){
        self.authImgBut = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.authImgBut.tag = 1;
        self.authImgBut.backgroundColor =UIColor.whiteColor;
        self.authImgBut.image = [UIImage imageNamed:@""];

        self.authImgBut.userInteractionEnabled=YES;
        self.authImgBut.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *authImgButTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(authAction)];
        [self.authImgBut addGestureRecognizer:authImgButTap];
        [self.view addSubview:self.authImgBut];
        [self.authImgBut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@30);
            make.height.mas_equalTo(@30);
            make.right.equalTo(self.view.mas_right).offset(-10);
            make.bottom.equalTo(self.whiteBoardView.view.mas_bottom).offset(-20);
        }];
        [self.chatImgBut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@30);
            make.height.mas_equalTo(@30);
            make.right.equalTo(self.authImgBut.mas_left).offset(-10);
            make.bottom.equalTo(self.whiteBoardView.view.mas_bottom).offset(-20);
        }];
        [self authAction];
        
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(halfWidth);
            make.height.equalTo(self.whiteBoardView.view.mas_height).offset(-60);
            make.right.mas_equalTo(self.view.mas_right);
            make.top.equalTo(self.scrollView.mas_bottom);
        }];
        self.tableView.authImgBut = self.authImgBut;
    }else{
        [self.chatImgBut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@30);
            make.height.mas_equalTo(@30);
            make.right.equalTo(self.view.mas_right).offset(-20);
            make.bottom.equalTo(self.whiteBoardView.view.mas_bottom).offset(-20);
        }];
    }
//    [self.moveMidView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(self.view).multipliedBy(0.25);
//        make.height.equalTo(self.whiteBoardView.view.mas_height);
//        make.left.mas_equalTo(self.midView.mas_left);
//        make.top.equalTo(self.scrollView.mas_bottom);
//    }];
//
//    NSInteger width = [UIScreen mainScreen].bounds.size.width;
//    NSInteger halfWidth =width/4;
//    [self.midView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(halfWidth);
//        make.height.equalTo(self.whiteBoardView.view.mas_height);
//        make.right.mas_equalTo(self.view.mas_right);
//        make.top.equalTo(self.scrollView.mas_bottom);
//    }];
//
//
//    [self.view bringSubviewToFront:self.moveMidView];
//
////    [self.view sendSubviewToBack:self.midView];
//    [self.midTab setupView];
//    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
//        [self.midTab setTitle:@[@"聊天区"]];
//    }else {
//        [self.midTab setTitle:@[@"聊天区",@"学生列表"]];
//    }
    
}


-(EMMemberView*)_getLocalMemberView{
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
        return self.scrollView.localView;
    }else {
        return self.scrollView.teacherView;
    }
    
}

- (void)_mute:(BOOL)isMute{
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
        [self.scrollView.localView setAudioStatus:!isMute];
    }else {
        [self.scrollView.teacherView setAudioStatus:!isMute];
    }
}

-(void)chatAction{
    if (self.chatImgBut.tag == 1){//close
        self.charView.hidden = YES;
        
        self.chatImgBut.image = [UIImage imageNamed:@"button_switch"];
        self.chatImgBut.tag = 0;
    }else{//open
        if (self.authImgBut.tag == 1){//close
            self.tableView.hidden = YES;
            
            self.authImgBut.image = [UIImage imageNamed:@"button_auth"];
            self.authImgBut.tag = 0;
        }
        
        self.charView.hidden = NO;
        
        self.chatImgBut.image = [UIImage imageNamed:@""];
        self.chatImgBut.tag = 1;
    }
}
-(void)authAction{
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
    
    if (self.authImgBut.tag == 1){//close
        self.tableView.hidden = YES;
        
        self.authImgBut.image = [UIImage imageNamed:@"button_auth"];
        self.authImgBut.tag = 0;
    }else{//open
        if (self.chatImgBut.tag == 1){//close
            self.charView.hidden = YES;
            
            self.chatImgBut.image = [UIImage imageNamed:@"button_switch"];
            self.chatImgBut.tag = 0;
        }
        
        self.tableView.hidden = NO;
        
        self.authImgBut.image = [UIImage imageNamed:@""];
        self.authImgBut.tag = 1;
    }
}
-(void)_memberChange:(UserInfo *)u{
    if(u.roleType == ROLE_TYPE_STUDENT){
        EMMemberView* studentView = [self.scrollView getMemberView:u.key];
        [studentView setAudioStatus:u.isAudio];
        [studentView setVideoStatus:u.isVideo];
    }else if(u.roleType == ROLE_TYPE_TEACHER){
        EMMemberView* teacherView = [self.scrollView getMemberView:@"sys-teacher"];
        [teacherView setAudioStatus:u.isAudio];
        [teacherView setVideoStatus:u.isVideo];
    }
}
@end



