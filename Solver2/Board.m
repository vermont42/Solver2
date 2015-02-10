//
//  Board.m
//  Solver2
//
//  Created by Joshua Adams on 1/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import "Board.h"

@interface Board ()
@property NSMutableArray *letters;
@end

static const int LETTERS_IN_ALPHABET = 26;

@implementation Board
- (instancetype)init
{
    if (self = [super init])
    {
        self.letters = [NSMutableArray new];
        for (int i = 0; i < LETTERS_IN_ALPHABET; i++)
        {
            NSMutableArray *letterArray = [NSMutableArray new];
            [letterArray addObject:[NSNull null]];
            [self.letters addObject:letterArray];
        }
    }
    return self;
}

- (void)addLetter:(int)letter color:(int)color
{
    if (color)
    {
        color = 5 - color;
    }
    NSMutableArray *letterArray = self.letters[letter];
    NSObject *firstObject = [letterArray firstObject];
    if (firstObject == [NSNull null])
    {
        [letterArray removeObjectAtIndex:0]; // remove dummy
    }
    LetterAndColor *letterAndColor = [[LetterAndColor alloc]initWithLetter:letter color:color];
    [letterArray addObject:letterAndColor];
    if ([letterArray count] > 1)
    {
        [letterArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            LetterAndColor *l1 = (LetterAndColor *)obj1;
            LetterAndColor *l2 = (LetterAndColor *)obj2;
            if (l1.color < l2.color) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (l1.color > l2.color) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    }
}

- (void)output
{
    for (int i = 0; i < LETTERS_IN_ALPHABET; i++)
    {
        NSMutableArray *letterArray = self.letters[i];
        NSObject *firstObject = [letterArray firstObject];
        if (!(firstObject == [NSNull null]))
        {
            for (int j = 0; j < [letterArray count]; j++)
            {
                LetterAndColor *letterAndColor = letterArray[j];
                NSLog(@"letter: %d color: %d", letterAndColor.letter, letterAndColor.color);
            }
        }
        else
        {
            NSLog(@"no letter %d", i);
        }
    }
}

- (LetterAndColor *)retrieveLetterAndColor:(NSString *)letter
{
    int index = 0;
    if ([letter isEqualToString:@"a"])
    {
        index = 0;
    }
    else if ([letter isEqualToString:@"b"])
    {
        index = 1;
    }
    else if ([letter isEqualToString:@"c"])
    {
        index = 2;
    }
    else if ([letter isEqualToString:@"d"])
    {
        index = 3;
    }
    else if ([letter isEqualToString:@"e"])
    {
        index = 4;
    }
    else if ([letter isEqualToString:@"f"])
    {
        index = 5;
    }
    else if ([letter isEqualToString:@"g"])
    {
        index = 6;
    }
    else if ([letter isEqualToString:@"h"])
    {
        index = 7;
    }
    else if ([letter isEqualToString:@"i"])
    {
        index = 8;
    }
    else if ([letter isEqualToString:@"j"])
    {
        index = 9;
    }
    else if ([letter isEqualToString:@"k"])
    {
        index = 10;
    }
    else if ([letter isEqualToString:@"l"])
    {
        index = 11;
    }
    else if ([letter isEqualToString:@"m"])
    {
        index = 12;
    }
    else if ([letter isEqualToString:@"n"])
    {
        index = 13;
    }
    else if ([letter isEqualToString:@"o"])
    {
        index = 14;
    }
    else if ([letter isEqualToString:@"p"])
    {
        index = 15;
    }
    else if ([letter isEqualToString:@"q"])
    {
        index = 16;
    }
    else if ([letter isEqualToString:@"r"])
    {
        index = 17;
    }
    else if ([letter isEqualToString:@"s"])
    {
        index = 18;
    }
    else if ([letter isEqualToString:@"t"])
    {
        index = 19;
    }
    else if ([letter isEqualToString:@"u"])
    {
        index = 20;
    }
    else if ([letter isEqualToString:@"v"])
    {
        index = 21;
    }
    else if ([letter isEqualToString:@"w"])
    {
        index = 22;
    }
    else if ([letter isEqualToString:@"x"])
    {
        index = 23;
    }
    else if ([letter isEqualToString:@"y"])
    {
        index = 24;
    }
    else if ([letter isEqualToString:@"z"])
    {
        index = 25;
    }
    NSMutableArray *letterArray = self.letters[index];
    if ([letterArray firstObject] == [NSNull null])
    {
        return nil;
    }
    BOOL foundLetter = NO;
    for (LetterAndColor *letterAndColor in letterArray)
    {
        if (!letterAndColor.hasBeenUsed)
        {
            letterAndColor.hasBeenUsed = YES;
            return letterAndColor;
        }
    }
    if (!foundLetter)
    {
        return nil;
    }
    return nil;
}

- (void)resetUsage
{
    for (NSMutableArray *letterArray in self.letters)
    {
        if ([letterArray firstObject] != [NSNull null])
        {
            for (LetterAndColor *letterAndColor in letterArray)
            {
                letterAndColor.hasBeenUsed = NO;
            }
        }
    }
}
@end
