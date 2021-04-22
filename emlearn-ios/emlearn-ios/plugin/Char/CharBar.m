#import "CharBar.h"
#import <Masonry.h>
#import "../../EMDefines.h"
#import "ViewBase.h"
#import "EMLearnOption.h"
#import "AlertWin.h"
#import "SysUtils.h"
#define ktextViewMinHeight 40
#define ktextViewMaxHeight 120

@interface CharBar()<UITextViewDelegate>

@property (nonatomic) CGFloat version;

@property (nonatomic) CGFloat previousTextViewContentHeight;


@end


@implementation CharBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isChat = YES;
        _version = [[[UIDevice currentDevice] systemVersion] floatValue];
        _previousTextViewContentHeight = ktextViewMinHeight;
        [self _setupSubviews];
    }
    
    return self;
}


- (void)_setupSubviews {
    self.backgroundColor = [UIColor whiteColor];
//    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = kColor_Gray;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    UIImageView *sbut = [[UIImageView alloc] initWithFrame:CGRectZero];
    sbut.image =[UIImage imageNamed:@"tv_message_on"];
    sbut.userInteractionEnabled=YES;
    sbut.tag = 1;
    sbut.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *sbutTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSbut:)];
    [sbut addGestureRecognizer:sbutTap];
    sbut.backgroundColor = UIColor.whiteColor;
    [self addSubview:sbut];
    [sbut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
        make.left.mas_equalTo(2);
        make.width.mas_equalTo(20);
        make.height.mas_offset(20);
    }];
    
    if ([[EMLearnOption sharedOptions].roleType  isEqual: ROLE_TYPE_STUDENT]){
        sbut.hidden = YES;
    }
    self.textView = [[EMTextView alloc] init];
    self.textView.delegate = self;
    self.textView.placeholder = @"请输入消息内容";
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.backgroundColor = kColor_LightGray;
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
        make.left.mas_equalTo(sbut.mas_right).offset(2);
        make.right.equalTo(self).offset(-50);
    }];
    
    UIButton * sendBut = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBut.layer.cornerRadius = 10;
    [sendBut setTitle:@"发送" forState:UIControlStateNormal];
    [sendBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBut setBackgroundColor:kColor_DeepPurple];
    [self addSubview:sendBut];
    [sendBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@50);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
        make.left.equalTo(self.textView.mas_right);
    }];
    
    // self.buttonsView = [[UIView alloc] init];
    // self.buttonsView.backgroundColor = [UIColor clearColor];
//    [self _setupButtonsView];
    // [self addSubview:self.buttonsView];
    // [self.buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
    //     make.top.equalTo(self.textView.mas_bottom).offset(5);
    //     make.left.equalTo(self);
    //     make.right.equalTo(self);
    //     make.height.equalTo(@50);
    //     make.bottom.equalTo(self).offset(-EMVIEWBOTTOMMARGIN);
    // }];
    
}

//点击return收回键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
     //回收键盘,取消第一响应者
     [textField resignFirstResponder];
    return YES;
}

//点击空白处收回键盘
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}
-(void)onSbut:(UIGestureRecognizer *)sender{
    if(sender.view.tag == 1){
        [[EMClient sharedClient].roomManager muteAllMembersFromChatroom:[EMLearnOption sharedOptions].chatRoomId completion:^void (EMChatroom *aChatroom, EMError *aError){
            if(aError) {
                NSLog(@"set mute message all err:%@",aError.errorDescription);
                return;
                
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                sender.view.tag = 0;
                ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_message_off"];
            });
        }];
    }else{
        [[EMClient sharedClient].roomManager unmuteAllMembersFromChatroom:[EMLearnOption sharedOptions].chatRoomId completion:^void (EMChatroom *aChatroom, EMError *aError){
            if(aError) {
                NSLog(@"set unmute message all err:%@",aError.errorDescription);
                return;
                
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                sender.view.tag = 1;
                ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_message_on"];
            });
        }];
    }
    
//    NSNumber *isOpen = [[NSNumber alloc] initWithInt:0];
//    if(sender.view.tag == 1){
//        isOpen = [[NSNumber alloc] initWithInt:-1];
//    }else{
//        isOpen = [[NSNumber alloc] initWithInt:1];
//    }
//    NSMutableDictionary *param =
//    [NSMutableDictionary dictionaryWithDictionary:@{
//        @"confrId":[EMLearnOption sharedOptions].conference.confId,
//        @"isOpen":isOpen,
//    }];
//    NSMutableDictionary *header =
//    [NSMutableDictionary dictionaryWithDictionary:@{
//        @"Authorization":[EMLearnOption sharedOptions].sysAccessToken,
//    }];
//    [ViewBase HttpPost:@"Conference/SetChatroomMute" paramaters:param headers:header callBlock:^void (id object,NSError *error){
//        if ([object isKindOfClass:[NSDictionary class]]){
//            NSDictionary *dictionary = (NSDictionary *)object;
//            NSString *code = [dictionary objectForKey:@"code"];
//            if([code isEqual: @"1"]){
//                dispatch_async(dispatch_get_main_queue(), ^(void){
//                    if(sender.view.tag == 1){
//                        sender.view.tag = 0;
//                        ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_message_off"];
//                    }else{
//                        sender.view.tag = 1;
//                        ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_message_on"];
//                    }
//                });
//            }
//
//        }
//
//    }];
}
#pragma mark - UITextViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.isChat){
        UIView* curWin = [SysUtils GetCurView];
        NSLog(@"ui:%@",curWin);
        self.keyBoard = [[EmKeyBoard alloc] init];
        self.keyBoard.emdelegate = self.emdelegate;
        [curWin addSubview:self.keyBoard];
        [self.keyBoard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(curWin.mas_left);
            make.top.equalTo(curWin.mas_top);
            make.height.mas_equalTo([UIScreen mainScreen].bounds.size.height -200);
            make.width.mas_equalTo(curWin.mas_width);
       }];
        [curWin bringSubviewToFront:self.keyBoard];
        [self.keyBoard layoutIfNeeded];
        [self.keyBoard setNeedsUpdateConstraints];
    }else{
        [AlertWin showInfoAlert:@"禁言中"];
    }
    
    
}
// - (void)textViewDidEndEditing:(UITextView *)textView{
//    [UIView animateWithDuration:0.3f animations:^{
//        [self mas_updateConstraints:^(MASConstraintMaker *make) {

//            make.top.mas_equalTo(self.heigth -120);
// //            make.bottom.equalTo(self.parent.mas_bottom);
//        }];
//        [self.parent layoutIfNeeded];
//    }];
// }



- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(self.isChat){
        return YES;
    }else{
        [AlertWin showInfoAlert:@"禁言中"];
        return NO;
    }
    
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    
//    if (self.emdelegate && [self.emdelegate respondsToSelector:@selector(inputView:shouldChangeTextInRange:replacementText:)]) {
//        return [self.emdelegate inputView:self.textView shouldChangeTextInRange:range replacementText:text];
//    } 
//    
//    return YES;
//}
//
//- (void)textViewDidChange:(UITextView *)textView
//{
//    [self _updatetextViewHeight];
//    if (self.emdelegate && [self.emdelegate respondsToSelector:@selector(inputViewDidChange:)]) {
//        [self.emdelegate inputViewDidChange:self.textView];
//    }
//}

#pragma mark - Private

- (CGFloat)_gettextViewContontHeight
{
    if (self.version >= 7.0) {
        return ceilf([self.textView sizeThatFits:self.textView.frame.size].height);
    } else {
        return self.textView.contentSize.height;
    }
}

- (void)_updatetextViewHeight
{
    CGFloat height = [self _gettextViewContontHeight];
    if (height < ktextViewMinHeight) {
        height = ktextViewMinHeight;
    }
    if (height > ktextViewMaxHeight) {
        height = ktextViewMaxHeight;
    }
    
    if (height == self.previousTextViewContentHeight) {
        return;
    }
    
    self.previousTextViewContentHeight = height;
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
//    [self.parent mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(self.heigth -100);
//    }];
}


#pragma mark - Public

- (void)clearInputViewText
{
    self.textView.text = @"";
    [self _updatetextViewHeight];
}



@end
