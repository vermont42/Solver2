//
//  RectWrapper.m
//  Solver2
//
//  Created by Joshua Adams on 12/28/14.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//

#import "RectWrapper.h"

@implementation RectWrapper
- (instancetype)initWithX:(float)x y:(float)y
{
    self = [super init];
    if (self)
    {
        self.x = x;
        self.y = y;
    }
    return self;
}
@end
