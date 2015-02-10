//
//  Board.h
//  Solver2
//
//  Created by Joshua Adams on 1/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LetterAndColor.h"

@interface Board : NSObject
- (void)addLetter:(int)letter color:(int)color;
- (void)output;
- (LetterAndColor *)retrieveLetterAndColor:(NSString *)letter;
- (void)resetUsage;
@end
