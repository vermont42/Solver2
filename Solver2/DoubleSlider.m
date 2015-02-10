//
//  DoubleSlider.m
//  DoubleSlider
//
//  Created by Joshua Adams on 1/10/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import "DoubleSlider.h"

@interface DoubleSlider ()
typedef enum
{
    LEFT_KNOB = 0,
    RIGHT_KNOB = 1,
    NEITHER = 2
} CurrentKnob;
@property (nonatomic) CurrentKnob currentKnob;
@property (nonatomic) float minValSpan;
@property (nonatomic) float valueFudge;
@end

@implementation DoubleSlider
static const CGFloat LINE_RED = 0.0;
static const CGFloat LINE_GREEN = 0.48;
static const CGFloat LINE_BLUE = 1.0;
static const CGFloat LINE_ALPHA = 1.0;
static const CGFloat LINE_WIDTH = 2.0;
static const CGFloat KNOB_BORDER_WIDTH = 1.0;
static const CGFloat KNOB_WIDTH = 28.0;
static const CGFloat INTRINSIC_HEIGHT = 62.0;
//static const float VALUE_FUDGE = .05; // TODO: calculate appropriate fudge dynamically; this value works for 1-10 but not 1000-2000
static const float FUDGE_FACTOR = 100.0;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (float)valueFudge
{
    if (_valueFudge == 0.0)
    {
        _valueFudge = (_absMaxVal - _absMinVal) / FUDGE_FACTOR;
    }
    return _valueFudge;
}

- (void)setup
{
    self.inColor = [UIColor colorWithRed:LINE_RED green:LINE_GREEN blue:LINE_BLUE alpha:LINE_ALPHA];
    self.outColor = [UIColor lightGrayColor];
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    self.absMinVal = 2.0;
    self.absMaxVal = 12.0;
    self.curMinVal = 4.0;
    self.curMaxVal = 12.0;
    self.isInteger = YES;
    self.precision = 1;
    self.currentKnob = NEITHER;
    self.minValSpan = (self.absMaxVal - self.absMinVal) * (KNOB_WIDTH / (self.bounds.size.width - KNOB_WIDTH));
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    self.valueFudge = 0.0;
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize
{
    //return CGSizeMake(KNOB_WIDTH * INTRINSIC_WIDTH_MULTIPLIER, INTRINSIC_HEIGHT);
    return CGSizeMake(UIViewNoIntrinsicMetric, INTRINSIC_HEIGHT);
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    CGFloat adjustedPixelWidth = self.bounds.size.width - KNOB_WIDTH;
    float virtualWidth = self.absMaxVal - self.absMinVal;
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        CGPoint translation = [gesture translationInView:self];
        [gesture setTranslation:CGPointZero inView:self];
        float newKnobVal = self.currentKnob == LEFT_KNOB ? self.curMinVal : self.curMaxVal;
        float deltaPercentage = translation.x / adjustedPixelWidth;
        newKnobVal += deltaPercentage * virtualWidth;
        if (self.currentKnob == LEFT_KNOB)
        {
            if (newKnobVal >= self.absMinVal && newKnobVal < self.curMaxVal - self.minValSpan)
            {
                if (fabsf(newKnobVal - self.absMinVal) > self.valueFudge)
                {
                    self.curMinVal = newKnobVal;
                }
                else
                {
                    self.curMinVal = self.absMinVal;
                }
                if (self.isInteger)
                {
                    [self.delegate minIntValueChanged:lroundf(self.curMinVal)];
                }
                else
                {
                    [self.delegate minFloatValueChanged:self.curMinVal];
                }
                    
            }
        }
        else
        {
            if (newKnobVal <= self.absMaxVal && newKnobVal > self.curMinVal + self.minValSpan)
            {
                if (fabsf(newKnobVal - self.absMaxVal) > self.valueFudge)
                {
                    self.curMaxVal = newKnobVal;
                }
                else
                {
                    self.curMaxVal = self.absMaxVal;
                }
                if (self.isInteger)
                {
                    [self.delegate maxIntValueChanged:lroundf(self.curMaxVal)];
                }
                else
                {
                    [self.delegate maxFloatValueChanged:self.curMaxVal];
                }
            }
        }
    }
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGFloat firstX = ((self.curMinVal - self.absMinVal) / virtualWidth) * adjustedPixelWidth + KNOB_WIDTH / 2;
        CGFloat secondX = ((self.curMaxVal - self.absMinVal) / virtualWidth) * adjustedPixelWidth + KNOB_WIDTH / 2;
        CGFloat gestureX = [gesture locationInView:self].x;
        float distFirst = fabsf(gestureX - firstX);
        float distSecond = fabsf(gestureX - secondX);
        if (distFirst < distSecond)
        {
            self.currentKnob = LEFT_KNOB;
        }
        else
        {
            self.currentKnob = RIGHT_KNOB;
        }
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat adjustedPixelWidth = self.bounds.size.width - KNOB_WIDTH;
    CGFloat halfPixelHeight = self.bounds.size.height / 2;
    float virtualWidth = self.absMaxVal - self.absMinVal;
    float offsetCurMinVal = self.curMinVal - self.absMinVal;
    float offsetCurMaxVal = self.curMaxVal - self.absMinVal;
    CGFloat firstX = (offsetCurMinVal / virtualWidth) * adjustedPixelWidth + KNOB_WIDTH / 2;
    CGFloat secondX = (offsetCurMaxVal / virtualWidth) * adjustedPixelWidth + KNOB_WIDTH / 2;
    UIBezierPath *path1 = [UIBezierPath new];
    UIBezierPath *path2 = [UIBezierPath new];
    UIBezierPath *path3 = [UIBezierPath new];
    path1.lineWidth = LINE_WIDTH;
    path2.lineWidth = LINE_WIDTH;
    path3.lineWidth = LINE_WIDTH;
    [self.outColor setStroke];
    [path1 moveToPoint:CGPointMake(KNOB_WIDTH / 2, halfPixelHeight)];
    [path1 addLineToPoint:CGPointMake(firstX, halfPixelHeight)];
    [path1 closePath];
    [path1 stroke];
    [self.inColor setStroke];
    [path2 moveToPoint:CGPointMake(firstX, halfPixelHeight)];
    [path2 addLineToPoint:CGPointMake(secondX, halfPixelHeight)];
    [path2 closePath];
    [path2 stroke];
    [self.outColor setStroke];
    [path3 moveToPoint:CGPointMake(secondX, halfPixelHeight)];
    [path3 addLineToPoint:CGPointMake(self.bounds.size.width - KNOB_WIDTH / 2, halfPixelHeight)];
    [path3 closePath];
    [path3 stroke];
    [self drawKnobAtX:firstX value:self.curMinVal halfPixelHeight:halfPixelHeight];
    [self drawKnobAtX:secondX value:self.curMaxVal halfPixelHeight:halfPixelHeight];
}

- (void)drawKnobAtX:(CGFloat)x value:(float)value halfPixelHeight:(float)halfPixelHeight
{
    UIBezierPath *knob = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, halfPixelHeight) radius:(KNOB_WIDTH/2 - 1) startAngle:0 endAngle:2*M_PI clockwise:YES];
    knob.lineWidth = KNOB_BORDER_WIDTH;
    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    [knob stroke];
    [knob fill];
    NSString *valueString = @"";
    if (self.isInteger)
    {
        valueString = [NSString stringWithFormat:@"%ld", lroundf(value)];
    }
    else
    {
        NSString *formatString = [NSString stringWithFormat:@"%%.0%df", self.precision];
        valueString = [NSString stringWithFormat:formatString, value];
    }
    CGSize valueSize = [valueString sizeWithAttributes:nil];
    CGFloat valueX = x - valueSize.width / 2;
    if (valueX < 0.0)
    {
        valueX = 0.0;
    }
    else if (valueX + valueSize.width > self.bounds.size.width)
   {
        valueX = self.bounds.size.width - valueSize.width;
    }
    [valueString drawAtPoint:CGPointMake(valueX, halfPixelHeight + KNOB_WIDTH / 2) withAttributes:@{ NSForegroundColorAttributeName:self.textColor }];
}
@end