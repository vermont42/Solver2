//
//  UIImage+Crop.m
//  Solver2
//
//  Created by Joshua Adams on 12/2/14.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//

#import "UIImage+Crop.h"
@import UIKit;

@implementation UIImage (Crop)
- (UIImage *)crop:(CGRect)rect
{
    
    rect = CGRectMake(rect.origin.x*self.scale,
                      rect.origin.y*self.scale,
                      rect.size.width*self.scale,
                      rect.size.height*self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:self.scale
                                    orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}
@end
