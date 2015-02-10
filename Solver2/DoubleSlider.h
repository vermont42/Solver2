//
//  DoubleSlider.h
//  DoubleSlider
//
//  Created by Joshua Adams on 1/10/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DoubleSliderDelegate <NSObject>
@optional
- (void)minFloatValueChanged:(float)minFloatValue;
- (void)maxFloatValueChanged:(float)minFloatValue;
- (void)minIntValueChanged:(int)minIntValue;
- (void)maxIntValueChanged:(int)minIntValue;
@end

IB_DESIGNABLE
@interface DoubleSlider : UIView
@property (nonatomic, retain) IBInspectable UIColor *inColor;
@property (nonatomic, retain) IBInspectable UIColor *outColor;
@property (nonatomic, retain) IBInspectable UIColor *textColor;
@property (nonatomic) IBInspectable float absMinVal;
@property (nonatomic) IBInspectable float absMaxVal;
@property (nonatomic) IBInspectable float curMinVal;
@property (nonatomic) IBInspectable float curMaxVal;
@property (nonatomic) IBInspectable BOOL isInteger;
@property (nonatomic) IBInspectable int precision;
@property (weak, nonatomic) id<DoubleSliderDelegate> delegate;
@end