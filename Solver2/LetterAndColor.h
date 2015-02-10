//
//  LetterAndColor.h
//  Solver2
//
//  Created by Joshua Adams on 1/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LetterAndColor : NSObject
- (instancetype)initWithLetter:(int)letter color:(int)color;
- (int)letter;
@property (nonatomic) int color;
@property (nonatomic) BOOL hasBeenUsed;
@end
