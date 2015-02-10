//
//  RectWrapper.h
//  Solver2
//
//  Created by Joshua Adams on 12/28/14.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RectWrapper : NSObject
- (instancetype)initWithX:(float)x y:(float)y;
@property (nonatomic) float x;
@property (nonatomic) float y;
@end
