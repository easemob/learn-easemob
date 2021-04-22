#import <UIKit/UIKit.h>
#import "../Text/EMTextView.h"

@protocol KeyBoardDelegate <NSObject>

@optional

-(BOOL)sendText:(NSString *)text;

- (void) closeView;
@end


@interface EmKeyBoard : UIView
    @property (nonatomic, weak) id<KeyBoardDelegate> emdelegate;
    @property (nonatomic, strong) EMTextView *inputField;
-(instancetype)init;
@end
