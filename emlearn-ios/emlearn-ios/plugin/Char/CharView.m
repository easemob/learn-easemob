#import "CharView.h"

#import "AlertWin.h"
#import <Masonry.h>
#import "EMDefines.h"
#import "EMLearnOption.h"
#import "EMDateHelper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMMessageModel.h"
#import "EMMessageCell.h"
#import "EMMessageTimeCell.h"
#import "SysUtils.h"
#import "ViewBaseMain.h"
@interface CharView()<EMChatManagerDelegate>
    
    @property (strong, nonatomic) NSMutableArray *dataArray;
    @property (nonatomic) BOOL isWillInputAt;
    @property (nonatomic, strong) dispatch_queue_t msgQueue;
    //消息格式化
    @property (nonatomic) NSTimeInterval msgTimelTag;
    @property (nonatomic, strong) NSString *moreMsgId;  //第一条消息的消息id
    @property (nonatomic, strong) UILabel *titleLabel;
    @property (nonatomic, strong) UILabel *titleDetailLabel;

//    @property (nonatomic, strong) UIView *topView;
@end


@implementation CharView
-(instancetype)init{
    self = [super init];
    if (self) {
        self.msgQueue = dispatch_queue_create("emmessage.com", NULL);
        
        self.backgroundColor = [UIColor whiteColor];
        self.msgTimelTag = -1;
        
        UIView * topView = [self _setupTopTitle];
        
//        self.tableView =[[UITableView alloc] init];
        self.tableView.backgroundColor = kColor_LightGray;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 130;
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        [self addSubview:self.tableView];
        
        
        
        NSInteger width = [UIScreen mainScreen].bounds.size.width;
        NSLog(@"width:%ld",(long)width);
        self.chatBar = [[CharBar alloc] init];
        self.chatBar.emdelegate = self;
        self.chatBar.parent = self;
        [self addSubview:self.chatBar];
        [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topView.mas_bottom);
            make.bottom.equalTo(self.chatBar.mas_top);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    }
    return self;
}


- (UIView *)_setupTopTitle{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * 06, 40)];
    topView.backgroundColor = kColor_Blue;
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.text = @"聊天区";
    [topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView);
        make.left.equalTo(topView).offset(15);
        make.right.equalTo(topView).offset(-5);
    }];
    
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.font = [UIFont systemFontOfSize:15];
    self.titleDetailLabel.textColor = [UIColor grayColor];
    self.titleDetailLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:self.titleDetailLabel];
    [self.titleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(topView);
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
    self.chatImgBut.image = [UIImage imageNamed:@"button_switch"];
    self.chatImgBut.tag = 0;
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataArray objectAtIndex:indexPath.row];
    NSString *cellString = nil;
    if ([obj isKindOfClass:[NSString class]]) {
        cellString = (NSString *)obj;
    } else if ([obj isKindOfClass:[EMMessageModel class]]) {
        EMMessageModel *model = (EMMessageModel *)obj;
        if (model.type == EMMessageTypeExtRecall) {
            cellString = @"您撤回一条消息";
        }
    }
    if ([cellString length] > 0) {
        EMMessageTimeCell *cell = (EMMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMessageTimeCell"];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EMMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EMMessageTimeCell"];
        }
        
        cell.timeLabel.text = cellString;
        return cell;
    } else {
        EMMessageModel *model = (EMMessageModel *)obj;
        NSString *identifier = [EMMessageCell cellIdentifierWithDirection:model.direction type:model.type];
        /*
        EMMessageCell *cell = nil;
        if (identifier)
            cell = (EMMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];*/
        // Configure the cell...
        EMMessageCell *cell = (EMMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[EMMessageCell alloc] initWithDirection:model.direction type:model.type];
            cell.delegate = self;
        }
        cell.model = model;
        return cell;
    }
}

#pragma mark - KeyBoardDelegate
//- (BOOL)inputView:(EMTextView *)aInputView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    self.isWillInputAt = NO;
//    if ([text isEqualToString:@"\n"]) {
//        [self _sendTextAction:aInputView.text ext:nil];
//        return NO;
//    } else if ([text isEqualToString:@"@"]) {
//        self.isWillInputAt = YES;
//    } else if ([text length] == 0) {
//
//    }
//
//    return YES;
//}
//
//- (void)inputViewDidChange:(EMTextView *)aInputView
//{
////    if (self.isWillInputAt && self.conversationModel.emModel.type == EMConversationTypeGroupChat) {
////        NSString *text = aInputView.text;
////        if ([text hasSuffix:@"@"]) {
////            self.isWillInputAt = NO;
////        }
////    }
//}
-(BOOL)sendText:(NSString *)text{
    [self _sendTextAction:text ext:nil];
    return YES;
}
- (void)closeView{
    if(self.chatBar.keyBoard != nil){
        [self.chatBar.keyBoard removeFromSuperview];
    }
}
#pragma mark - EMChatManagerDelegate


- (void)messagesDidReceive:(NSArray *)aMessages
{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        NSMutableArray *msgArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [aMessages count]; i++) {
            EMMessage *msg = aMessages[i];
            [msgArray addObject:msg];
        }
        
        NSArray *formated = [weakself _formatMessages:msgArray];
        [weakself.dataArray addObjectsFromArray:formated];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.tableView reloadData];
            [weakself.tableView setNeedsLayout];
            [weakself.tableView layoutIfNeeded];
            [weakself _scrollToBottomRow];
        });
    });
}
- (void)messagesDidRecall:(NSArray *)aMessages {
    NSLog(@"messagesDidRecall:%@",aMessages);
}
- (void)sendDidReadReceipt{}
- (void)groupMessageDidRead:(EMMessage *)aMessage groupAcks:(NSArray *)aGroupAcks{}
- (void)messagesDidRead:(NSArray *)aMessages{}

- (void)messageStatusDidChange:(EMMessage *)aMessage
                         error:(EMError *)aError{
    __weak typeof(self) weakself = self;
    dispatch_async(self.msgQueue, ^{
        if (![[EMLearnOption sharedOptions].chatRoomId isEqualToString:aMessage.conversationId]){
            return ;
        }
        
        __block NSUInteger index = NSNotFound;
        __block EMMessageModel *reloadModel = nil;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[EMMessageModel class]]) {
                EMMessageModel *model = (EMMessageModel *)obj;
                if ([model.emModel.messageId isEqualToString:aMessage.messageId]) {
                    reloadModel = model;
                    index = idx;
                    *stop = YES;
                }
            }
        }];
        
        if (index != NSNotFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.dataArray replaceObjectAtIndex:index withObject:reloadModel];
                [weakself.tableView beginUpdates];
                [weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakself.tableView endUpdates];
            });
        }
        
    });
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages{
    NSLog(@"cmdMessagesDidReceive:%@",aCmdMessages);
}
#pragma mark - Public

- (void)_scrollToBottomRow
{
    if ([self.dataArray count] > 0) {
        NSInteger toRow = self.dataArray.count - 1;
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)_sendTextAction:(NSString *)aText
                    ext:(NSDictionary *)aExt
{
    [self.chatBar clearInputViewText];
    if ([aText length] == 0) {
        return;
    }
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:aText];
    [self _sendMessageWithBody:body];
}

//发送消息体
- (void)_sendMessageWithBody:(EMMessageBody *)aBody
{
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    NSString *to = [EMLearnOption sharedOptions].chatRoomId;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:aBody ext:@{@"nickName":[EMLearnOption sharedOptions].nickName}];
    
    
    message.chatType = EMChatTypeChatRoom;
    message.status = EMMessageStatusDelivering;
    
    __weak typeof(self) weakself = self;
    NSArray *formated = [weakself _formatMessages:@[message]];
    [self.dataArray addObjectsFromArray:formated];
    if (!self.moreMsgId) {
        //新会话的第一条消息
        self.moreMsgId = message.messageId;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.tableView reloadData];
        [weakself.tableView setNeedsLayout];
        [weakself.tableView layoutIfNeeded];
        [weakself _scrollToBottomRow];
    });
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"errorCode    %u   errorDesc    %@",error.code,error.errorDescription);
        if (error)
            [AlertWin showErrorAlert:error.errorDescription];
        [weakself messageStatusDidChange:message error:error];
    }];
    
}

#pragma mark - Data

- (NSArray *)_formatMessages:(NSArray<EMMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];

    for (int i = 0; i < [aMessages count]; i++) {
        EMMessage *msg = aMessages[i];

        // cmd消息不展示
        if(msg.body.type == EMMessageBodyTypeCmd || msg.body.type == EMMessageBodyTypeCustom) {
            continue;
        }
        if (msg.chatType == EMChatTypeChat && !msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
            [[EMClient sharedClient].chatManager sendMessageReadAck:msg.messageId toUser:msg.conversationId completion:nil];
        } else if (msg.chatType == EMChatTypeGroupChat && !msg.isReadAcked && (msg.body.type == EMMessageBodyTypeText || msg.body.type == EMMessageBodyTypeLocation)) {
        }
        
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            NSString *timeStr = [EMDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            [formated addObject:timeStr];
            self.msgTimelTag = msg.timestamp;
        }
//
        EMMessageModel *model = [[EMMessageModel alloc] initWithEMMessage:msg];
        [formated addObject:model];
    }
    
    return formated;
}


- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
