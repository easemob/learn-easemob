#import "EMMemberView.h"
#import <Masonry.h>
#import "EMLearnOption.h"
#import "AlertWin.h"
#import "ViewBase.h"
#import "UIView+DragScale.h"
#import "EMDefines.h"
#import "ServerCall.h"
#import "UserInfo.h"
@interface EMMemberView()



@end

@implementation EMMemberView

- (instancetype)initWithFrame:(CGRect)frame role:(NSString *)roleType
{
    self = [super initWithFrame:frame];
    self.isLocal = false;
    if (self) {
        _stream = NULL;
        self.audioStatus = YES;
        self.videoStatus = YES;
        self.backgroundColor = kColor_DeepBlue;
        
        self.upView = [[UIView alloc]initWithFrame:CGRectZero];
        self.upView.backgroundColor = kColor_Blue;
        [self addSubview:self.upView];
        [self.upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom).offset(-30);
            make.width.equalTo(self);
        }];
        
        self.downView = [[UIView alloc]initWithFrame:CGRectZero];
        self.downView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];;
        [self addSubview:self.downView];
        [self.downView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.upView.mas_bottom);
            make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo(self);
        }];
        
        self.bgView = [[UIImageView alloc] init];
        self.bgView.contentMode = UIViewContentModeScaleAspectFit;
//        self.bgView.userInteractionEnabled = YES;
        if(roleType == ROLE_TYPE_TEACHER){
            self.bgView.image = [UIImage imageNamed:@"teacher_header"];
        }else if(roleType == ROLE_TYPE_STUDENT){
            self.bgView.image = [UIImage imageNamed:@"student_header"];
        }
        
        
        [self.upView addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self);
//            make.bottom.equalTo(self);
//            make.height.equalTo(self);
//            make.width.equalTo(self);
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(30, 30, 30, 30));
        }];
        
        self.audioStatusView = [[UIImageView alloc] init];
        self.audioStatusView.contentMode = UIViewContentModeScaleAspectFit;
        self.audioStatusView.userInteractionEnabled=YES;
        UITapGestureRecognizer *audioStatusTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickAudioStatus)];
        [self.audioStatusView addGestureRecognizer:audioStatusTap];
        
        [self.downView addSubview:self.audioStatusView];
        [self.audioStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
            make.top.equalTo(self.downView.mas_top);
            make.bottom.equalTo(self.downView.mas_bottom);
            make.left.equalTo(self.downView.mas_left).offset(10);
        }];
        
        self.videoStatusView = [[UIImageView alloc] init];
        self.videoStatusView.contentMode = UIViewContentModeScaleAspectFit;
        self.videoStatusView.userInteractionEnabled=YES;
        UITapGestureRecognizer *videoStatusTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickVideoStatus)];
        [self.videoStatusView addGestureRecognizer:videoStatusTap];
        [self.downView addSubview:self.videoStatusView];
        [self.videoStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
            make.top.equalTo(self.downView.mas_top);
            make.bottom.equalTo(self.downView.mas_bottom);
            make.left.equalTo(self.audioStatusView.mas_right).offset(10);
        }];
        
        self.roleTypeLable = [[UILabel alloc] init];
        self.roleTypeLable.textColor = [UIColor whiteColor];
        self.roleTypeLable.font = [UIFont systemFontOfSize:12];
        [self.downView addSubview:self.roleTypeLable];
        [self.roleTypeLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.top.equalTo(self.downView.mas_top);
            make.bottom.equalTo(self.downView.mas_bottom);
            make.left.equalTo(self.videoStatusView.mas_right).offset(10);
        }];
        
//        self.roleTypeLable = [[UILabel alloc] init];
//        self.roleTypeLable.contentMode = UIViewContentModeScaleAspectFit;
//        [self addSubview:self.roleTypeLable];
//        [self.roleTypeLable mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(10);
//            make.bottom.equalTo(self);
//            make.height.equalTo(@20);
//            make.width.equalTo(@40);
//        }];

        

        
        

        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:longPress];
        
    }
    return self;
}
// 长按图片的时候就会触发长按手势
- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press");
        self.expanBlock(0);
        [self enableDragging];
    }
}

-(void)onClickExpan:(UIGestureRecognizer *)sender{
    if(![self isSetStream] && ![self isLocal]){
        return;
    }
    NSLog(@"click expan");
    self.expanBlock(sender.view.tag);
    if(sender.view.tag == 0){
        // ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_message_off"];
        sender.view.tag=1;
    }else{
        // ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_message_off"];
        sender.view.tag=0;
    }
}
-(void)onClickAudioStatus{
    NSLog(@"click audio");
    BOOL isAudio = !_audioStatus;
    if(self.isLocal){
        [self setAudioStatus:isAudio];
        [[[EMClient sharedClient] conferenceManager] updateConference:[EMLearnOption sharedOptions].conference isMute:!isAudio];
    }else{
        if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_TEACHER]){
            UserInfo *ui = [self.userDictionary objectForKey:self.userName];
            if(ui != NULL){
                [[[EMClient sharedClient] conferenceManager] setMuteMember:[EMLearnOption sharedOptions].conference memId:ui.emId mute:!isAudio completion:^(EMError *aError) {
                    if(aError) {
                        NSLog(@"set mute err:%@",aError.errorDescription);
                        return;
                        
                    }
                   
                    
                }];
            }
            
        }else{
            [AlertWin showInfoAlert:@"无法控制"];
        }
        
    }
    
}
-(void)onClickVideoStatus{
    NSLog(@"click video");
    if(self.isLocal){
        BOOL isVideo = !_videoStatus;
        [self setVideoStatus:isVideo];
        [[[EMClient sharedClient] conferenceManager] updateConference:[EMLearnOption sharedOptions].conference enableVideo:isVideo];
    }else{
        [AlertWin showInfoAlert:@"无法控制"];
    }
    
}
- (void)setDisplayView:(UIView *)streamView
{
    if(streamView == NULL){
        [_streamView removeFromSuperview];
    }
    _streamView = streamView;
//    _streamView.backgroundColor = [UIColor blackColor];
    if([_streamView isKindOfClass:[EMCallRemoteView class]] || [_streamView isKindOfClass:[EMCallLocalView class]]) {
        [self addSubview:streamView];
        [self sendSubviewToBack:streamView];
        [self sendSubviewToBack:_upView];
//        self.backgroundColor = [UIColor clearColor];
//        [self bringSubviewToFront:streamView];
        [streamView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(self);
        }];
    }else{
        NSLog(@"display view is error");
    }
}
-(void)setLocal{

    self.isLocal = true;
}
-(BOOL)isSetStream{
    if(_stream != NULL){
        return YES;
    }
    return NO;
}
-(void)setStream:(EMCallStream *)aStream{
    _userName = aStream.userName;
    _stream = aStream;
    if (aStream == NULL){
        [self setVideoStatus:NO];
        self.nickNameLabel.text = @"";
        [self setDisplayView:NULL];
    }else{
        if(self.streamView == NULL){
            EMCallRemoteView *remoteView = [[EMCallRemoteView alloc] init];
            remoteView.scaleMode = EMCallViewScaleModeAspectFill;//EMCallViewScaleModeAspectFit;
            [self setVideoStatus:aStream.enableVideo];
            [self setAudioStatus:aStream.enableVoice];
            
            [self setDisplayView:remoteView];
        }else{
            [self setVideoStatus:aStream.enableVideo];
            [self setAudioStatus:aStream.enableVoice];
        }
        [ServerCall GetNickName:aStream.memberName callBlock:^void (NSString* nickName){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self setNickName:nickName];
            });
        }];
    }
}
-(void)setUserDictionary:(NSMutableDictionary *)dict{
    _userDictionary = dict;
}

-(void)setRoleName:(NSString *)roleName{
    self.roleTypeLable.text = roleName;
}

-(void)setNickName:(NSString *)nickName{
    self.roleTypeLable.text = nickName;
//    self.nickNameLabel.text = nickName;
}

- (void)setAudioStatus:(BOOL)audioStatus
{
    _audioStatus = audioStatus;
    
    if (audioStatus) {
        _audioStatusView.image = [UIImage imageNamed:@"mv_audio_on"];
        if(self.timeTimer){
            [self.timeTimer invalidate];
            self.timeTimer = nil;
        }
    } else {
        self.status = StreamStatusNormal;
        _audioStatusView.image = [UIImage imageNamed:@"mv_audio_off"];
    }
}


- (void)setVideoStatus:(BOOL)videoStatus
{
    _videoStatus = videoStatus;
    
    if (videoStatus) {
        self.videoStatusView.image = [UIImage imageNamed:@"mv_video_on"];
        _upView.hidden = YES;
        if(_streamView)
        {
            _streamView.hidden = NO;
//            [self bringSubviewToFront:_streamView];
        }
    } else {
        self.videoStatusView.image = [UIImage imageNamed:@"mv_video_off"];
        _upView.hidden = NO;
        if(_streamView)
        {
            _streamView.hidden = YES;
//            [self sendSubviewToBack:_streamView];
        }
    }
}

- (void)setStatus:(StreamStatus)status
{
    if (_status == status) {
        return;
    }
    
    _status = status;
//    [self bringSubviewToFront:_audioStatusView];
    
    switch (_status) {
        case StreamStatusConnecting:
        {
            if (_audioStatus) {
                _audioStatusView.image = [UIImage imageNamed:@"mv_audio_gray"];
            }
        }
            break;
        case StreamStatusConnected:
        {
            if (_audioStatus) {
                _audioStatusView.image = [UIImage imageNamed:@"mv_audio_off"];
            }
        }
            break;
        case StreamStatusTalking:
            if (_audioStatus) {
                if(!self.timeTimer)
                    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeTalkingAction:) userInfo:nil repeats:YES];
            }
            break;
            
        default:
            {
                if (_audioStatus) {
                    _audioStatusView.image = [UIImage imageNamed:@"mv_audio_off"];
                    if(self.timeTimer){
                        [self.timeTimer invalidate];
                        self.timeTimer = nil;
                    }
                }
            }
            break;
    }
}

- (void)timeTalkingAction:(id)sender
{
    self.imageCount++;
    self.imageCount %= 12;
    NSString* imageName = [NSString stringWithFormat:@"volume/%02d",12-self.imageCount];
    _audioStatusView.image = [UIImage imageNamed:imageName];
}


@end
