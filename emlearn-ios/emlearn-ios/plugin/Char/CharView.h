#import <UIKit/UIKit.h>
#import "RefreshView.h"
#import "CharBar.h"
@interface CharView : RefreshView
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) CharBar *chatBar;
@property (nonatomic, strong)UIImageView *chatImgBut;
-(instancetype)init;
@end


