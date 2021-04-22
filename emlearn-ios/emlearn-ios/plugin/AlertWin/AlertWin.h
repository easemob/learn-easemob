#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EMAlertViewStyle) {
    EMAlertViewStyleDefault,
    EMAlertViewStyleError,
    EMAlertViewStyleInfo,
    EMAlertViewStyleSuccess,
};

@interface AlertWin : UIView

+ (void)showErrorAlert:(NSString *)aStr;

+ (void)showSuccessAlert:(NSString *)aMessage;

+ (void)showInfoAlert:(NSString *)aMessage;

@end

NS_ASSUME_NONNULL_END
