#import "EmKeyBoard.h"
#import <Masonry.h>
#import "AlertWin.h"
@interface EmKeyBoard ()<UITextViewDelegate>
    
@end


@implementation EmKeyBoard

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.grayColor;
        self.inputField = [[EMTextView alloc] initWithFrame:CGRectZero];
        self.inputField.placeholder = @"请输入消息内容";
        self.inputField.font = [UIFont systemFontOfSize:14];
        self.inputField.returnKeyType = UIReturnKeySend;
        self.inputField.backgroundColor = UIColor.whiteColor;
        self.inputField.delegate = self;
        [self addSubview:self.inputField];
        [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(10, 10, 10, 150));
        }];

        UIButton * sendBut = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [sendBut setBackgroundColor:[UIColor whiteColor]];
        sendBut.layer.cornerRadius = 18;
        sendBut.titleLabel.font = [UIFont systemFontOfSize:14];
        [sendBut setTitle:@"发送" forState:UIControlStateNormal];
        [sendBut addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendBut];
        [sendBut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self).multipliedBy(0.17);
            make.height.equalTo(self.mas_height).multipliedBy(0.3);
            make.left.equalTo(self.inputField.mas_right).offset(15);
            make.top.equalTo(self.mas_top).offset(20);
        }];

        UIButton * cancelBut = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelBut setBackgroundColor:[UIColor whiteColor]];
        cancelBut.layer.cornerRadius = 18;
        cancelBut.titleLabel.font = [UIFont systemFontOfSize:14];
        [cancelBut setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBut addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBut];
        [cancelBut mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self).multipliedBy(0.17);
            make.height.equalTo(self).multipliedBy(0.3);
            make.left.equalTo(self.inputField.mas_right).offset(15);
            make.top.equalTo(sendBut.mas_bottom).offset(20);
        }];

        
    }
    [self.inputField becomeFirstResponder];
    return self;

}

- (void)sendAction
{
    NSString * inputText = self.inputField.text;
    if(inputText == @""){
        [AlertWin showInfoAlert:@"无内容"];
        return;
    }
    if (self.emdelegate && [self.emdelegate respondsToSelector:@selector(sendText:)]) {
        [self.emdelegate sendText:inputText ];
    }
    [self cancelAction];
}

- (void)cancelAction
{
    if (self.emdelegate && [self.emdelegate respondsToSelector:@selector(closeView)]) {
        [self.emdelegate closeView];
    }
    [self.inputView resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
     //回收键盘,取消第一响应者
     [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{

    if (self.emdelegate && [self.emdelegate respondsToSelector:@selector(sendText:)]) {
       if ([text isEqualToString:@"\n"]) {
           NSString * inputText = self.inputField.text;
           if(inputText == @""){
               [AlertWin showInfoAlert:@"无内容"];
               return YES;
           }
           [self.emdelegate sendText:inputText ];
           [self cancelAction];
            return NO;
        }
        
    }

    return YES;
}
//
//- (void)textViewDidChange:(UITextView *)textView
//{
//    if (self.emdelegate && [self.emdelegate respondsToSelector:@selector(inputViewDidChange:)]) {
//        [self.emdelegate inputViewDidChange:self.textView];
//    }
//}
@end
