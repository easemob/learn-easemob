#import <UIKit/UIKit.h>
#import "ViewBase.h"

#import "../plugin/DropDownMenu/EBDropdownListView.h"
#import "../plugin/RadioButton/RadioButton.h"


@interface ViewLogin : ViewBase

@property(nonatomic,strong) UIImageView* conferencelogo;
@property(nonatomic,strong) UITextField* nameField;
@property(nonatomic,strong) UITextField* passField;
@property(nonatomic,strong) UITextField* nickNameField;
@property(nonatomic,strong) EBDropdownListView* confrTypeDropDown;

@property(nonatomic,strong) UIButton* joinRoomButton;
@property(nonatomic,strong) UILabel* errorLable;
@end
