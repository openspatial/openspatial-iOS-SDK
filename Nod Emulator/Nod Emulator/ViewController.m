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
    [self.quatBut addTarget:self action:@selector(enableTrans3D)
           forControlEvents:UIControlEventTouchDown];
    [self.swipeUp addTarget:self action:@selector(swipedUp)
           forControlEvents:UIControlEventTouchDown];
    [self.swipeDown addTarget:self action:@selector(swipedDown)
             forControlEvents:UIControlEventTouchDown];
    [self.swipeLeft addTarget:self action:@selector(swipedLeft)
             forControlEvents:UIControlEventTouchDown];
    [self.swipeRight addTarget:self action:@selector(swipedRight)
              forControlEvents:UIControlEventTouchDown];
    [self.twistRight addTarget:self action:@selector(twistedRight)
              forControlEvents:UIControlEventTouchDown];
    [self.twistLeft addTarget:self action:@selector(twistedLeft)
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



short touch0 = 0;
short touch1 = 0;
short touch2 = 0;
short tact0 = 0;
short tact1 = 0;

/*                  FOR ALL EMULATOR TOUCH METHODS
 *                  touch0 -> left touch
 *                  touch1 -> right touch
 *                  touch2 -> slider touch
 *                  tact0 -> left tact
 *                  tact1 -> right tact
 */

- (void) leftTouchPressed
{
    if(touch0 == BUTTON_UNUSED || touch0 == BUTTON_UP)
    {
        touch0 = BUTTON_DOWN;
        [self.LTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                     forState:UIControlStateNormal];
    }
    else
    {
        touch0 = BUTTON_UP;
        [self.LTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                     forState:UIControlStateNormal];
    }
    NSLog(@"%d",touch0);
    NSDictionary* retDic = @{ TOUCH_0 : @(touch0),
                              TOUCH_1 : @(0),
                              TOUCH_2 : @(0),
                              TACTILE_0 : @(0),
                              TACTILE_1 : @(0),
                              };

    char* bytes = [OpenSpatialDecoder createButtonPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:BUTTON_SIZE];
    [self.NBE sendButton:temp];
}



- (void) rightTouchPressed
{
    if(touch1 == BUTTON_UNUSED || touch1 == BUTTON_UP)
    {
        touch1 = BUTTON_DOWN;
        [self.RTouch setImage:[UIImage imageNamed:@"RedButton.png"]
                     forState:UIControlStateNormal];
    }
    else
    {
        touch1 = BUTTON_UP;
        [self.RTouch setImage:[UIImage imageNamed:@"BlueButton.png"]
                     forState:UIControlStateNormal];
    }

    NSDictionary* retDic = @{ TOUCH_0 : @(0),
                              TOUCH_1 : @(touch1),
                              TOUCH_2 : @(0),
                              TACTILE_0 : @(0),
                              TACTILE_1 : @(0),
                              };

    char* bytes = [OpenSpatialDecoder createButtonPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:BUTTON_SIZE];
    [self.NBE sendButton:temp];
}

- (void) SlideHoldPressed
{
    if(touch2 == BUTTON_UNUSED || touch2 == BUTTON_UP)
    {
        touch2 = BUTTON_DOWN;
    }
    else
    {
        touch2 = BUTTON_UP;
    }

    NSDictionary* retDic = @{ TOUCH_0 : @(0),
                              TOUCH_1 : @(0),
                              TOUCH_2 : @(touch2),
                              TACTILE_0 : @(0),
                              TACTILE_1 : @(0),
                              };

    char* bytes = [OpenSpatialDecoder createButtonPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:BUTTON_SIZE];
    [self.NBE sendButton:temp];
}

- (void) leftTactPressed
{
    if(tact0 == BUTTON_UNUSED || tact0 == BUTTON_UP)
    {
        tact0 = BUTTON_DOWN;
        [self.LTact setImage:[UIImage imageNamed:@"RedButton.png"]
                     forState:UIControlStateNormal];
    }
    else
    {
        [self.LTact setImage:[UIImage imageNamed:@"BlueButton.png"]
                     forState:UIControlStateNormal];
        tact0 = BUTTON_UP;
    }

    NSDictionary* retDic = @{ TOUCH_0 : @(0),
                              TOUCH_1 : @(0),
                              TOUCH_2 : @(0),
                              TACTILE_0 : @(tact0),
                              TACTILE_1 : @(0),
                              };

    char* bytes = [OpenSpatialDecoder createButtonPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:BUTTON_SIZE];
    [self.NBE sendButton:temp];
}

- (void) rightTactPressed
{
    if(tact1 == BUTTON_UNUSED || tact1 == BUTTON_UP)
    {
        tact1 = BUTTON_DOWN;
        [self.RTact setImage:[UIImage imageNamed:@"RedButton.png"]
                     forState:UIControlStateNormal];
    }
    else
    {
        tact1 = BUTTON_UP;
        [self.RTact setImage:[UIImage imageNamed:@"BlueButton.png"]
                     forState:UIControlStateNormal];
    }

    NSDictionary* retDic = @{ TOUCH_0 : @(0),
                              TOUCH_1 : @(0),
                              TOUCH_2 : @(0),
                              TACTILE_0 : @(0),
                              TACTILE_1 : @(tact1),
                              };

    char* bytes = [OpenSpatialDecoder createButtonPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:BUTTON_SIZE];
    [self.NBE sendButton:temp];
}

-(void) leftSlidePressed
{
    NSDictionary* retDic = @{GEST_OPCODE : @G_OP_SCROLL,
                            GEST_DATA : @SLIDE_LEFT,
                             };
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GEST_SIZE];
    [self.NBE sendGesture:temp];
}
-(void) rightSlidePressed
{
    NSDictionary* retDic = @{GEST_OPCODE : @G_OP_SCROLL,
                             GEST_DATA : @SLIDE_RIGHT,
                             };
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GEST_SIZE];
    [self.NBE sendGesture:temp];
}

-(void) sendCoordinates:(int)x y:(int)y
{
    short int x2 = x;
    short int y2 = y;
    NSDictionary* retDic = @{ X : @(x2),
                              Y : @(y2),
                              };

    char* bytes = [OpenSpatialDecoder createPos2DPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:POS2D_SIZE];
    [self.NBE sendOS2D:temp];
}

bool trans3DEnabled = false;
-(void) enableTrans3D
{
    if(!trans3DEnabled)
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
                NSDictionary* retDic = @{ X : @(0),
                                          Y : @(0),
                                          Z : @(0),
                                          ROLL : @(motion.attitude.roll),
                                          PITCH : @(motion.attitude.pitch),
                                          YAW : @(motion.attitude.yaw),
                                          };
                char* bytes = [OpenSpatialDecoder create3DTransPointer:retDic];
                NSData* temp = [NSData dataWithBytes:bytes length:TRANS3D_SIZE];
                [self.NBE send3DTrans:temp];
            }
        ];
        self.quatBut.alpha = 1.0;
        trans3DEnabled = true;
    }
    else
    {
        [self.motionManager stopDeviceMotionUpdates];
        self.quatBut.alpha = .4;
        trans3DEnabled = false;
    }

}

- (void) swipedUp
{
    NSDictionary* retDic = @{GEST_OPCODE: @G_OP_DIRECTION,
                             GEST_DATA : @GUP,
                             };
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GEST_SIZE];
    [self.NBE sendGesture:temp];
}

- (void) swipedDown
{
    NSDictionary* retDic = @{GEST_OPCODE: @G_OP_DIRECTION,
                             GEST_DATA : @GDOWN,
                             };
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GEST_SIZE];
    [self.NBE sendGesture:temp];
}

- (void) swipedLeft
{
    NSDictionary* retDic = @{GEST_OPCODE: @G_OP_DIRECTION,
                             GEST_DATA : @GLEFT,
                             };
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GEST_SIZE];
    [self.NBE sendGesture:temp];
}

- (void) swipedRight
{
    NSDictionary* retDic = @{GEST_OPCODE: @G_OP_DIRECTION,
                             GEST_DATA : @GRIGHT,
                             };
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GEST_SIZE];
    [self.NBE sendGesture:temp];
}

- (void) twistedLeft
{
    NSDictionary* retDic = @{GEST_OPCODE: @G_OP_DIRECTION,
                             GEST_DATA : @GCW,
                             };
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GEST_SIZE];
    [self.NBE sendGesture:temp];
}

- (void) twistedRight
{
    NSDictionary* retDic = @{GEST_OPCODE: @G_OP_DIRECTION,
                             GEST_DATA : @GCCW,
                             };
    char* bytes = [OpenSpatialDecoder createGestPointer:retDic];
    NSData* temp = [NSData dataWithBytes:bytes length:GEST_SIZE];
    [self.NBE sendGesture:temp];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.motionManager stopDeviceMotionUpdates];
}

@end
