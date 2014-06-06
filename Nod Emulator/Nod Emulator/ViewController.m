//
//  ViewController.m
//  Nod Emulator
//
//  Copyright (c) 2014 Nod Inc. All rights reserved.
//

#import "ViewController.h"
#import "NodBluetoothEmulator.h"
#import "OpenSpatialDecoder.h"

@interface ViewController ()

@property NodBluetoothEmulator* NBE;

@end

@implementation ViewController

#define NOPRESS 0
#define LTOUCHPRESSED 1
#define RTOUCHPRESSED 2
#define BOTHTOUCHPRESSED 3
#define SLIDEHOLDPRESSED 4
#define SLIDEHOLDLTOUCH 5
#define SLIDEHOLDRTOUCH 6
#define ALL3PRESSED 7
#define LTACTPRESSED 1
#define RTACTPRESSED 2
#define BOTHTACTPRESSED 3

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.trackView setBackgroundColor:[UIColor colorWithPatternImage:
                                        [UIImage imageNamed:@"nod-logo"]]];
    self.trackView.layer.cornerRadius = 25;
    self.trackView.layer.masksToBounds = YES;
    self.trackView.layer.borderColor = [UIColor blackColor].CGColor;
    self.trackView.layer.borderWidth = 1.0f;
    [self.sliderView setBackgroundColor:[ViewController colorWithHexString:@"00A6DE"]];
    self.sliderView.layer.cornerRadius = 10;
    self.sliderView.layer.masksToBounds = YES;
    self.sliderView.alpha = .3;
    self.quatBut.alpha = .4;
    self.sliderView.parent = self;
    self.trackView.delegate = self;
    self.NBE = [NodBluetoothEmulator sharedEmulator];
    [self.LTouch addTarget:self action:@selector(leftTouchPressed)
          forControlEvents:UIControlEventTouchDown];
    [self.RTouch addTarget:self action:@selector(rightTouchPressed)
          forControlEvents:UIControlEventTouchDown];
    [self.LTact addTarget:self action:@selector(leftTactPressed)
         forControlEvents:UIControlEventTouchDown];
    [self.RTact addTarget:self action:@selector(rightTactPressed)
         forControlEvents:UIControlEventTouchDown];
    [self.LSlide addTarget:self action:@selector(leftSlidePressed)
          forControlEvents:UIControlEventTouchDown];
    [self.RSlide addTarget:self action:@selector(rightSlidePressed)
          forControlEvents:UIControlEventTouchDown];
    [self.quatBut addTarget:self action:@selector(enableQuat)
           forControlEvents:UIControlEventTouchDown];
    [self.swipeUp addTarget:self action:@selector(swipedUp)
           forControlEvents:UIControlEventTouchDown];
    [self.swipeDown addTarget:self action:@selector(swipedDown)
             forControlEvents:UIControlEventTouchDown];
    [self.swipeLeft addTarget:self action:@selector(swipedLeft)
             forControlEvents:UIControlEventTouchDown];
    [self.swipeRight addTarget:self action:@selector(swipedRight)
              forControlEvents:UIControlEventTouchDown];
}

+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                         uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

uint8_t touchVal = 0;
uint8_t slideVal = 0;
uint8_t tactVal = 0;

- (void) leftTouchPressed
{
    switch (touchVal) {
        case NOPRESS:
            touchVal = LTOUCHPRESSED;
            [self.LTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case LTOUCHPRESSED:
            touchVal = NOPRESS;
            [self.LTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                         forState:UIControlStateNormal];
            break;
        case RTOUCHPRESSED:
            touchVal = BOTHTOUCHPRESSED;
            [self.LTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case BOTHTOUCHPRESSED:
            touchVal = RTOUCHPRESSED;
            [self.LTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                         forState:UIControlStateNormal];
            break;
        case SLIDEHOLDPRESSED:
            touchVal = SLIDEHOLDLTOUCH;
            [self.LTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case SLIDEHOLDLTOUCH:
            touchVal = SLIDEHOLDPRESSED;
            [self.LTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                         forState:UIControlStateNormal];
            break;
        case SLIDEHOLDRTOUCH:
            touchVal = ALL3PRESSED;
            [self.LTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case ALL3PRESSED:
            touchVal = SLIDEHOLDRTOUCH;
            [self.LTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                         forState:UIControlStateNormal];
            break;
    }

    NSDictionary* retDic = @{ X : @0,
                      Y : @0,
                      TOUCH : @(touchVal),
                      SLIDE : @(slideVal),
                      TACTILE : @(tactVal),
                      };

    char* bytes = [OpenSpatialDecoder createPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:OS2DSIZE];
    [self.NBE sendOS2D:temp];
}

- (void) rightTouchPressed
{
    switch (touchVal) {
        case NOPRESS:
            touchVal = RTOUCHPRESSED;
            [self.RTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case LTOUCHPRESSED:
            touchVal = BOTHTOUCHPRESSED;
            [self.RTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case RTOUCHPRESSED:
            touchVal = NOPRESS;
            [self.RTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                         forState:UIControlStateNormal];
            break;
        case BOTHTOUCHPRESSED:
            touchVal = LTOUCHPRESSED;
            [self.RTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                         forState:UIControlStateNormal];
            break;
        case SLIDEHOLDPRESSED:
            touchVal = SLIDEHOLDRTOUCH;
            [self.RTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case SLIDEHOLDLTOUCH:
            touchVal = ALL3PRESSED;
            [self.RTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case SLIDEHOLDRTOUCH:
            touchVal = SLIDEHOLDPRESSED;
            [self.RTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                         forState:UIControlStateNormal];
            break;
        case ALL3PRESSED:
            touchVal = SLIDEHOLDLTOUCH;
            [self.RTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
    }

    NSDictionary* retDic = @{ X : @0,
                              Y : @0,
                              TOUCH : @(touchVal),
                              SLIDE : @(slideVal),
                              TACTILE : @(tactVal),
                              };

    char* bytes = [OpenSpatialDecoder createPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:OS2DSIZE];
    [self.NBE sendOS2D:temp];
}

- (void) SlideHoldPressed
{
    switch (touchVal) {
        case NOPRESS:
            touchVal = SLIDEHOLDPRESSED;
            break;
        case LTOUCHPRESSED:
            touchVal = SLIDEHOLDLTOUCH;
            break;
        case RTOUCHPRESSED:
            touchVal = SLIDEHOLDRTOUCH;
            break;
        case BOTHTOUCHPRESSED:
            touchVal = ALL3PRESSED;
            break;
        case SLIDEHOLDPRESSED:
            touchVal = NOPRESS;
            break;
        case SLIDEHOLDLTOUCH:
            touchVal = LTOUCHPRESSED;
            break;
        case SLIDEHOLDRTOUCH:
            touchVal = RTOUCHPRESSED;
            break;
        case ALL3PRESSED:
            touchVal = BOTHTOUCHPRESSED;
            break;
    }

    NSDictionary* retDic = @{ X : @0,
                              Y : @0,
                              TOUCH : @(touchVal),
                              SLIDE : @(slideVal),
                              TACTILE : @(tactVal),
                              };

    char* bytes = [OpenSpatialDecoder createPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:OS2DSIZE];
    [self.NBE sendOS2D:temp];
}

- (void) leftTactPressed
{
    switch (tactVal) {
        case NOPRESS:
            tactVal = LTACTPRESSED;
            [self.LTact setImage:[UIImage imageNamed:@"RedButton.png"]
                         forState:UIControlStateNormal];
            break;
        case LTACTPRESSED:
            tactVal = NOPRESS;
            [self.LTact setImage:[UIImage imageNamed:@"BlueButton.png"]
                        forState:UIControlStateNormal];
            break;
        case RTACTPRESSED:
            tactVal = BOTHTACTPRESSED;
            [self.LTact setImage:[UIImage imageNamed:@"RedButton.png"]
                        forState:UIControlStateNormal];
            break;
        case BOTHTACTPRESSED:
            tactVal = RTACTPRESSED;
            [self.LTact setImage:[UIImage imageNamed:@"BlueButton.png"]
                        forState:UIControlStateNormal];
            break;
    }

    NSDictionary* retDic = @{ X : @0,
                              Y : @0,
                              TOUCH : @(touchVal),
                              SLIDE : @(slideVal),
                              TACTILE : @(tactVal),
                              };

    char* bytes = [OpenSpatialDecoder createPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:OS2DSIZE];
    [self.NBE sendOS2D:temp];
}

- (void) rightTactPressed
{
    switch (tactVal) {
        case NOPRESS:
            tactVal = RTACTPRESSED;
            [self.RTact setImage:[UIImage imageNamed:@"RedButton.png"]
                        forState:UIControlStateNormal];
            break;
        case LTACTPRESSED:
            tactVal = BOTHTACTPRESSED;
            [self.RTact setImage:[UIImage imageNamed:@"RedButton.png"]
                        forState:UIControlStateNormal];
            break;
        case RTACTPRESSED:
            tactVal = NOPRESS;
            [self.RTact setImage:[UIImage imageNamed:@"BlueButton.png"]
                        forState:UIControlStateNormal];
            break;
        case BOTHTACTPRESSED:
            tactVal = LTACTPRESSED;
            [self.RTact setImage:[UIImage imageNamed:@"RedButton.png"]
                        forState:UIControlStateNormal];
            break;
    }

    NSDictionary* retDic = @{ X : @0,
                              Y : @0,
                              TOUCH : @(touchVal),
                              SLIDE : @(slideVal),
                              TACTILE : @(tactVal),
                              };

    char* bytes = [OpenSpatialDecoder createPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:OS2DSIZE];
    [self.NBE sendOS2D:temp];
}

-(void) leftSlidePressed
{
    slideVal--;
    NSDictionary* retDic = @{ X : @0,
                              Y : @0,
                              TOUCH : @(touchVal),
                              SLIDE : @(slideVal),
                              TACTILE : @(tactVal),
                              };

    char* bytes = [OpenSpatialDecoder createPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:OS2DSIZE];
    [self.NBE sendOS2D:temp];
}
-(void) rightSlidePressed
{
    slideVal++;
    NSDictionary* retDic = @{ X : @0,
                              Y : @0,
                              TOUCH : @(touchVal),
                              SLIDE : @(slideVal),
                              TACTILE : @(tactVal),
                              };

    char* bytes = [OpenSpatialDecoder createPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:OS2DSIZE];
    [self.NBE sendOS2D:temp];
}

-(void) sendCoordinates:(int)x y:(int)y
{
    short int x2 = x;
    short int y2 = y;
    NSDictionary* retDic = @{ X : @(x2),
                              Y : @(y2),
                              TOUCH : @(touchVal),
                              SLIDE : @(slideVal),
                              TACTILE : @(tactVal),
                              };

    char* bytes = [OpenSpatialDecoder createPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:OS2DSIZE];
    [self.NBE sendOS2D:temp];
}

bool quatEnabled = false;
-(void) enableQuat
{
    if(!quatEnabled)
    {
        // Create a CMMotionManager
        if(!self.motionManager)
        {
            self.motionManager = [[CMMotionManager alloc] init];
        }

        // Tell CoreMotion to show the compass calibration HUD when required
        // to provide true north-referenced attitude
        self.motionManager.showsDeviceMovementDisplay = YES;
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 20.0;

        // Start Motion
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
            withHandler:^(CMDeviceMotion *motion, NSError *error)
            {
                CMQuaternion quat = motion.attitude.quaternion;
                NSDictionary* retDic = @{ X : @(-quat.x),
                                          Y : @(-quat.z),
                                          Z : @(-quat.y),
                                          W : @(quat.w),
                                          };
                char* bytes = [OpenSpatialDecoder createQuatPointer:retDic];
                NSData* temp = [NSData dataWithBytes:bytes length:QUATSIZE];
                [self.NBE sendRawQuat:temp];
            }
        ];
        self.quatBut.alpha = 1.0;
        quatEnabled = true;
    }
    else
    {
        [self.motionManager stopDeviceMotionUpdates];
        self.quatBut.alpha = .4;
        quatEnabled = false;
    }

}

- (void) swipedUp
{
    NSDictionary* retDic = @{GEST: @GUP};
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GESTSIZE];
    [self.NBE sendGesture:temp];
}

- (void) swipedDown
{
    NSDictionary* retDic = @{GEST: @GDOWN};
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GESTSIZE];
    [self.NBE sendGesture:temp];
}

- (void) swipedLeft
{
    NSDictionary* retDic = @{GEST: @GLEFT};
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GESTSIZE];
    [self.NBE sendGesture:temp];
}

- (void) swipedRight
{
    NSDictionary* retDic = @{GEST: @GRIGHT};
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GESTSIZE];
    [self.NBE sendGesture:temp];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.motionManager stopDeviceMotionUpdates];
}

@end
