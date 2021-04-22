#import <UIKit/UIKit.h>
#import "../Text/EMTextView.h"
#import "../KeyBoard/EmKeyBoard.h"



@interface CharBar : UIView
@property(nonatomic) BOOL isChat;
@property (nonatomic, strong) EMTextView *textView;
@property (nonatomic, strong) UIView *parent;
@property (nonatomic, weak) id<KeyBoardDelegate> emdelegate;
@property(nonatomic,strong) NSString * name;
@property (nonatomic, strong) EmKeyBoard * keyBoard;
- (void)clearInputViewText;
- (instancetype)init:(int)heigth;
@end




