//
//  ViewController.h
//  Nod Emulator
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "TouchView.h"
#import "SliderView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController <TouchViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *LTouch;
@property (weak, nonatomic) IBOutlet UIButton *RTouch;
@property (weak, nonatomic) IBOutlet UIButton *LTact;
@property (weak, nonatomic) IBOutlet UIButton *RTact;
@property (weak, nonatomic) IBOutlet UIButton *LSlide;
@property (weak, nonatomic) IBOutlet UIButton *RSlide;
@property (weak, nonatomic) IBOutlet TouchView *trackView;
@property (weak, nonatomic) IBOutlet UIButton *quatBut;
@property (weak, nonatomic) IBOutlet UIButton *eulerBut;
@property (weak, nonatomic) IBOutlet UIButton *swipeUp;
@property (weak, nonatomic) IBOutlet UIButton *swipeRight;
@property (weak, nonatomic) IBOutlet UIButton *swipeDown;
@property (weak, nonatomic) IBOutlet UIButton *swipeLeft;
@property (weak, nonatomic) IBOutlet SliderView *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *twistLeft;
@property (weak, nonatomic) IBOutlet UIButton *twistRight;
@property CMMotionManager* motionManager;

-(void) leftSlidePressed;
-(void) rightSlidePressed;
-(void) SlideHoldPressed;
+(UIColor*) colorWithHexString:(NSString*) hex;

@end
