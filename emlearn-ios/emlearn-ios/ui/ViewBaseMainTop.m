#import "ViewBaseMainTop.h"
#import <Masonry.h>
#import "EMLearnOption.h"
#import "EMDefines.h"
//页头
@interface ViewBaseMainTop ()
    @property (nonatomic, strong) UIButton *leaveConfrButton;
    @property (nonatomic, strong) UIButton *uploadButton;
@end

@implementation ViewBaseMainTop

- (instancetype)initWithConfVC:(UIViewController*)confVC
{
    self = [super init];
    if(self) {
        self.confVC = confVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:kColor_LightGray];
    
    UILabel *roomNameTitleLable = [[UILabel alloc] initWithFrame:CGRectZero];
    roomNameTitleLable.text = @"房间名称：";
    roomNameTitleLable.textColor = kColor_Purple;
    [roomNameTitleLable setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:roomNameTitleLable];
    roomNameTitleLable.textAlignment = NSTextAlignmentRight;
    [roomNameTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(@25);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.top.equalTo(self.view.mas_top).offset(5);
    }];
    
    self.roomNameLable = [[UILabel alloc] initWithFrame:CGRectZero];
    self.roomNameLable.text = [EMLearnOption sharedOptions].roomName;
    self.roomNameLable.textColor = [UIColor blackColor];
    [self.roomNameLable setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:self.roomNameLable];
    self.roomNameLable.textAlignment = NSTextAlignmentLeft;
    [self.roomNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@100);
        make.height.mas_equalTo(@25);
        make.left.equalTo(roomNameTitleLable.mas_right);
        make.top.equalTo(self.view.mas_top).offset(5);
    }];
    
    UIImageView *timeImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    timeImage.image = [UIImage imageNamed:@"main_time"];
    timeImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:timeImage];
    [timeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@20);
        make.height.mas_equalTo(@20);
        make.left.equalTo(self.roomNameLable.mas_right).offset(20);
        make.top.equalTo(self.view.mas_top).offset(7);
    }];
        
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    [self.timeLabel setFont:[UIFont fontWithName:@"Arial" size:20]];
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@100);
        make.height.equalTo(@20);
        make.top.equalTo(self.view.mas_top).offset(7);
        make.left.equalTo(timeImage.mas_right).offset(10);
    }];
    
    
    
    self.leaveConfrButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.leaveConfrButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.leaveConfrButton setImage:[UIImage imageNamed:@"main_leave"] forState:UIControlStateNormal];
    //[self.leaveConfrButton setTitle:@"离开会议" forState:UIControlStateNormal];
    //[self.leaveConfrButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.leaveConfrButton setTintColor:[UIColor blackColor]];
    [self.leaveConfrButton addTarget:self.confVC action:@selector(leaveAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leaveConfrButton];
    [self.leaveConfrButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view).with.offset(-20);
    }];

    self.uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.uploadButton setImage:[UIImage imageNamed:@"file"] forState:UIControlStateNormal];
    //[self.leaveConfrButton setTitle:@"离开会议" forState:UIControlStateNormal];
    //[self.leaveConfrButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.uploadButton setTintColor:[UIColor blackColor]];
    [self.uploadButton addTarget:self.confVC action:@selector(setAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.uploadButton];
    [self.uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.leaveConfrButton.mas_left);
    }];
    [self startTimer];
}


- (void)startTimer
{
    _timeLength = 0;
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int hour = _timeLength / 3600;
    int m = (_timeLength - hour * 3600) / 60;
    int s = _timeLength - hour * 3600 - m * 60;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, m, s];
}

@end
