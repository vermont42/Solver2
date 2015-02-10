//
//  SolverModel.h
//  Solver2
//
//  Created by Joshua Adams on 12/2/14.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@protocol SolverDelegate <NSObject>
- (void)receiveStatus:(NSAttributedString *)status;
- (void)receiveProgress:(float)progress;
- (void)endProcessing;
- (void)startProcessing;
@end

@interface SolverModel : NSObject
+ (void)mungeScreenshot:(UIImage *)screenshot
               delegate:(id<SolverDelegate>)delegate
         maxLetterCount:(int)maxLetterCount
         minLetterCount:(int)minLetterCount;
@end
