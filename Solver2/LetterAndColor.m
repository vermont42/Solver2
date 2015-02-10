//
//  LetterAndColor.m
//  Solver2
//
//  Created by Joshua Adams on 1/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import "LetterAndColor.h"

@interface LetterAndColor ()
@property (nonatomic) int letter;
@end

@implementation LetterAndColor
- (instancetype)initWithLetter:(int)letter color:(int)color
{
    self = [super init];
    if (self)
    {
        _letter = letter;
        _color = color;
    }
    return self;
}

- (void)setLetter:(int)letter color:(int)color
{
    self.color = color;
    self.letter = letter;
}
@end
