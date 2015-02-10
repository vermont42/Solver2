//
//  ViewController.m
//  Solver2
//
//  Created by Joshua Adams on 11/30/14.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//

#import "ViewController.h"
#import "SolverModel.h"
#import "UIImage+Crop.h"
#import "DoubleSlider.h"

@interface ViewController () <SolverDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, DoubleSliderDelegate>
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *screenShotView;
@property (strong, nonatomic) IBOutlet UIButton *selectScreenshotButton;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet DoubleSlider *wordLengthSlider;
@property (nonatomic) int minWordLength;
@property (nonatomic) int maxWordLength;
@property (nonatomic) BOOL foundImage;
@end

static const float BOARD_X = 0, BOARD_Y = 248, BOARD_WIDTH = 637, BOARD_HEIGHT = 639;
static const double ANIMATION_DURATION = 0.2;
static const double ANIMATION_DELAY = 0.0;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wordLengthSlider.delegate = self;
    self.minWordLength = 4;
    self.maxWordLength = 12;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.progressView.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.foundImage = NO;
}

- (IBAction)selectScreenshot:(UIButton *)sender
{
#if TARGET_IPHONE_SIMULATOR
    UIImage *screenshot = [UIImage imageNamed:@"ss1.png"];
    self.screenShotView.image = screenshot;
    dispatch_queue_t mungeQ = dispatch_queue_create("munge queue", NULL);
    dispatch_async(mungeQ, ^{
        //double start = [[NSDate date] timeIntervalSince1970];
        [SolverModel mungeScreenshot:screenshot
                            delegate:self
                      maxLetterCount:self.maxWordLength
                      minLetterCount:self.minWordLength];
        //double end = [[NSDate date] timeIntervalSince1970];
        //double timeInterval = end - start;
    });
#else
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    [self presentViewController: controller animated:YES completion:nil];
#endif
}

- (void)minIntValueChanged:(int)minIntValue
{
    self.minWordLength = minIntValue;
}

- (void)maxIntValueChanged:(int)maxIntValue
{
    self.maxWordLength = maxIntValue;
}

- (void)startProcessing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.selectScreenshotButton.hidden = YES;
        self.progressView.alpha = 1;
    });
}

- (void)endProcessing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.alpha = 0;
        self.selectScreenshotButton.hidden = NO;
    });
}

- (void)receiveProgress:(float)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL animated = YES;
        if (progress == 0.0)
        {
            animated = NO;
        }
        [self.progressView setProgress:progress animated:animated];
    });
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    [self dismissModalViewControllerAnimated:YES];
    self.screenShotView.image = [image crop:CGRectMake(BOARD_X, BOARD_Y, BOARD_WIDTH, BOARD_HEIGHT)];
    dispatch_queue_t mungeQ = dispatch_queue_create("munge queue", NULL);
    dispatch_async(mungeQ, ^{
        [SolverModel mungeScreenshot:image
                            delegate:self
                      maxLetterCount:self.maxWordLength
                      minLetterCount:self.minWordLength];
    });

}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 static const double ANIMATION_DURATION = 0.3;
 static const double ANIMATION_DELAY = 0.0;
 
 @implementation WidgetFader
 + (void)showWidget:(UIView *)widget
 {
 [UIView animateWithDuration:ANIMATION_DURATION
 delay:ANIMATION_DELAY
 options:UIViewAnimationOptionAllowUserInteraction
 animations:^(void) {
 if ([widget isKindOfClass:[UIButton class]])
 {
 ((UIButton *)widget).enabled = YES;
 }
 widget.alpha = 1.0;
 } completion:nil];
 }
 
 */

- (void) receiveStatus:(NSAttributedString *)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:ANIMATION_DELAY
                            options:UIViewAnimationOptionTransitionNone
                         animations:^(void) {
                             self.statusLabel.alpha = 0.0;
                         } completion:nil];
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:ANIMATION_DELAY
                            options:UIViewAnimationOptionTransitionNone
                         animations:^(void) {
                             self.statusLabel.attributedText = status;
                             self.statusLabel.alpha = 1.0;
                         } completion:nil];
    });
}
@end
