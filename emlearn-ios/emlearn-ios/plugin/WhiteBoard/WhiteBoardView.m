
#import "WhiteBoardView.h"
#import <Masonry.h>
#import "AlertWin.h"
@interface WhiteBoardView ()
@property (nonatomic) WKWebView *wkWebView;
@property (nonatomic) EMWhiteboard* wb;
@property (nonatomic) UIButton* backButton;
@property (nonatomic) UIButton* exitButton;
@property (nonatomic) UIButton* interactButton;
@end

@implementation WhiteBoardView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    // AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;//允许转成横屏
    // appDelegate.curOrientationMask = UIInterfaceOrientationMaskLandscapeLeft;
    // appDelegate.allowRotation = NO;
    //appDelegate.orientation = UIInterfaceOrientationLandscapeLeft;
    
    //[appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    //调用横屏代码

    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];

    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];

    [UIViewController attemptRotationToDeviceOrientation];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;//允许转成横屏
//    appDelegate.allowRotation = YES;
}

- (instancetype)initWithWBUrl:(EMWhiteboard*)wb
{
    self = [super init];
    if(self) {
        _wb = wb;
    }
    return self;
}

-(BOOL)isCreator
{
    if(self.wb && [self.wb.roomURL length] > 0) {
        NSArray* array = [self.wb.roomURL componentsSeparatedByString:@"?"];
        if([array count] > 1) {
            NSString* params = [array objectAtIndex:1];
            NSArray* paramsArray = [params componentsSeparatedByString:@"&"];
            for(NSString* param in paramsArray) {
                NSArray* paramArray = [param componentsSeparatedByString:@"="];
                NSString* key = [paramArray objectAtIndex:0];
                if([key isEqualToString:@"isCreater"]) {
                    NSString* value = [paramArray objectAtIndex:1];
                    if([value isEqualToString:@"true"]) {
                        return YES;
                    }
                    break;
                }
            }
        }
    }
    return NO;
}

-(void)setupSubviews
{
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.preferences = [WKPreferences new];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    self.wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:config];
    [self.wkWebView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.wb.roomURL]]];
    [self.view addSubview:self.wkWebView];
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.equalTo(self.view);
    }];
    
    if([self isCreator]){
        self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.exitButton.frame = CGRectMake(self.view.bounds.size.width - 100, 50, 40, 40);
        [self.exitButton setImage:[UIImage imageNamed:@"wb-exit"] forState:UIControlStateNormal];
//        [self.exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.exitButton];
        [self.exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(1.9);
            make.centerY.equalTo(self.view).multipliedBy(0.5);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
        }];
        
        self.interactButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.interactButton.frame = CGRectMake(self.view.bounds.size.width - 100, 50, 40, 40);
        [self.interactButton setImage:[UIImage imageNamed:@"wb-interact"] forState:UIControlStateNormal];
//        [self.interactButton addTarget:self action:@selector(interactAction) forControlEvents:UIControlEventTouchUpInside];
        [self.interactButton setHidden:YES];
        [self.view addSubview:self.interactButton];
        [self.interactButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(1.9);
            make.centerY.equalTo(self.view).multipliedBy(0.8);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
        }];
    }
}





-(void)interactAction
{
//    __weak typeof(self) weakself = self;
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//    UIAlertAction *allowInteract = [UIAlertAction actionWithTitle:@"允许白板成员互动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[[EMClient sharedClient] conferenceManager] updateWhiteboardRoomWithRoomId:weakself.wb.roomId username:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken intract:YES allUsers:YES serventIds:nil completion:^(EMError *aError) {
//            if(!aError) {
//                [weakself.wkWebView reload];
//                NSLog(@"set white err:%@",aError.errorDescription);
//            }else{
//                [AlertWin showInfoAlert:@"操作白板失败"];
//            }
//        }];
//    }];
//    [alertController addAction:allowInteract];
//
//    UIAlertAction *forbidInteract = [UIAlertAction actionWithTitle:@"禁止白板成员互动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[[EMClient sharedClient] conferenceManager] updateWhiteboardRoomWithRoomId:weakself.wb.roomId username:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken intract:NO allUsers:YES serventIds:nil completion:^(EMError *aError) {
//            if(aError) {
//                NSLog(@"set white err:%@",aError.errorDescription);
//            }else
//                [AlertWin showInfoAlert:@"操作白板成功"];
//        }];
//    }];
//    [alertController addAction:forbidInteract];
//
//    [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];
//
//    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)exitAction
{
//    __weak typeof(self) weakself = self;
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"退出后将销毁白板,是否继续" preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[[EMClient sharedClient] conferenceManager] destroyWhiteboardRoomWithUsername:[EMClient sharedClient].currentUsername userToken:[EMClient sharedClient].accessUserToken roomId:self.wb.roomId completion:^(EMError *aError) {
//            if(!aError) {
//                [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:@"whiteBoard" completion:^(EMError *aError) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.navigationController popViewControllerAnimated:YES];
//                    });
//                }];
//            }else{
//                [EMAlertController showErrorAlert:[NSString stringWithFormat:@"退出失败：%@",aError.errorDescription]];
//            }
//        }];
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//       
//    }]];
//    [self presentViewController:alert animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
