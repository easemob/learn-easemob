#import "ViewLogin.h"
#import "AppDelegate.h"
#import "EMLearnOption.h"
#import "RightTextField.h"
#import <Hyphenate/EMOptions+PrivateDeploy.h>
#import <Hyphenate/Hyphenate.h>
#import <Masonry.h>
#import "EMDefines.h"

#import "ViewOneMain.h"
#import "ViewSmallMain.h"

static BOOL gIsInitializedSDK = NO;
static BOOL g_IsLogin = NO;
int kHeightStart = 100;
//登录页面
@interface ViewLogin ()
@property (nonatomic) NSString* roomName;
@property (nonatomic) UILabel* versionLable;
@property (nonatomic) UIActivityIndicatorView * activity;
//@property (nonatomic) UITextField* maxVideoCount;
//@property (nonatomic) UITextField* maxTalkerCount;
@end


@implementation ViewLogin

- (void)viewDidLoad {
    NSLog(@"login view viewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSDK];
    [self initView];
}
-(void)initView{
    [self.view setBackgroundColor:UIColor.whiteColor];
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    
    UIImage* image = [UIImage imageNamed:@"login_left"];
    self.conferencelogo = [[UIImageView alloc] initWithImage:image];
    //self.conferencelogo.frame = CGRectMake(100, 130, mainBounds.size.width-200, 100);
    [self.conferencelogo setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:self.conferencelogo];
    [self.conferencelogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@98);
        make.height.equalTo(@34);
        make.left.mas_equalTo(self.view).offset(74);
        make.top.mas_equalTo(self.view).offset(68);
    }];
    UIView *uLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 1)];
    uLine.backgroundColor = kColor_Purple;
    [self.view addSubview:uLine];
    [uLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.equalTo(@35);
        make.left.equalTo(self.view).offset(187);
        make.top.equalTo(self.view).offset(66);
    }];
    
    UILabel* lable = [[UILabel alloc] initWithFrame:CGRectMake(100, kHeightStart-70, mainBounds.size.width-200, 40)];
    lable.text = @"教育 Demo";
    lable.textAlignment = NSTextAlignmentCenter;
    [lable setFont:[UIFont systemFontOfSize:18]];
    lable.textColor = kColor_Purple;
    [self.view addSubview:lable];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@140);
        make.height.equalTo(@28);
        make.left.mas_equalTo(self.view).offset(198);
        make.top.mas_equalTo(self.view).offset(70);
    }];
    int lableWidth = 120;
    int lableHeight = 21;
    int lableOffest = 5;
    int inputOffest = 27;
    int leftOffest = 44;
    UILabel *titleLable1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 1)];
    titleLable1.text = @"房间名/Room";
    titleLable1.textAlignment = NSTextAlignmentLeft;
    [titleLable1 setFont:[UIFont systemFontOfSize:14]];
    titleLable1.textColor = UIColor.grayColor;
    [self.view addSubview:titleLable1];
    [titleLable1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lableHeight);
        make.width.mas_equalTo(lableWidth);
        make.left.equalTo(self.view).offset(leftOffest);
        make.top.equalTo(self.view).offset(127);
    }];
    
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(60, kHeightStart, mainBounds.size.width - 120, 40)];
    self.nameField.delegate = self;
    self.nameField.borderStyle = UITextBorderStyleNone;
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"请输入房间名称" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:self.nameField.font}];
//    self.nameField.attributedPlaceholder = attrString;
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.font = [UIFont systemFontOfSize:17];
    self.nameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.layer.borderWidth = 2.0f;
    self.nameField.layer.cornerRadius = 5;
    self.nameField.layer.borderColor = kColor_Purple.CGColor;
    self.nameField.tag = 100;
    self.nameField.keyboardType = UIKeyboardTypeASCIICapable;
    self.nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.nameField.textColor = [UIColor blackColor];
    [self.nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.left.equalTo(self.view).with.offset(leftOffest);
        make.right.equalTo(self.view).with.offset(-leftOffest);
        make.top.equalTo(titleLable1.mas_bottom).offset(lableOffest);
    }];
    
    
    self.errorLable = [[UILabel alloc] initWithFrame:CGRectMake(60, kHeightStart, mainBounds.size.width-120, 30)];
    [self.errorLable setTextColor:[UIColor redColor]];
    self.errorLable.font = [UIFont systemFontOfSize:14];
    self.errorLable.text = @"";
    [self.view addSubview:self.errorLable];
    [self.errorLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.left.equalTo(self.view).with.offset(leftOffest);
        make.right.equalTo(self.view).with.offset(-60);
        make.top.equalTo(self.nameField.mas_bottom).offset(-10);
    }];
    
    UILabel *titleLable2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 1)];
    titleLable2.text = @"房间密码/Key";
    titleLable2.textAlignment = NSTextAlignmentLeft;
    [titleLable2 setFont:[UIFont systemFontOfSize:14]];
    titleLable2.textColor = UIColor.grayColor;
    [self.view addSubview:titleLable2];
    [titleLable2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lableHeight);
        make.width.mas_equalTo(lableWidth);
        make.left.equalTo(self.view).offset(50);
        make.top.equalTo(self.nameField.mas_bottom).offset(inputOffest);
    }];
    
    UIImageView *passFieldImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    passFieldImage.image = [UIImage imageNamed:@"pass_right"];
    passFieldImage.contentMode = UIViewContentModeCenter;
    
    self.passField = [[RightTextField alloc] initWithFrame:CGRectZero Icon:passFieldImage];
    self.passField.delegate = self;
    self.passField.borderStyle = UITextBorderStyleNone;
//    NSAttributedString *passAttrString = [[NSAttributedString alloc] initWithString:@"请输入房间密码" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:self.nameField.font}];
//    self.passField.attributedPlaceholder = passAttrString;
    self.passField.returnKeyType = UIReturnKeyDone;
    self.passField.font = [UIFont systemFontOfSize:17];
    self.passField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.passField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.passField.leftViewMode = UITextFieldViewModeAlways;
    self.passField.layer.borderWidth = 2.0f;
    self.passField.layer.cornerRadius = 5;
    self.passField.layer.borderColor = kColor_Purple.CGColor;
    self.passField.tag = 100;
    self.passField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passField.textColor = [UIColor blackColor];
    self.passField.rightViewMode = UITextFieldViewModeAlways;
    [self.passField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.passField];
    [self.passField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.left.equalTo(self.view).with.offset(leftOffest);
        make.right.equalTo(self.view).with.offset(-leftOffest);
        make.top.equalTo(titleLable2.mas_bottom).offset(lableOffest);
    }];
    
    
    
    
    UILabel *titleLable3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 1)];
    titleLable3.text = @"房间类型/Class";
    titleLable3.textAlignment = NSTextAlignmentLeft;
    [titleLable3 setFont:[UIFont systemFontOfSize:14]];
    titleLable3.textColor = UIColor.grayColor;
    [self.view addSubview:titleLable3];
    [titleLable3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lableHeight);
        make.width.mas_equalTo(lableWidth);
        make.left.equalTo(self.view).offset(leftOffest);
        make.top.equalTo(self.passField.mas_bottom).offset(inputOffest);
    }];
    
    //dropdown
    EBDropdownListItem *confrItem1 = [[EBDropdownListItem alloc] initWithItem:@"1" itemName:@"1v1"];

    EBDropdownListItem *confrItem2 = [[EBDropdownListItem alloc] initWithItem:@"2" itemName:@"小班课"];

    self.confrTypeDropDown = [[EBDropdownListView alloc] initWithDataSource:@[confrItem1, confrItem2]];
    self.confrTypeDropDown.backgroundColor = UIColor.whiteColor;
    self.confrTypeDropDown.frame = CGRectMake(60, kHeightStart, mainBounds.size.width - 120, 40);
    [self.confrTypeDropDown setViewBorder:2.0f borderColor:kColor_Purple cornerRadius:2];
    [self.view addSubview:self.confrTypeDropDown];
    [self.confrTypeDropDown setDropdownListViewSelectedBlock:^(EBDropdownListView *dropdownListView) {
        NSString *msgString = [NSString stringWithFormat:
                               @"selected name:%@  id:%@  index:%ld"
                               , dropdownListView.selectedItem.itemName
                               , dropdownListView.selectedItem.itemId
                               , dropdownListView.selectedIndex];
        NSLog(@"%@", msgString);
        if([dropdownListView.selectedItem.itemName  isEqual: @"1v1"]){
            [EMLearnOption sharedOptions].confrType = CONFR_TYPE_ONE;
        }else if([dropdownListView.selectedItem.itemName  isEqual: @"小班课"]){
            [EMLearnOption sharedOptions].confrType = CONFR_TYPE_SMALL;
        }
        
    }];
    [self.confrTypeDropDown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.left.equalTo(self.view).with.offset(leftOffest);
        make.right.equalTo(self.view).with.offset(-leftOffest);
        make.top.equalTo(titleLable3.mas_bottom).offset(lableOffest);
    }];
    [self.confrTypeDropDown selectedItemAtIndex:0];

    UILabel *titleLable4 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 1)];
    titleLable4.text = @"用户名称/Name";
    titleLable4.textAlignment = NSTextAlignmentLeft;
    [titleLable4 setFont:[UIFont systemFontOfSize:14]];
    titleLable4.textColor = UIColor.grayColor;
    [self.view addSubview:titleLable4];
    [titleLable4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lableHeight);
        make.width.mas_equalTo(lableWidth);
        make.left.equalTo(self.view).offset(leftOffest);
        make.top.equalTo(self.confrTypeDropDown.mas_bottom).offset(inputOffest);
    }];
    self.nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(60, kHeightStart, mainBounds.size.width - 120, 40)];
    self.nickNameField.delegate = self;
    self.nickNameField.borderStyle = UITextBorderStyleNone;
//    NSAttributedString *nickNameAttrString = [[NSAttributedString alloc] initWithString:@"请输入昵称" attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:self.nameField.font}];
//    self.nickNameField.attributedPlaceholder = nickNameAttrString;
    self.nickNameField.returnKeyType = UIReturnKeyDone;
    self.nickNameField.font = [UIFont systemFontOfSize:17];
    self.nickNameField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.nickNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nickNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.nickNameField.leftViewMode = UITextFieldViewModeAlways;
    self.nickNameField.layer.borderWidth = 2.0f;
    self.nickNameField.layer.cornerRadius = 5;
    self.nickNameField.layer.borderColor = kColor_Purple.CGColor;
    self.nickNameField.tag = 100;
    self.nickNameField.keyboardType = UIKeyboardTypeASCIICapable;
    self.nickNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.nickNameField.textColor = [UIColor blackColor];
    [self.nickNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.nickNameField];
    [self.nickNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.left.equalTo(self.view).with.offset(leftOffest);
        make.right.equalTo(self.view).with.offset(-leftOffest);
        make.top.equalTo(titleLable4.mas_bottom).offset(lableOffest);
    }];
    
    
    NSMutableArray* buttons = [NSMutableArray arrayWithCapacity:2];
    RadioButton* teacherBtn = [[RadioButton alloc] initWithFrame:CGRectZero];
    [teacherBtn addTarget:self action:@selector(onRadioButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
//        btnRect.origin.y += 40;
    [teacherBtn setTitle:@"老师" forState:UIControlStateNormal];
    [teacherBtn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    [teacherBtn setTitleColor:kColor_Purple forState:UIControlStateSelected];
    teacherBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [teacherBtn setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    [teacherBtn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
    teacherBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    teacherBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    [self.view addSubview:teacherBtn];
    [teacherBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
        make.height.equalTo(@40);
        make.left.equalTo(self.view).offset(leftOffest+80);
        make.top.equalTo(self.nickNameField.mas_bottom).offset(inputOffest);
    }];
    [buttons addObject:teacherBtn];
    
    RadioButton* studentBtn = [[RadioButton alloc] initWithFrame:CGRectZero];
    [studentBtn addTarget:self action:@selector(onRadioButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
//        btnRect.origin.y += 40;
    [studentBtn setTitle:@"学生" forState:UIControlStateNormal];
    [studentBtn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    [studentBtn setTitleColor:kColor_Purple forState:UIControlStateSelected];
    studentBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [studentBtn setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    [studentBtn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
    studentBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    studentBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    [self.view addSubview:studentBtn];
    [studentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
        make.height.equalTo(@40);
        make.left.equalTo(teacherBtn.mas_right);
        make.top.equalTo(self.nickNameField.mas_bottom).offset(inputOffest);
    }];
    [buttons addObject:studentBtn];
    
    [teacherBtn setGroupButtons:buttons]; // Setting buttons into the group
    [teacherBtn setSelected:YES]; // Making the first button initially selected

    
    
    self.joinRoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.joinRoomButton.frame = CGRectMake(100, kHeightStart, mainBounds.size.width-200, 40);
    self.joinRoomButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.joinRoomButton setTitle:@"加入房间" forState:UIControlStateNormal];
//    [self.joinRoomButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.joinRoomButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    //设置按下状态的颜色
    [self.joinRoomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.joinRoomButton setBackgroundColor:kColor_DeepPurple];
//    [self.joinRoomButton setEnabled:NO];
    //self.joinAsSpeaker.layer.borderWidth = 0.5;
    self.joinRoomButton.layer.cornerRadius = 1;
    [self.view addSubview:_joinRoomButton];
    [self.joinRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.left.equalTo(self.view).with.offset(leftOffest);
        make.right.equalTo(self.view).with.offset(-leftOffest);
        make.top.equalTo(studentBtn.mas_bottom).with.offset(30);
    }];

    UILabel *descLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 1)];
    descLable.text = @"本产品由环信提供 当前版本：1.4.1";
    descLable.textAlignment = NSTextAlignmentCenter;
    [descLable setFont:[UIFont systemFontOfSize:14]];
    descLable.textColor = UIColor.grayColor;
    [self.view addSubview:descLable];
    [descLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.equalTo(self.view).with.offset(leftOffest);
        make.right.equalTo(self.view).with.offset(-leftOffest);
        make.top.equalTo(self.joinRoomButton.mas_bottom).offset(50);
    }];
    
    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _activity.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view addSubview:_activity];
    [_activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _activity.hidesWhenStopped = YES;
}
- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
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
    NSLog(@"%@",touches);
}

//-(void)textChange:(UITextField*)field {
//    _roomName = self.nameField.text;
//    if([_roomName length] > 0)
//    {
//        [self.joinRoomButton setEnabled:YES];
//        [self.joinRoomButton setBackgroundColor:kColor_Purple];
//
//    }
//    else{
//        [self.joinRoomButton setEnabled:NO];
//        [self.joinRoomButton setBackgroundColor:kColor_Purple];
//    }
//}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    
    int kmaxLength = 18;//设置最大输入值
    int len =[toBeString length];
    if(len > kmaxLength){
        textField.text = [toBeString substringToIndex: len - 1];
        
    }
    if(![self validateString:toBeString])
    {
        textField.text = [toBeString substringToIndex: len - 1];
    }
}

-(BOOL)validateString:(NSString*)str
{
    // 编写正则表达式
    NSString *regex = @"^[\u4e00-\u9fa5A-Za-z0-9_-]*$";
    // 创建谓词对象并设定条件表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    // 字符串判断，然后BOOL值
    BOOL result = [predicate evaluateWithObject:str];
    return result;
}

-(void) onRadioButtonValueChanged:(RadioButton*)sender
{
    // Lets handle ValueChanged event only for selected button, and ignore for deselected
    if(sender.selected) {
        if([sender.titleLabel.text  isEqual: @"学生"]){
            [EMLearnOption sharedOptions].roleType = ROLE_TYPE_STUDENT;
        }else if([sender.titleLabel.text  isEqual: @"老师"]){
            [EMLearnOption sharedOptions].roleType = ROLE_TYPE_TEACHER;
        }
    }
}

-(void)userLogin:(NSString *)username password:(NSString*)pass{
    [[EMClient sharedClient] loginWithUsername:username password:pass completion:^(NSString *aUsername, EMError *aError) {
        if(!aError){
            [self initManager];
            g_IsLogin = YES;
            [self joinRoom:[EMLearnOption sharedOptions].isJoinAsAudience?EMConferenceRoleAudience:EMConferenceRoleSpeaker];
        }
    }];
}

- (void)loginAction
{
    self.joinRoomButton.enabled = NO;
    self.errorLable.text = @"";
    if([self.nameField.text length] < 3){
        self.errorLable.text = @"房间名称不能少于3位";
        self.joinRoomButton.enabled = YES;
        return;
    }
    
    [_activity startAnimating];
    NSMutableDictionary *param = 
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"name":self.nameField.text,
            @"username":self.nickNameField.text,
            @"password":self.passField.text,
            @"role":[EMLearnOption sharedOptions].roleType,
            @"confrType":[EMLearnOption sharedOptions].confrType
        }];
    [ViewBase HttpPost:@"Conference/Entry" paramaters:param headers:nil callBlock:^void (id object,NSError *error){
        if ([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *dictionary = (NSDictionary *)object;
            NSString *code = [dictionary objectForKey:@"code"];
            if([code isEqual: @"1"]){
                NSDictionary *dataDict = [dictionary objectForKey:@"data"];
                NSString *accessToken = [dataDict objectForKey:@"EmToken"];
                NSString *username = [dataDict objectForKey:@"EmName"];
                NSString *userId = [dataDict objectForKey:@"EmUserId"];
                NSString *confrId = [dataDict objectForKey:@"EmconfrId"];
                NSString *chatId = [dataDict objectForKey:@"EmChatId"];
                NSString *sysToken = [dataDict objectForKey:@"SysToken"];
                [EMLearnOption sharedOptions].chatRoomId = chatId;
                [EMLearnOption sharedOptions].roomId = confrId;
                [EMLearnOption sharedOptions].userName = username;
                [EMLearnOption sharedOptions].userId = userId;
                [EMLearnOption sharedOptions].roomName = self.nameField.text;
                [EMLearnOption sharedOptions].roomPswd = self.passField.text;
                [EMLearnOption sharedOptions].nickName = self.nickNameField.text;
                
                
                
                NSString *sysAccessToken = @"";
                sysAccessToken = [sysAccessToken stringByAppendingFormat:@"%@ %@", @"Bearer",sysToken];
                [EMLearnOption sharedOptions].sysAccessToken = sysAccessToken;
                NSLog(@"Dersialized JSON Dictionary = %@", dictionary);
                NSLog(@"confrId:%@ chatId:%@",confrId,chatId);
                NSLog(@"Access Token:%@",sysAccessToken);
                if([[EMClient sharedClient] isLoggedIn]){
                    [[EMClient sharedClient] logout:NO completion:^(EMError *aError) {
                        [self userLogin:username password:@"1"];
                    }];
                }else{
                    [self userLogin:username password:@"1"];
                }
            }else if([code isEqual: @"-15"]){
                [self showHint:@"包含多个老师"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.joinRoomButton.enabled = YES;
                    if(self.activity.isAnimating){
                        [self.activity stopAnimating];
                    }
                });
                
                
            }else if([code isEqual: @"-16"]){
                [self showHint:@"包含多个学生"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.joinRoomButton.enabled = YES;
                    if(self.activity.isAnimating){
                        [self.activity stopAnimating];
                    }
                });
            }else if([code isEqual: @"-1"]){
                [self showHint:@"服务器错误"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.joinRoomButton.enabled = YES;
                    if(self.activity.isAnimating){
                        [self.activity stopAnimating];
                    }
                });
            }
            
        }
        
    }];
    
}


- (void)joinRoom:(EMConferenceRole)role 
{
    
    NSString* roomName = [EMLearnOption sharedOptions].roomName;
    NSString* roomPswd = [EMLearnOption sharedOptions].roomPswd;
    NSString* roomId = [EMLearnOption sharedOptions].roomId;

    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, EMError *aError) = ^(EMCallConference *aCall, EMError *aError) {
        if (aError) {
            if(aError.code == EMErrorInvalidPassword){
                weakself.errorLable.text = @"密码错误";
            }else
            if (aError.code == EMErrorCallCDNError) {
                weakself.errorLable.text = @"cdn推流设置错误";
            }else
            if (aError.code == EMErrorCallSpeakerFull){
                [self showHint:@"主播人数已满"]   ;

            }else{
                weakself.errorLable.text = aError.errorDescription;
            }
            weakself.joinRoomButton.enabled = YES;
            if(weakself.activity.isAnimating) {
                [weakself.activity stopAnimating];
            }
            return ;
        }
        [EMLearnOption sharedOptions].conference = aCall;
        [EMLearnOption sharedOptions].muteAll = NO;

        if([[EMLearnOption sharedOptions].confrType  isEqual: CONFR_TYPE_ONE]){
            ViewOneMain* viewOneMain = [[ViewOneMain alloc] initWithConfence];
            if(weakself.activity.isAnimating) {
                [weakself.activity stopAnimating];
            }
            viewOneMain.modalPresentationStyle = 0;
            [weakself presentViewController:viewOneMain animated:YES completion:nil];
        }else if([[EMLearnOption sharedOptions].confrType  isEqual: CONFR_TYPE_SMALL]){
            ViewSmallMain* viewSmallMain = [[ViewSmallMain alloc] initWithConfence];
            if(weakself.activity.isAnimating) {
                [weakself.activity stopAnimating];
            }
            viewSmallMain.modalPresentationStyle = 0;
            [weakself presentViewController:viewSmallMain animated:YES completion:nil];
        }
        
        weakself.joinRoomButton.enabled = YES;
        [[EMClient sharedClient].conferenceManager enableStatistics:YES];
    };
    
    
    // [[[EMClient sharedClient] conferenceManager] joinRoom:roomName password:roomPswd role:role roomConfig:roomConfig completion:block];
    [[[EMClient sharedClient] conferenceManager] joinConferenceWithConfId:roomId password:roomPswd completion:block];
}

-(void)initSDK
{
    if (!gIsInitializedSDK) {
        gIsInitializedSDK = YES;
        EMLearnOption* option = [EMLearnOption sharedOptions];
        EMOptions *options = [EMOptions optionsWithAppkey:option.EASEMOB_APPKEY];
        options.enableConsoleLog = YES;
        if(option.specifyServer)
        {
            options.enableDnsConfig = NO;
            options.chatPort = option.chatPort;
            options.chatServer = option.chatServer;
            options.restServer = option.restServer;
        }
        [[EMClient sharedClient] initializeSDKWithOptions:options];
    }
}


-(void) initManager
{
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].conferenceManager addDelegate:self delegateQueue:nil];
    
}
@end

