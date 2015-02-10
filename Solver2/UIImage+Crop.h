//
//  UIImage+Crop.h
//  Solver2
//
//  Created by Joshua Adams on 12/2/14.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface UIImage (Crop)
- (UIImage *)crop:(CGRect)rect;
@end