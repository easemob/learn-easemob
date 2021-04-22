//
//  JXPageView.m
//  JXChannelSegment
//
//  Created by JackXu on 16/9/16.
//  Copyright © 2016年 BFMobile. All rights reserved.
//

#import "TableView.h"
#import "UserInfo.h"
#import "ViewBase.h"
#import <Masonry.h>
#import <Hyphenate/Hyphenate.h>
#import "EMLearnOption.h"
#import "AlertWin.h"
#import "EMDefines.h"
@interface TableView()
    @property (nonatomic,strong) NSMutableDictionary *userDictionary;
    @property (nonatomic,strong) UITableView *tableView;
@end


@implementation TableView

- (instancetype)init:(NSMutableDictionary *)userDictionary
{
    self = [super init];
    if (self) {
        UIView * topView = [self _setupTopTitle];
        
        self.tableView= [[UITableView alloc] init];
        self.tableView.rowHeight = 30;
        self.tableView.dataSource = self;
        _tableView.delegate = self;
        self.tableView.backgroundColor = UIColor.whiteColor;
        [self addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(self);
            make.left.equalTo(self);
            make.top.equalTo(topView.mas_bottom);
            make.bottom.equalTo(self);
        }];
        self.userDictionary =userDictionary;
//        NSMutableDictionary *param =
//        [NSMutableDictionary dictionaryWithDictionary:@{
//            @"confrId":[EMLearnOption sharedOptions].conference.confId,
//        }];
//        NSMutableDictionary *header =
//        [NSMutableDictionary dictionaryWithDictionary:@{
//            @"Authorization":[EMLearnOption sharedOptions].sysAccessToken,
//        }];
//        [ViewBase HttpGet:@"Conference/GetConfrOper" paramaters:param headers:header callBlock:^void (id object,NSError *error){
//            if ([object isKindOfClass:[NSDictionary class]]){
//                NSDictionary *dictionary = (NSDictionary *)object;
//                NSString *code = [dictionary objectForKey:@"code"];
//                if([code isEqual: @"1"]){
//                    NSMutableArray *itemArr = [[NSMutableArray alloc] init];
//                    NSArray *dataArrs = [dictionary objectForKey:@"data"];
//                    for (int i = 0; i < dataArrs.count; i++)
//                    {
//                        NSDictionary *iDict = dataArrs[i];
//                        UserInfo *ui = [[UserInfo alloc]init];
//                        ui.nickName = (NSString *)[iDict objectForKey:@"NickName"];
//                        ui.name = (NSString *)[iDict objectForKey:@"Name"];
//                        ui.isWhite = (BOOL)[iDict objectForKey:@"IsWhite"];
//                        ui.isMessage = (BOOL)[iDict objectForKey:@"IsMessage"];
//
//                        UserInfo * ru = [userDictionary objectForKey:ui.name];
//                        ui.isAudio = ru.isAudio;
//                        ui.isVideo = ru.isVideo;
//                        [itemArr addObject:ui];
//
//                    }
//                    [self setItems:itemArr];
//                    dispatch_async(dispatch_get_main_queue(), ^(void){
//                        [self.tableView reloadData];
//                    });
//
//
//                }
//
//            }
//
//        }];
    }
    
    return self;
}

- (UIView *)_setupTopTitle{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * 06, 40)];
    topView.backgroundColor = kColor_Blue;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = @"学生列表";
    [topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_top).offset(4);
        make.left.equalTo(topView).offset(15);
        make.right.equalTo(topView).offset(-5);
    }];
    
    
    UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [closeButton setImage:[UIImage imageNamed:@"main_leave"] forState:UIControlStateNormal];
    //[self.leaveConfrButton setTitle:@"离开会议" forState:UIControlStateNormal];
    //[self.leaveConfrButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeButton setTintColor:[UIColor blackColor]];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        make.top.equalTo(topView.mas_top);
        make.right.equalTo(topView).offset(-10);
    }];
    
    [self addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.mas_equalTo(30);
        make.left.equalTo(self);
        make.top.equalTo(self);
    }];
    
    
    return topView;
}

-(void)closeAction{
    self.hidden = YES;
    self.authImgBut.image = [UIImage imageNamed:@"button_auth"];
    self.authImgBut.tag = 0;
}

-(void)setItems:(NSMutableDictionary *)dict{
    self.userDictionary = dict;
    [self.tableView reloadData];
}
-(void)reloadData{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // 在这个方法中设置第section组有多行数据
    return self.userDictionary.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1.定义一个cell的复用标识
    NSString *ID = [[NSString alloc]initWithFormat:@"cell_%ld",(long)indexPath.row ];

    // 2.根据复用标识，从缓存池中取出带有同样的复用标识的cell
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // 3.如果缓存池中没有带有这种复用标识的cell，就创建一个带有这种复用标识的cell
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    cell.backgroundColor = UIColor.whiteColor;
    if(indexPath.row==0){
        UILabel *oneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        oneLabel.text = @"名称";
        oneLabel.font = [UIFont systemFontOfSize:12];
        oneLabel.textColor = [UIColor blackColor];
        [cell addSubview:oneLabel];
        [oneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell).multipliedBy(0.23);
            make.height.equalTo(cell);
            make.left.equalTo(cell).offset(10);
            make.bottom.equalTo(cell);
        }];
        UILabel *towLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        towLabel.text = @"白板";
        towLabel.font = [UIFont systemFontOfSize:12];
        towLabel.textColor = [UIColor blackColor];
        [cell addSubview:towLabel];
        [towLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell).multipliedBy(0.23);
            make.height.equalTo(cell);
            make.left.equalTo(oneLabel.mas_right);
            make.bottom.equalTo(cell);
        }];
//        UILabel *threeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        threeLabel.text = @"消息";
//        threeLabel.font = [UIFont systemFontOfSize:12];
//        threeLabel.textColor = [UIColor blackColor];
//        [cell addSubview:threeLabel];
//        [threeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(cell).multipliedBy(0.18);
//            make.height.equalTo(cell);
//            make.left.equalTo(towLabel.mas_right);
//            make.bottom.equalTo(cell);
//        }];
        UILabel *fourLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        fourLabel.text = @"语音";
        fourLabel.font = [UIFont systemFontOfSize:12];
        fourLabel.textColor = [UIColor blackColor];
        [cell addSubview:fourLabel];
        [fourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell).multipliedBy(0.23);
            make.height.equalTo(cell);
            make.left.equalTo(towLabel.mas_right);
            make.bottom.equalTo(cell);
        }];
        UILabel *fiveLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        fiveLabel.text = @"视频";
        fiveLabel.font = [UIFont systemFontOfSize:12];
        fiveLabel.textColor = [UIColor blackColor];
        [cell addSubview:fiveLabel];
        [fiveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell).multipliedBy(0.23);
            make.height.equalTo(cell);
            make.left.equalTo(fourLabel.mas_right);
            make.bottom.equalTo(cell);
        }];
        
    }else{
        if(self.userDictionary.count == 0 ){
            return cell;
        }
        // 4.设置cell的一些属性
        NSArray * userArray = [self.userDictionary allValues];
        UserInfo * ui = [userArray objectAtIndex:indexPath.row-1];
        UILabel *oneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        oneLabel.text = ui.nickName;
        oneLabel.font = [UIFont systemFontOfSize:12];
        oneLabel.textColor = [UIColor blackColor];
        oneLabel.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:oneLabel];
        [oneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell).multipliedBy(0.23);
            make.height.equalTo(cell);
            make.left.equalTo(cell).offset(2);
            make.bottom.equalTo(cell);
        }];

        UIImageView *towImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        if(ui.isWhite){
            towImage.image = [UIImage imageNamed:@"tv_white_on"];
            
            [towImage setTag:indexPath.row*100 + 11];
        }else{
            towImage.image = [UIImage imageNamed:@"tv_white_off"];
            [towImage setTag:indexPath.row*100 + 10];
        }
        towImage.userInteractionEnabled=YES;
        towImage.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *towImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
        [towImage addGestureRecognizer:towImageTap];
        
        [cell addSubview:towImage];
        [towImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell).multipliedBy(0.1);
            make.height.equalTo(cell);
            make.left.equalTo(oneLabel.mas_right).offset(10);
            make.bottom.equalTo(cell);
        }];

//        UIImageView *threeImage = [[UIImageView alloc] initWithFrame:CGRectZero];
//        if(ui.isMessage){
//            threeImage.image = [UIImage imageNamed:@"tv_message_on"];
//            [threeImage setTag:indexPath.row*100 + 21];
//        }else{
//            threeImage.image = [UIImage imageNamed:@"tv_message_off"];
//            [threeImage setTag:indexPath.row*100 + 20];
//        }
//        threeImage.userInteractionEnabled=YES;
//        threeImage.contentMode = UIViewContentModeScaleAspectFit;
//        UITapGestureRecognizer *threeImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
//        [threeImage addGestureRecognizer:threeImageTap];
//
//
//        [cell addSubview:threeImage];
//        [threeImage mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(cell).multipliedBy(0.18);
//            make.height.equalTo(cell);
//            make.left.equalTo(towImage.mas_right);
//            make.bottom.equalTo(cell);
//        }];

        UIImageView *fourImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        if(ui.isAudio){
            fourImage.image = [UIImage imageNamed:@"tv_audio_on"];
            [fourImage setTag:indexPath.row*100 + 31];
        }else{
            fourImage.image = [UIImage imageNamed:@"tv_audio_off"];
            [fourImage setTag:indexPath.row*100 + 30];
        }
        fourImage.userInteractionEnabled=YES;
        fourImage.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *fourImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
        [fourImage addGestureRecognizer:fourImageTap];
        

        [cell addSubview:fourImage];
        [fourImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell).multipliedBy(0.1);
            make.height.equalTo(cell);
            make.left.equalTo(towImage.mas_right).offset(25);
            make.bottom.equalTo(cell);
        }];

        UIImageView *fiveImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        if(ui.isVideo){
            fiveImage.image = [UIImage imageNamed:@"tv_video_on"];
            [fiveImage setTag:indexPath.row*100 + 41];
        }else{
            fiveImage.image = [UIImage imageNamed:@"tv_video_off"];
            [fiveImage setTag:indexPath.row*100 + 40];
        }
        fiveImage.userInteractionEnabled=YES;
        fiveImage.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *fiveImageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:) ];
        [fiveImage addGestureRecognizer:fiveImageTap];
        

        [cell addSubview:fiveImage];
        [fiveImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(cell).multipliedBy(0.1);
            make.height.equalTo(cell);
            make.left.equalTo(fourImage.mas_right).offset(25);
            make.bottom.equalTo(cell);
        }];
    }
    
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 当选中了某一行的时候就会调用这个方法，可以在这里进行一些操作
}

- (void)onClickImage:(UIGestureRecognizer *)sender
{
    NSLog(@"点击了第%ld张图片", sender.view.tag);
    int ivalue = sender.view.tag/100;
    int ttype = sender.view.tag%100;
    int type =ttype/10;
    int status = ttype%10;
    int oldValue = (ivalue*100)+(type*10);
    NSArray * userArray = [self.userDictionary allValues];
    UserInfo * ui = [userArray objectAtIndex:ivalue-1];
    if(type == 1){
        bool isOpen ;
        if(status == 1){
            isOpen = NO;
        }else{
            isOpen = YES;
        }
        NSArray *serventIds = [NSArray arrayWithObject:ui.emId];
        [[EMClient sharedClient].conferenceManager updateWhiteboardRoomWithRoomId:[EMLearnOption sharedOptions].whiteRoomId 
         username:[EMClient sharedClient].currentUsername
         userToken:[EMClient sharedClient].accessUserToken intract:isOpen allUsers:NO serventIds:serventIds completion:^(EMError *aError) {
            if (aError) {
                NSLog(@"---white update state:%@",aError.errorDescription);
                
                return ;
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                 if(status == 1){
                     sender.view.tag = oldValue+0;
                     ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_white_off"];
                 }else{
                     sender.view.tag = oldValue+1;
                     ((UIImageView *)sender.view).image = [UIImage imageNamed:@"button_white_on"];
                 }
             });
        }];
        
    }else if(type == 2){
        NSNumber *isOpen = [[NSNumber alloc] initWithInt:0];
        if(status == 1){
            isOpen = [[NSNumber alloc] initWithInt:-1];
        }else{
            isOpen = [[NSNumber alloc] initWithInt:1];
        }
        NSMutableDictionary *param =
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"UserNames":@[ui.name],
            @"confrId":[EMLearnOption sharedOptions].conference.confId,
            @"isOpen":isOpen,
        }];
        NSMutableDictionary *header =
        [NSMutableDictionary dictionaryWithDictionary:@{
            @"Authorization":[EMLearnOption sharedOptions].sysAccessToken,
        }];
        [ViewBase HttpPost:@"Conference/SetChatroomMute" paramaters:param headers:header callBlock:^void (id object,NSError *error){
            if ([object isKindOfClass:[NSDictionary class]]){
                NSDictionary *dictionary = (NSDictionary *)object;
                NSString *code = [dictionary objectForKey:@"code"];
                if([code isEqual: @"1"]){
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        if(status == 1){
                            sender.view.tag = oldValue +0;
                            ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_message_off"];
                        }else{
                            sender.view.tag = oldValue +1;
                            ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_message_on"];
                        }
                    });
                }
                
            }
            
        }];
  
        
    }else if(type == 3){
        BOOL isAudio = NO;
        if(status != 1){
            isAudio = YES;
        }
        [[[EMClient sharedClient] conferenceManager] setMuteMember:[EMLearnOption sharedOptions].conference memId:ui.emId mute:isAudio completion:^(EMError *aError) {
            if(aError) {
                NSLog(@"set mute err:%@",aError.errorDescription);
                return;
                
            }
           
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if(isAudio){
                ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_audio_on"];
                sender.view.tag = oldValue +1;
                NSLog(@"click set mute image on");
            }else{
                ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_audio_off"];
                sender.view.tag = oldValue +0;
                NSLog(@"click set mute image off");
            }
        });
    }else if(type == 4){
        BOOL isVideo = NO;
        if(status == 1){
            ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_video_off"];
            sender.view.tag = oldValue +0;
        }else{
            ((UIImageView *)sender.view).image = [UIImage imageNamed:@"tv_video_on"];
            sender.view.tag = oldValue +1;
            isVideo = YES;
        }
    }  
}
@end
