#import "ViewSplash.h"
#import "ViewLogin.h"
@interface ViewSplash ()
@property (nonatomic) NSTimer* timer;
@end


@implementation ViewSplash

- (void)viewDidLoad {
    [super viewDidLoad];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(toLogin) userInfo:nil repeats:NO];
}

- (void)toLogin{
    ViewLogin* loginView = [[ViewLogin alloc] init];
    loginView.modalPresentationStyle = 0;
    [self presentViewController:loginView animated:NO completion:nil];
    NSLog(@"to login view");
}

- (void)dealloc {
  [self.timer invalidate];
  NSLog(@"dealloc");
}

@end

