//
//  PinchTextView.m
//
//  Displays an attributed string and pinches it towards touches.

#import "PinchTextView.h"
#import "PinchTextLayer.h"

@interface PinchTextView ()

@end

@implementation PinchTextView

#pragma mark -
#pragma mark Init

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self != nil) {
    [self finishInit];
  }
  return self;
}

- (void)awakeFromNib
{
  [self finishInit];
}

- (void)finishInit
{
#if TARGET_OS_IPHONE
  // Flip the view's context. Core Text runs bottom to top, even on iPad, and
  // the view is much simpler if we do everything in Mac coordinates.
  CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
  CGAffineTransformTranslate(transform, 0, -self.bounds.size.height);
  self.transform = transform;
#endif
  //  self.contentScaleFactor = 1.0;  // If you want it to be near-realtime. :D
  [self.layer setNeedsDisplay];
}

#pragma mark -
#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"pinchScale"];
  anim.duration = 0.1;
  anim.fromValue = @(self.pinchTextLayer.pinchScale);
  anim.toValue = @1000;
  anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.pinchTextLayer addAnimation:anim forKey:@"touchesBegan"];
  
  self.pinchTextLayer.pinchScale = 1000;
  [self updateTouchPointWithTouches:[event touchesForView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self updateTouchPointWithTouches:[event touchesForView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"pinchScale"];
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  animation.duration = .5;
  animation.values = @[@1000, @-50, @0];
  animation.calculationMode = kCAAnimationCubic;
  [self.pinchTextLayer addAnimation:animation forKey:@"touchesEnded"];
  
  self.pinchTextLayer.pinchScale = 0;
}

- (void)updateTouchPointWithTouches:(NSSet *)touches
{
  NSMutableSet *points = [NSMutableSet new];
  for (UITouch *touch in touches) {
    CGPoint location = [touch locationInView:self];
    [points addObject:[NSValue valueWithCGPoint:location]];
  }
  
  [self.pinchTextLayer setTouchPoints:points];
}

+ (Class)layerClass
{
  return [PinchTextLayer class];
}

- (NSAttributedString *)attributedString {
  return [self.pinchTextLayer attributedString];
}

- (void)setAttributedString:(NSAttributedString *)attributedString {
  [self.pinchTextLayer setAttributedString:attributedString];
}

- (PinchTextLayer *)pinchTextLayer {
  return (PinchTextLayer*)self.layer;
}

@end