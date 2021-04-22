
#import "UIView+DragScale.h"
#import <objc/runtime.h>

@implementation UIView (draggable)

- (void)setPanGesture:(UIPanGestureRecognizer*)panGesture {
    objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPanGestureRecognizer*)panGesture {
    return objc_getAssociatedObject(self, @selector(panGesture));
}

- (void)setPinGesture:(UIPinchGestureRecognizer*)pinGesture {
    objc_setAssociatedObject(self, @selector(pinGesture), pinGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPinchGestureRecognizer*)pinGesture {
    return objc_getAssociatedObject(self, @selector(pinGesture));
}

- (void)setLastScale:(CGFloat)newLastScale {
    CGFloat tLastScale = newLastScale;
    NSNumber *lastScale = [NSNumber numberWithFloat:tLastScale];
    objc_setAssociatedObject(self, @selector(lastScale), lastScale, OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)lastScale {
    NSNumber *newLastScale =objc_getAssociatedObject(self, @selector(lastScale));
    return newLastScale.doubleValue;
}

#pragma mark - Gesture recognizer

- (void)handlePan:(UIPanGestureRecognizer*)sender {
    CGPoint point = [sender translationInView:[self superview]];
    sender.view.transform = CGAffineTransformTranslate(sender.view.transform, point.x, point.y);
    [sender setTranslation:CGPointZero inView:[self superview]];
}


-(void)handleScale:(UIPinchGestureRecognizer*)sender {
    //当手指离开屏幕时,将lastscale设置为1.0
    if([sender state] == UIGestureRecognizerStateEnded) {
        self.lastScale = 1.0;
        return;
    }
    
    CGFloat scale = 1.0 - (self.lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    CGAffineTransform currentTransform = self.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [self setTransform:newTransform];
    self.lastScale = [sender scale];
}
//设置点击的范围
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

#pragma mark - Drag state handling

- (void)setDraggable:(BOOL)draggable {
    self.panGesture.enabled = draggable;
}

- (void)enableDragging {
    self.lastScale=1.0;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.cancelsTouchesInView = NO;
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
    
//    _lastScale=1.0;
//    self.pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleScale:)];
//    [self.pinGesture setDelegate:self];
//    [self addGestureRecognizer:self.pinGesture];
}

@end
