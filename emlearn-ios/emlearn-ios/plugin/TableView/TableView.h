#import <UIKit/UIKit.h>


@interface TableView : UIView
   - (instancetype)init:(NSMutableDictionary *)userDictionary;
@property (nonatomic, strong)UIImageView *authImgBut;
-(void)setItems:(NSMutableDictionary *)dict;
-(void)reloadData;
@end
