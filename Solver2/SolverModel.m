//
//  SolverModel.m
//  Solver2
//
//  Created by Joshua Adams on 12/2/14.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//

#import "SolverModel.h"
#import "UIImage+Crop.h"
#import "RectWrapper.h"
#import "DDFileReader.h"
#import "Board.h"
#import "LetterAndColor.h"
@import UIKit;

@interface SolverModel ()
@property (strong, nonatomic) NSMutableArray *allLetterImages;
@property (strong, nonatomic) NSArray *letters;
@property (strong, nonatomic) NSArray *colorStrings;
@property (strong, nonatomic) NSArray *letterCoordinates;
@property (weak, nonatomic) id<SolverDelegate> delegate;
@end

static const NSUInteger LETTER_HEIGHT = 50;
static const NSUInteger LETTER_WIDTH = 50;
static const int LETTERS_IN_ALPHABET = 26;
static const int COLOR_COUNT = 5;
static const int COLUMN_COUNT = 5;
static const int ROW_COUNT = 5;
static const int PIXEL_COUNT = 2500;
static const int COLORS_PER_PIXEL = 3;
static const int BYTES_PER_PIXEL = 4;
static const NSUInteger BITS_PER_COMPONENT = 8;
static const NSUInteger BYTES_PER_ROW = 200;
static const float EQUALITY_TOLERANCE = 20.0;
static const float COLUMN_ONE = 39, COLUMN_TWO = 167, COLUMN_THREE = 295, COLUMN_FOUR = 423, COLUMN_FIVE = 551;
static const float ROW_ONE = 287, ROW_TWO = 415, ROW_THREE = 543, ROW_FOUR = 671, ROW_FIVE = 799;
static const int TOTAL_WORDS = 239021;
static const int DARK_BLUE = 4, DARK_RED = 3, LIGHT_BLUE = 2, LIGHT_RED = 1, WHITE = 0;
static const int BLUE_BONUS = 3, RED_BONUS = 2;
static float ***soloPixelBuffers;
static float *croppedPixelBuffer;
static unsigned char *rawDataBuffer;
static CGRect letterRect;
static NSArray *rects;
static NSArray *soloLetters;
static CGColorSpaceRef colorSpace;
static NSMutableArray *allWords;
static int *values;
static BOOL doneReadingFile = NO;
static Board *board;
static NSArray *bestLettersAndColors;
static const int TEN_PERCENT_OF_WORDS = 24000, PROGRESS_REMAINDER = 10, NUMBER_OF_CHUNKS = 10;
static int currentWord = 0;
static NSArray *wordStarts;
static NSArray *wordEnds;

@implementation SolverModel
+ (void)initialize
{
    soloLetters = @[
                    @[[UIImage imageNamed:@"aw.png"], [UIImage imageNamed:@"bw.png"], [UIImage imageNamed:@"cw.png"], [UIImage imageNamed:@"dw.png"], [UIImage imageNamed:@"ew.png"], [UIImage imageNamed:@"fw.png"], [UIImage imageNamed:@"gw.png"], [UIImage imageNamed:@"hw.png"], [UIImage imageNamed:@"iw.png"], [UIImage imageNamed:@"jw.png"], [UIImage imageNamed:@"kw.png"], [UIImage imageNamed:@"lw.png"], [UIImage imageNamed:@"mw.png"], [UIImage imageNamed:@"nw.png"], [UIImage imageNamed:@"ow.png"], [UIImage imageNamed:@"pw.png"], [UIImage imageNamed:@"qw.png"], [UIImage imageNamed:@"rw.png"], [UIImage imageNamed:@"sw.png"], [UIImage imageNamed:@"tw.png"], [UIImage imageNamed:@"uw.png"], [UIImage imageNamed:@"vw.png"], [UIImage imageNamed:@"ww.png"], [UIImage imageNamed:@"xw.png"], [UIImage imageNamed:@"yw.png"], [UIImage imageNamed:@"zw.png"]
                      ],
                    @[[UIImage imageNamed:@"adb.png"], [UIImage imageNamed:@"bdb.png"], [UIImage imageNamed:@"cdb.png"], [UIImage imageNamed:@"ddb.png"], [UIImage imageNamed:@"edb.png"], [UIImage imageNamed:@"fdb.png"], [UIImage imageNamed:@"gdb.png"], [UIImage imageNamed:@"hdb.png"], [UIImage imageNamed:@"idb.png"], [UIImage imageNamed:@"jdb.png"], [UIImage imageNamed:@"kdb.png"], [UIImage imageNamed:@"ldb.png"], [UIImage imageNamed:@"mdb.png"], [UIImage imageNamed:@"ndb.png"], [UIImage imageNamed:@"odb.png"], [UIImage imageNamed:@"pdb.png"], [UIImage imageNamed:@"qdb.png"], [UIImage imageNamed:@"rdb.png"], [UIImage imageNamed:@"sdb.png"], [UIImage imageNamed:@"tdb.png"], [UIImage imageNamed:@"udb.png"], [UIImage imageNamed:@"vdb.png"], [UIImage imageNamed:@"wdb.png"], [UIImage imageNamed:@"xdb.png"], [UIImage imageNamed:@"ydb.png"], [UIImage imageNamed:@"zdb.png"]
                      ],
                    @[[UIImage imageNamed:@"adr.png"], [UIImage imageNamed:@"bdr.png"], [UIImage imageNamed:@"cdr.png"], [UIImage imageNamed:@"ddr.png"], [UIImage imageNamed:@"edr.png"], [UIImage imageNamed:@"fdr.png"], [UIImage imageNamed:@"gdr.png"], [UIImage imageNamed:@"hdr.png"], [UIImage imageNamed:@"idr.png"], [UIImage imageNamed:@"jdr.png"], [UIImage imageNamed:@"kdr.png"], [UIImage imageNamed:@"ldr.png"], [UIImage imageNamed:@"mdr.png"], [UIImage imageNamed:@"ndr.png"], [UIImage imageNamed:@"odr.png"], [UIImage imageNamed:@"pdr.png"], [UIImage imageNamed:@"qdr.png"], [UIImage imageNamed:@"rdr.png"], [UIImage imageNamed:@"sdr.png"], [UIImage imageNamed:@"tdr.png"], [UIImage imageNamed:@"udr.png"], [UIImage imageNamed:@"vdr.png"], [UIImage imageNamed:@"wdr.png"], [UIImage imageNamed:@"xdr.png"], [UIImage imageNamed:@"ydr.png"], [UIImage imageNamed:@"zdr.png"]
                      ],
                    @[[UIImage imageNamed:@"alb.png"], [UIImage imageNamed:@"blb.png"], [UIImage imageNamed:@"clb.png"], [UIImage imageNamed:@"dlb.png"], [UIImage imageNamed:@"elb.png"], [UIImage imageNamed:@"flb.png"], [UIImage imageNamed:@"glb.png"], [UIImage imageNamed:@"hlb.png"], [UIImage imageNamed:@"ilb.png"], [UIImage imageNamed:@"jlb.png"], [UIImage imageNamed:@"klb.png"], [UIImage imageNamed:@"llb.png"], [UIImage imageNamed:@"mlb.png"], [UIImage imageNamed:@"nlb.png"], [UIImage imageNamed:@"olb.png"], [UIImage imageNamed:@"plb.png"], [UIImage imageNamed:@"qlb.png"], [UIImage imageNamed:@"rlb.png"], [UIImage imageNamed:@"slb.png"], [UIImage imageNamed:@"tlb.png"], [UIImage imageNamed:@"ulb.png"], [UIImage imageNamed:@"vlb.png"], [UIImage imageNamed:@"wlb.png"], [UIImage imageNamed:@"xlb.png"], [UIImage imageNamed:@"ylb.png"], [UIImage imageNamed:@"zlb.png"]
                      ],
                    @[[UIImage imageNamed:@"alr.png"], [UIImage imageNamed:@"blr.png"], [UIImage imageNamed:@"clr.png"], [UIImage imageNamed:@"dlr.png"], [UIImage imageNamed:@"elr.png"], [UIImage imageNamed:@"flr.png"], [UIImage imageNamed:@"glr.png"], [UIImage imageNamed:@"hlr.png"], [UIImage imageNamed:@"ilr.png"], [UIImage imageNamed:@"jlr.png"], [UIImage imageNamed:@"klr.png"], [UIImage imageNamed:@"llr.png"], [UIImage imageNamed:@"mlr.png"], [UIImage imageNamed:@"nlr.png"], [UIImage imageNamed:@"olr.png"], [UIImage imageNamed:@"plr.png"], [UIImage imageNamed:@"qlr.png"], [UIImage imageNamed:@"rlr.png"], [UIImage imageNamed:@"slr.png"], [UIImage imageNamed:@"tlr.png"], [UIImage imageNamed:@"ulr.png"], [UIImage imageNamed:@"vlr.png"], [UIImage imageNamed:@"wlr.png"], [UIImage imageNamed:@"xlr.png"], [UIImage imageNamed:@"ylr.png"], [UIImage imageNamed:@"zlr.png"]
                      ]
                    ];
    wordStarts = @[@0, @238897, @237605, @232151, @219673, @197516, @164607, @124446, @83719, @48190, @20297, @0];
    wordEnds = @[@0, @239020, @238896, @237604, @232150, @219672, @197515, @164606, @124445, @83718, @48189, @20296];
    colorSpace = CGColorSpaceCreateDeviceRGB();
    croppedPixelBuffer = (float *)malloc(PIXEL_COUNT * sizeof(float) * COLORS_PER_PIXEL);
    rawDataBuffer = malloc(PIXEL_COUNT * BYTES_PER_PIXEL);
    letterRect = CGRectMake(0, 0, LETTER_WIDTH, LETTER_HEIGHT);
    soloPixelBuffers = (float ***)malloc(sizeof(float **) * COLOR_COUNT);
    for (int color = 0; color < COLOR_COUNT; color++)
    {
        soloPixelBuffers[color] = (float **)malloc(sizeof(float *) * LETTERS_IN_ALPHABET);
        for (int letter = 0; letter < LETTERS_IN_ALPHABET; letter++)
        {
            soloPixelBuffers[color][letter] = (float *)malloc(sizeof(float) * PIXEL_COUNT * COLORS_PER_PIXEL);
            [SolverModel extractPixels:soloLetters[color][letter] pixelBuffer:soloPixelBuffers[color][letter]];
        }
    }
    rects = @[
        @[
        [[RectWrapper alloc] initWithX:COLUMN_ONE y:ROW_ONE],
        [[RectWrapper alloc] initWithX:COLUMN_TWO y:ROW_ONE],
        [[RectWrapper alloc] initWithX:COLUMN_THREE y:ROW_ONE],
        [[RectWrapper alloc] initWithX:COLUMN_FOUR y:ROW_ONE],
        [[RectWrapper alloc] initWithX:COLUMN_FIVE y:ROW_ONE]
        ],
        @[
        [[RectWrapper alloc] initWithX:COLUMN_ONE y:ROW_TWO],
        [[RectWrapper alloc] initWithX:COLUMN_TWO y:ROW_TWO],
        [[RectWrapper alloc] initWithX:COLUMN_THREE y:ROW_TWO],
        [[RectWrapper alloc] initWithX:COLUMN_FOUR y:ROW_TWO],
        [[RectWrapper alloc] initWithX:COLUMN_FIVE y:ROW_TWO]
        ],
        @[
        [[RectWrapper alloc] initWithX:COLUMN_ONE y:ROW_THREE],
        [[RectWrapper alloc] initWithX:COLUMN_TWO y:ROW_THREE],
        [[RectWrapper alloc] initWithX:COLUMN_THREE y:ROW_THREE],
        [[RectWrapper alloc] initWithX:COLUMN_FOUR y:ROW_THREE],
        [[RectWrapper alloc] initWithX:COLUMN_FIVE y:ROW_THREE]
        ],
        @[
        [[RectWrapper alloc] initWithX:COLUMN_ONE y:ROW_FOUR],
        [[RectWrapper alloc] initWithX:COLUMN_TWO y:ROW_FOUR],
        [[RectWrapper alloc] initWithX:COLUMN_THREE y:ROW_FOUR],
        [[RectWrapper alloc] initWithX:COLUMN_FOUR y:ROW_FOUR],
        [[RectWrapper alloc] initWithX:COLUMN_FIVE y:ROW_FOUR]
        ],
        @[
        [[RectWrapper alloc] initWithX:COLUMN_ONE y:ROW_FIVE],
        [[RectWrapper alloc] initWithX:COLUMN_TWO y:ROW_FIVE],
        [[RectWrapper alloc] initWithX:COLUMN_THREE y:ROW_FIVE],
        [[RectWrapper alloc] initWithX:COLUMN_FOUR y:ROW_FIVE],
        [[RectWrapper alloc] initWithX:COLUMN_FIVE y:ROW_FIVE]
        ]
    ];
    
    // Set a bool when this is done.
    // Have mungeScreenshot block on that bool.
    // Possibly tell the VC that the file is being read.
    dispatch_queue_t fileQ = dispatch_queue_create("file-reading queue", NULL);
    dispatch_async(fileQ, ^{
        NSString *pathToWordsFile = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"txt"];
        DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:pathToWordsFile];
        allWords = [[NSMutableArray alloc] initWithCapacity:TOTAL_WORDS];
        //__block int wordCount = 0;
        [reader enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            [allWords addObject:line];
            currentWord++;
        }];
        doneReadingFile = YES;
    });
    //values = @{@"a":@1, @"b":@4, @"c":@4, @"d":@2, @"e":@1, @"f":@4, @"g":@3, @"h":@3, @"i":@1, @"j":@10, @"k":@5, @"l":@2, @"m":@4, @"n":@2, @"o":@1, @"p":@4, @"q":@10, @"r":@1, @"s":@1, @"t":@1, @"u":@2, @"v":@5, @"w":@4, @"x":@8, @"y":@3, @"z":@10};
    values = (int *)malloc(sizeof(int) * LETTERS_IN_ALPHABET);
    values[0] = 1; values[1] = 4; values[2] = 4; values[3] = 2; values[4] = 1; values[5] = 4; values[6] = 3; values[7] = 3; values[8] = 1; values[9] = 10; values[10] = 5; values[11] = 2; values[12] = 4; values[13] = 2; values[14] = 1; values[15] = 4; values[16] = 10; values[17] = 1; values[18] = 1; values[19] = 1; values[20] = 2; values[21] = 5; values[22] = 4; values[23] = 8; values[24] = 3; values[25] = 10;
}

+ (void)mungeScreenshot:(UIImage *)screenshot
               delegate:(id<SolverDelegate>)delegate
         maxLetterCount:(int)maxLetterCount
         minLetterCount:(int)minLetterCount
{
    [delegate startProcessing];
    board = [Board new];
    int foundCount = 0, foundAtX = 0, foundAtY = 0;
    for (int x = 0; x < COLUMN_COUNT; x++)
    {
        for (int y = 0; y < ROW_COUNT; y++)
        {
            RectWrapper *rectWrapper = rects[y][x];
            CGRect cropRect = CGRectMake(rectWrapper.x, rectWrapper.y, LETTER_WIDTH, LETTER_HEIGHT);
            UIImage *croppedImage = [screenshot crop:cropRect];
            [SolverModel extractPixels:croppedImage pixelBuffer:croppedPixelBuffer];
            for (int color = 0; color < COLOR_COUNT; color++)
            {
                for (int letter = 0; letter < LETTERS_IN_ALPHABET; letter++)
                {
                    BOOL foundMismatch = NO;
                    for (int i = 0; i < PIXEL_COUNT; i++)
                    {
                        float sR = soloPixelBuffers[color][letter][i * 3];
                        float sG = soloPixelBuffers[color][letter][i * 3 + 1];
                        float sB = soloPixelBuffers[color][letter][i * 3 + 2];
                        float cR = croppedPixelBuffer[i * 3];
                        float cG = croppedPixelBuffer[i * 3 + 1];
                        float cB = croppedPixelBuffer[i * 3 + 2];
                        if ((sR > cR + EQUALITY_TOLERANCE) || (cR > sR + EQUALITY_TOLERANCE) ||
                            (sG > cG + EQUALITY_TOLERANCE) || (cG > sG + EQUALITY_TOLERANCE) ||
                            (sB > cB + EQUALITY_TOLERANCE) || (cB > sB + EQUALITY_TOLERANCE))
                        {
                            //NSLog(@"not equal sR: %f cR: %f sG: %f cG: %f sB: %f cB: %f", sR, cR, sG, cG, sB, cB);
                            foundMismatch = YES;
                            i = PIXEL_COUNT;
                            break;
                        }
                    }
                    if (!foundMismatch)
                    {
                        foundCount++;
                        foundAtX = x;
                        foundAtY = y;
                        [board addLetter:letter color:color];
                        letter = LETTERS_IN_ALPHABET;
                        color = COLOR_COUNT;
                        break;
                    }
                }
            }
        }
    }
    if (!doneReadingFile)
    {
        [delegate receiveStatus:[[NSAttributedString alloc] initWithString:@"Processing word file."]];
    }
    while (!doneReadingFile)
    {
        if (currentWord % TEN_PERCENT_OF_WORDS == PROGRESS_REMAINDER)
        {
            [delegate receiveProgress:1.0 - (currentWord / TOTAL_WORDS)];
        }
    }
    [delegate receiveStatus:[[NSAttributedString alloc] initWithString:@""]];
    int maxScore = 0;
    float maxScorePerLetter = 0;
    NSString *bestWord = @"";
    int start = [wordStarts[maxLetterCount - 1] intValue];
    int end = [wordEnds[minLetterCount - 1] intValue];
    int span = end - start;
    int chunkSize = span / NUMBER_OF_CHUNKS;
    int chunkIndex = 0;
    [delegate receiveProgress:0.0];
    for (int i = start; i <= end; i++)
    {
        NSString *word = allWords[i];
        unsigned long length = [word length];
        NSMutableArray *lettersAndColors = [NSMutableArray new];
        BOOL canSpellWord = YES;
        for (int j = 0; j < length; j++)
        {
            NSString *letter = [word substringWithRange:NSMakeRange(j, 1)];
            LetterAndColor *letterAndColor = [board retrieveLetterAndColor:letter];
            if (!letterAndColor)
            {
                canSpellWord = NO;
                break;
            }
            else
            {
                [lettersAndColors addObject:letterAndColor];
            }
        }
        if (canSpellWord)
        {
            int curScore = 0;
            for (int j = 0; j < length; j++)
            {
                int curBonus = 1;
                LetterAndColor *letterAndColor = lettersAndColors[j];
                if (letterAndColor.color == LIGHT_RED)
                {
                    curBonus = RED_BONUS;
                }
                else if (letterAndColor.color == LIGHT_BLUE)
                {
                    curBonus = BLUE_BONUS;
                }
                curScore += values[letterAndColor.letter] * curBonus;
            }
            for (int j = 0; j < length; j++)
            {
                LetterAndColor *letterAndColor = lettersAndColors[j];
                if (letterAndColor.color == DARK_RED)
                {
                    curScore *= RED_BONUS;
                }
                else if (letterAndColor.color == DARK_BLUE)
                {
                    curScore *= BLUE_BONUS;
                }
            }
            if ((float)(curScore / length) > maxScorePerLetter)
            {
                maxScore = curScore;
                maxScorePerLetter = (float)curScore / length;
                bestWord = word;
                bestLettersAndColors = lettersAndColors;
                [delegate receiveStatus:[SolverModel getAttributedScore:bestLettersAndColors prefix:@"Cur:" score:maxScore scorePerLetter:maxScorePerLetter]];
            }
        }
        [board resetUsage];
        if (chunkIndex++ == chunkSize)
        {
            chunkIndex = 0;
            [delegate receiveProgress:(float)i / span];
        }
    }
    if (maxScore)
    {
        [delegate receiveStatus:[SolverModel getAttributedScore:bestLettersAndColors prefix:@"Best:" score:maxScore scorePerLetter:maxScorePerLetter]];
    }
    else
    {
        [delegate receiveStatus:[[NSAttributedString alloc] initWithString:@"No words found."]];
    }
    [delegate endProcessing];
}

+ (NSAttributedString *)getAttributedScore:(NSArray *)lettersAndColors prefix:(NSString *)prefix score:(int)score scorePerLetter:(float)scorePerLetter
{
    NSMutableAttributedString *mat = [[NSMutableAttributedString alloc] initWithString:prefix];
    [mat appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    for (LetterAndColor *letterAndColor in lettersAndColors)
    {
        NSString *letterString = @"";
        switch (letterAndColor.letter)
        {
            case 0:
                letterString = @"a";
                break;
            case 1:
                letterString = @"b";
                break;
            case 2:
                letterString = @"c";
                break;
            case 3:
                letterString = @"d";
                break;
            case 4:
                letterString = @"e";
                break;
            case 5:
                letterString = @"f";
                break;
            case 6:
                letterString = @"g";
                break;
            case 7:
                letterString = @"h";
                break;
            case 8:
                letterString = @"i";
                break;
            case 9:
                letterString = @"j";
                break;
            case 10:
                letterString = @"k";
                break;
            case 11:
                letterString = @"l";
                break;
            case 12:
                letterString = @"m";
                break;
            case 13:
                letterString = @"n";
                break;
            case 14:
                letterString = @"o";
                break;
            case 15:
                letterString = @"p";
                break;
            case 16:
                letterString = @"q";
                break;
            case 17:
                letterString = @"r";
                break;
            case 18:
                letterString = @"s";
                break;
            case 19:
                letterString = @"t";
                break;
            case 20:
                letterString = @"u";
                break;
            case 21:
                letterString = @"v";
                break;
            case 22:
                letterString = @"w";
                break;
            case 23:
                letterString = @"x";
                break;
            case 24:
                letterString = @"y";
                break;
            case 25:
                letterString = @"z";
                break;
        }
        UIColor *color = nil;
        switch (letterAndColor.color)
        {
            case DARK_BLUE:
                color = [UIColor colorWithRed:.2 green:.2 blue:1.0 alpha:1.0];
                break;
            case DARK_RED:
                color = [UIColor redColor];
                break;
            case LIGHT_BLUE:
                color = [UIColor colorWithRed:.5 green:.5 blue:1.0 alpha:1.0];
                break;
            case LIGHT_RED:
                color = [UIColor colorWithRed:1.0 green:.5 blue:.5 alpha:1.0];
                break;
            case WHITE:
                color = [UIColor whiteColor];
                break;
        }
        [mat appendAttributedString:[[NSAttributedString alloc] initWithString:letterString attributes:@{ NSForegroundColorAttributeName:color }]];
    }
    [mat appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d %.1f", score, scorePerLetter]]];
    return mat;
}

+ (void)extractPixels:(UIImage *)image pixelBuffer:(float *)pixelBuffer
{
    CGImageRef imageRef = [image CGImage];
    CGContextRef context = CGBitmapContextCreate(rawDataBuffer, LETTER_WIDTH, LETTER_HEIGHT,
                                                 BITS_PER_COMPONENT, BYTES_PER_ROW, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, letterRect, imageRef);
    CGContextRelease(context);
    
    int pixelIndex = 0;
    for (NSUInteger y = 0; y < LETTER_HEIGHT; y++)
    {
        for (NSUInteger x = 0; x < LETTER_WIDTH; x++)
        {
            unsigned long byteIndex = (BYTES_PER_ROW * y) + x * BYTES_PER_PIXEL;
            pixelBuffer[pixelIndex++] = rawDataBuffer[byteIndex];
            pixelBuffer[pixelIndex++] = rawDataBuffer[byteIndex + 1];
            pixelBuffer[pixelIndex++] = rawDataBuffer[byteIndex + 2];
        }
    }
}
@end
